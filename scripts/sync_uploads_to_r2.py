"""One-off sync of existing upload files into the Cloudflare R2 bucket.

Run this once when switching production to R2, so that files the seed data
references (static/images/uploads/) and any surviving runtime uploads
(static/uploads/) exist in the bucket before upload_url() starts pointing
image tags at it.

Usage:
    # with the R2_* variables set in .env (or the environment):
    python scripts/sync_uploads_to_r2.py            # upload everything
    python scripts/sync_uploads_to_r2.py --dry-run  # just list what would go

Safe to re-run: existing objects are simply overwritten with the same bytes.
"""

import argparse
import mimetypes
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

from app.helpers import storageHelper  # noqa: E402 — needs env loaded first

# Static-relative trees that hold uploads referenced by the database.
UPLOAD_TREES = ('images/uploads', 'uploads')


def iter_upload_keys():
    for tree in UPLOAD_TREES:
        root = os.path.join(storageHelper.STATIC_ROOT, tree)
        if not os.path.isdir(root):
            continue
        for dirpath, _dirnames, filenames in os.walk(root):
            for name in filenames:
                if name.startswith('.'):  # .DS_Store and friends
                    continue
                path = os.path.join(dirpath, name)
                key = os.path.relpath(path, storageHelper.STATIC_ROOT)
                yield key.replace(os.sep, '/'), path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true',
                        help='list the files without uploading')
    args = parser.parse_args()

    if not storageHelper.storage_enabled():
        sys.exit('R2 is not configured — set the R2_* variables in .env first '
                 '(see .env.example).')

    bucket = os.environ['R2_BUCKET']
    client = storageHelper._r2()

    count = 0
    for key, path in iter_upload_keys():
        count += 1
        if args.dry_run:
            print(f'would upload {key}')
            continue
        content_type = mimetypes.guess_type(key)[0] or 'application/octet-stream'
        with open(path, 'rb') as fh:
            client.put_object(Bucket=bucket, Key=key, Body=fh,
                              ContentType=content_type)
        print(f'uploaded {key}')

    verb = 'listed' if args.dry_run else 'uploaded'
    print(f'\n{verb} {count} file(s) to bucket {bucket!r}')


if __name__ == '__main__':
    main()
