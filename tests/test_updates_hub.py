"""Smoke tests for Group Updates & Knowledge Hub (P2-107)."""

import os
import sys
import pathlib
import unittest
from unittest.mock import patch

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))


class _DD(dict):
    def __getitem__(self, k):
        return self.get(k, 0)


class _FakeCursor:
    def __init__(self):
        self._last = []

    def __enter__(self):
        return self

    def __exit__(self, *a):
        return False

    def execute(self, sql, params=None):
        if 'group_memberships WHERE user_id' in sql:
            self._last = [_DD(membership_id=1)]
        else:
            self._last = []

    def fetchone(self):
        if isinstance(self._last, list) and self._last:
            return self._last[0]
        return _DD()

    def fetchall(self):
        return list(self._last) if isinstance(self._last, list) else []

    def close(self):
        pass


class _FakeConn:
    autocommit = True

    def cursor(self, **kw):
        return _FakeCursor()

    def close(self):
        pass


def _setup_env():
    os.environ.setdefault('DB_USER', 'x')
    os.environ.setdefault('DB_PASSWORD', 'x')
    os.environ.setdefault('DB_HOST', 'localhost')
    os.environ.setdefault('DB_NAME', 'x')
    os.environ.setdefault('DB_PORT', '5432')


class UpdatesHubRoutesTest(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        _setup_env()
        from app import app, db
        cls.app = app
        cls.db = db

    def _client(self, role, group_id=1):
        c = self.app.test_client()
        with c.session_transaction() as s:
            s['user_id'] = 1
            s['username'] = 'tester'
            s['group_id'] = group_id
            s['group_name'] = 'Test'
            s['group_role'] = role
        return c

    def test_routes_registered(self):
        e = {r.endpoint for r in self.app.url_map.iter_rules()}
        expected = (
            'updates_list', 'updates_detail', 'updates_new', 'updates_edit',
            'updates_remove', 'updates_toggle_like', 'updates_comments_json',
            'updates_comment', 'updates_comment_remove',
            'hub_index', 'hub_article', 'hub_submit', 'hub_my_submissions',
            'hub_edit', 'hub_moderation', 'hub_decision', 'hub_toggle_feature',
        )
        for name in expected:
            self.assertIn(name, e, name + ' missing')

    def test_observer_views_updates(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Observer').get('/updates')
            self.assertIn(r.status_code, (200, 302))

    def test_operator_blocked_from_new(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Operator').get('/updates/new')
            self.assertEqual(r.status_code, 403)

    def test_coordinator_can_open_new(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Group Coordinator').get('/updates/new')
            self.assertIn(r.status_code, (200, 302))

    def test_like_toggle_returns_json(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Observer').post('/updates/1/like.json')
            # Returns 404 because our fake says the update doesn't exist,
            # but the route must respond JSON.
            self.assertEqual(r.mimetype, 'application/json')

    def test_comments_json_endpoint_404s_for_missing(self):
        # Without a real update row in the fake, the route 404s.
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Observer').get('/updates/1/comments.json')
            self.assertEqual(r.status_code, 404)

    def test_operator_cannot_moderate_hub(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Operator').get('/hub/moderate')
            self.assertEqual(r.status_code, 403)

    def test_coordinator_can_moderate_hub(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Group Coordinator').get('/hub/moderate')
            self.assertIn(r.status_code, (200, 302))

    def test_hub_index_loads(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Observer').get('/hub')
            self.assertIn(r.status_code, (200, 302))

    def test_member_can_submit_form(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Operator').get('/hub/submit')
            self.assertIn(r.status_code, (200, 302))

    def test_member_my_submissions_page(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Operator').get('/hub/my-submissions')
            self.assertIn(r.status_code, (200, 302))

    def test_empty_search_does_not_500(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Observer').get('/hub?q=nonexistent_search_term_xyz')
            self.assertIn(r.status_code, (200, 302))


if __name__ == '__main__':
    unittest.main()
