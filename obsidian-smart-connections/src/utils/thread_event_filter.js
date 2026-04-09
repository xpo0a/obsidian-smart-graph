export function is_thread_storage_path(path, source_dir) {
  if (!path || !source_dir) return false;
  return path === source_dir || path.startsWith(`${source_dir}/`);
}
