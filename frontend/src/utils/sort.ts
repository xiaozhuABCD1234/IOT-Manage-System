import type { MarkOnline } from "@/utils/mqtt";

export function sortMarks(list: MarkOnline[]) {
  list.sort((a, b) => {
    if (a.online !== b.online) return Number(b.online) - Number(a.online);
    return a.id.localeCompare(b.id);
  });
}
