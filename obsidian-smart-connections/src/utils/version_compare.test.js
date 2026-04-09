import test from 'ava';
import { is_server_version_newer } from './version_compare.js';

test('ignores v-prefix equality', t => {
  t.false(is_server_version_newer('3.0.80', 'v3.0.80'));
});

test('returns true when server version is newer', t => {
  t.true(is_server_version_newer('3.0.80', 'v3.0.81'));
});

test('returns false when local version is newer', t => {
  t.false(is_server_version_newer('999.0.0', 'v3.0.81'));
});
