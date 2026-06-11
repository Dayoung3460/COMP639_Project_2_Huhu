"""Smoke tests for Innovation Epic - 3D Terrain Map."""

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
        if 'SELECT geojson' in sql:
            self._last = [_DD(geojson='{"type":"Polygon","coordinates":[[[172.46,-43.65],[172.48,-43.65],[172.48,-43.63],[172.46,-43.63],[172.46,-43.65]]]}')]
        else:
            self._last = []

    def fetchone(self):
        return self._last[0] if (isinstance(self._last, list) and self._last) else _DD()

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


class Map3DTest(unittest.TestCase):

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

    def _super_client(self):
        """A Super Admin session has NO group_id -- they operate cross-group."""
        c = self.app.test_client()
        with c.session_transaction() as s:
            s['user_id'] = 1
            s['username'] = 'admin'
            s['group_role'] = 'Super Admin'
        return c

    def test_routes_registered(self):
        e = {r.endpoint for r in self.app.url_map.iter_rules()}
        for name in ('map3d_index', 'map3d_group_data', 'map3d_line_data',
                     'map3d_operational_area', 'map3d_save_prefs'):
            self.assertIn(name, e, name + ' missing')

    def test_all_in_group_roles_can_view(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            for role in ('Observer', 'Operator', 'Group Coordinator', 'Super Admin'):
                r = self._client(role).get('/map3d')
                self.assertIn(r.status_code, (200, 302),
                              role + ' should reach the map, got ' + str(r.status_code))

    def test_data_endpoint_returns_json(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Observer').get('/map3d/data/group.json?days=30')
            self.assertEqual(r.status_code, 200)
            self.assertEqual(r.mimetype, 'application/json')
            j = r.get_json()
            self.assertIn('assets', j)
            self.assertIn('legend', j)
            self.assertIn('lines', j)

    def test_operational_area_endpoint(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Observer').get('/map3d/data/operational-area.json')
            self.assertEqual(r.status_code, 200)
            j = r.get_json()
            self.assertIn('geojson', j)
            # Our fake returns a real polygon
            self.assertEqual(j['geojson']['type'], 'Polygon')

    def test_save_prefs(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Operator').post(
                '/map3d/prefs', data={'show_vegetation': 'true', 'activity_days': '14'}
            )
            self.assertEqual(r.status_code, 200)
            j = r.get_json()
            self.assertTrue(j['ok'])
            self.assertEqual(j['activity_days'], 14)
            self.assertTrue(j['show_vegetation'])

    def test_save_prefs_clamps_days(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._client('Operator').post(
                '/map3d/prefs', data={'show_vegetation': 'false', 'activity_days': '9999'}
            )
            self.assertEqual(r.json['activity_days'], 365)
            self.assertFalse(r.json['show_vegetation'])

    def test_super_admin_without_group_sees_prompt(self):
        # No session group + no ?group_id= -> the page must render the group
        # picker instead of redirecting to select-group.
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._super_client().get('/map3d')
            self.assertEqual(r.status_code, 200)
            self.assertIn(b'Select a group', r.data)

    def test_super_admin_data_requires_group_id(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._super_client().get('/map3d/data/group.json?days=30')
            self.assertEqual(r.status_code, 400)

    def test_super_admin_data_with_group_id(self):
        with patch.object(self.db, 'get_db', return_value=_FakeConn()):
            r = self._super_client().get('/map3d/data/group.json?days=30&group_id=1')
            self.assertEqual(r.status_code, 200)
            self.assertIn('assets', r.get_json())

    def test_activity_colour_ramp(self):
        from app.map3d import _activity_colour
        # Cool blue when zero, hot red when very high
        self.assertEqual(_activity_colour(0), '#9ec5fe')
        self.assertEqual(_activity_colour(100), '#dc3545')
        # Monotonically warmer
        self.assertNotEqual(_activity_colour(2), _activity_colour(5))


if __name__ == '__main__':
    unittest.main()
