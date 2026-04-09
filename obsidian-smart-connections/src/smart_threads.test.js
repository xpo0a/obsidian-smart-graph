import test from 'ava';
import { is_thread_storage_path } from './utils/thread_event_filter.js';

test('SmartThreads ignores non-thread file events', (t) => {
  t.false(is_thread_storage_path('Notes/example.md', '.smart-env/smart_threads'));
});

test('SmartThreads handles thread storage file events', (t) => {
  t.true(is_thread_storage_path('.smart-env/smart_threads/thread.json', '.smart-env/smart_threads'));
});

test('SmartThreads still ignores events from other collections', (t) => {
  t.false(is_thread_storage_path('', '.smart-env/smart_threads'));
});
