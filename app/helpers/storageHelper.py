"""
storageHelper.py — Tiaki
Upload storage abstraction: Cloudflare R2 (production) or local static/ (dev).

Every user upload (avatars, group identity photos, update photos, ticket
screenshots) goes through this module instead of writing to disk directly.
Render's free tier has an ephemeral filesystem, so anything written locally
is lost on deploy/restart — R2 is the durable home for uploads in production.

Mode selection is automatic: when the R2_* environment variables are all
set, files go to R2 and URLs point at R2_PUBLIC_BASE_URL; otherwise files
land under static/ exactly as before, so local development needs no R2
account and no extra setup.

Keys are static-relative paths (e.g. 'images/uploads/avatar_ab12.png' or
'uploads/group_3/cover.webp') — the same strings the DB already stores, so
no data migration is needed. Existing files are copied to the bucket once
with scripts/sync_uploads_to_r2.py.
"""

import glob
import logging
import mimetypes
import os

from flask import url_for

logger = logging.getLogger(__name__)

# Filesystem root for local mode — resolved relative to this file so the
# helper also works outside an app context (e.g. one-off scripts).
STATIC_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..', '..', 'static'))

_R2_ENV_KEYS = ('R2_ACCOUNT_ID', 'R2_ACCESS_KEY_ID', 'R2_SECRET_ACCESS_KEY',
                'R2_BUCKET', 'R2_PUBLIC_BASE_URL')

_client = None  # cached boto3 client (thread-safe for our use)


def storage_enabled():
    """True when all R2_* env vars are set and uploads should go to R2."""
    return all(os.environ.get(k) for k in _R2_ENV_KEYS)


def _r2():
    """Cached boto3 S3 client pointed at the account's R2 endpoint."""
    global _client
    if _client is None:
        import boto3
        _client = boto3.client(
            's3',
            endpoint_url=('https://'
                          f"{os.environ['R2_ACCOUNT_ID']}.r2.cloudflarestorage.com"),
            aws_access_key_id=os.environ['R2_ACCESS_KEY_ID'],
            aws_secret_access_key=os.environ['R2_SECRET_ACCESS_KEY'],
            region_name='auto',
        )
    return _client


def _local_path(key):
    return os.path.join(STATIC_ROOT, key)


def save_file(file, key):
    """Store an uploaded FileStorage under `key`.

    Raises OSError on failure in either mode, so existing callers'
    `except OSError` handling keeps working unchanged.
    """
    if storage_enabled():
        content_type = mimetypes.guess_type(key)[0] or 'application/octet-stream'
        try:
            file.stream.seek(0)
            _r2().put_object(
                Bucket=os.environ['R2_BUCKET'],
                Key=key,
                Body=file.stream,
                ContentType=content_type,
            )
        except Exception as exc:
            logger.exception('R2 upload failed for %s', key)
            raise OSError(f'R2 upload failed for {key}') from exc
    else:
        path = _local_path(key)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        file.save(path)


def delete_file(key):
    """Delete a stored file. Missing files are a no-op; failures are logged
    (deletes are cleanup, not user-facing — callers never need to handle)."""
    if not key:
        return
    if storage_enabled():
        try:
            _r2().delete_object(Bucket=os.environ['R2_BUCKET'], Key=key)
        except Exception:
            logger.warning('R2 delete failed for %s', key, exc_info=True)
    else:
        path = _local_path(key)
        if os.path.exists(path):
            try:
                os.remove(path)
            except OSError:
                logger.warning('Local delete failed for %s', key, exc_info=True)


def delete_prefix(prefix, keep=None):
    """Delete every stored file whose key starts with `prefix`, except an
    optional `keep` key. Used to sweep stale identity-slot siblings
    (cover.jpg left behind after a cover.webp upload)."""
    if storage_enabled():
        try:
            resp = _r2().list_objects_v2(
                Bucket=os.environ['R2_BUCKET'], Prefix=prefix)
            for obj in resp.get('Contents', []):
                if obj['Key'] != keep:
                    delete_file(obj['Key'])
        except Exception:
            logger.warning('R2 prefix sweep failed for %s', prefix, exc_info=True)
    else:
        for path in glob.glob(_local_path(prefix) + '*'):
            key = os.path.relpath(path, STATIC_ROOT).replace(os.sep, '/')
            if key != keep:
                delete_file(key)


def _normalize_key(key):
    """Legacy DB rows (seed data) store a bare filename for files that
    live under images/uploads/; newer rows store the full key
    ('uploads/group_3/cover.webp'). Treat any slash-less key as the
    legacy form so both resolve to a valid URL."""
    return key if '/' in key else f'images/uploads/{key}'


def upload_url(key):
    """Public URL for a stored upload, or None when `key` is falsy.

    No existence check — a stale DB reference renders a broken <img>,
    which img-fallback.js swaps for the bundled default client-side.
    """
    if not key:
        return None
    key = _normalize_key(key)
    if storage_enabled():
        return f"{os.environ['R2_PUBLIC_BASE_URL'].rstrip('/')}/{key}"
    return url_for('static', filename=key)


def upload_url_if_exists(key):
    """Like upload_url, but returns None when the file is verifiably
    missing, so `or`-chained callers (the identity cascade) fall through
    to their generated default instead of serving a broken image.

    Only local mode can check cheaply; in R2 mode a HEAD per render is
    not worth the latency — durable storage removes the original failure
    mode (ephemeral disk), and img-fallback.js covers the residual case.
    """
    if not key:
        return None
    key = _normalize_key(key)
    if not storage_enabled() and not os.path.isfile(_local_path(key)):
        return None
    return upload_url(key)
