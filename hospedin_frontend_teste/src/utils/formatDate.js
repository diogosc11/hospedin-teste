export function formatDate(dateString) {
  if (!dateString) return '—';

  const date = new Date(dateString);
  if (isNaN(date.getTime())) return 'Data inválida';

  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const year = date.getFullYear();

  return `${day}/${month}/${year}`;
}
