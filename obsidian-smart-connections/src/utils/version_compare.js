export function is_server_version_newer(local_version, server_version) {
  if (!server_version || server_version === 'unknown') return false;

  const normalize = (version) => `${version || ''}`
    .trim()
    .replace(/^[^\d]*/, '')
    .replace(/[^\d.].*$/, '');

  const local_parts = normalize(local_version).split('.').map(Number);
  const server_parts = normalize(server_version).split('.').map(Number);
  const max_len = Math.max(local_parts.length, server_parts.length);

  for (let i = 0; i < max_len; i++) {
    const local = local_parts[i] || 0;
    const server = server_parts[i] || 0;
    if (server > local) return true;
    if (server < local) return false;
  }
  return false;
}
