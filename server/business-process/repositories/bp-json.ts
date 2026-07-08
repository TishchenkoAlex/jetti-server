export function toJson(value: unknown): string | null {
  if (value == null) return null;
  return JSON.stringify(value);
}

export function parseJsonObject<T>(value: unknown, fallback: T): T {
  if (value == null) return fallback;
  if (typeof value === 'object' && !Array.isArray(value)) return value as T;
  if (typeof value !== 'string' || !value.trim()) return fallback;

  try {
    const parsed = JSON.parse(value);
    return parsed && typeof parsed === 'object' && !Array.isArray(parsed) ? parsed as T : fallback;
  } catch {
    return fallback;
  }
}

export function parseJsonArray<T>(value: unknown, fallback: T[]): T[] {
  if (value == null) return fallback;
  if (Array.isArray(value)) return value as T[];
  if (typeof value !== 'string' || !value.trim()) return fallback;

  try {
    const parsed = JSON.parse(value);
    return Array.isArray(parsed) ? parsed as T[] : fallback;
  } catch {
    return fallback;
  }
}
