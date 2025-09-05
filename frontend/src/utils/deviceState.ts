import type { Ref } from "vue";
import type { MarkOnline } from "@/utils/mqtt";
import { sortMarks } from "./sort";

export function createDeviceStateMachine(marks: Ref<MarkOnline[]>) {
  const timerMap = new Map<string, number>();
  const offlineTimerMap = new Map<string, number>();

  function setOnlineFalse(id: string) {
    const idx = marks.value.findIndex(m => m.id === id);
    if (idx !== -1) marks.value[idx].online = false;
    timerMap.delete(id);
  }

  function removeDevice(id: string) {
    const idx = marks.value.findIndex(m => m.id === id);
    if (idx !== -1) marks.value.splice(idx, 1);
    offlineTimerMap.delete(id);
    timerMap.delete(id);
  }

  function onMessage(data: MarkOnline) {
    if (offlineTimerMap.has(data.id)) clearTimeout(offlineTimerMap.get(data.id)!);
    if (timerMap.has(data.id)) clearTimeout(timerMap.get(data.id)!);

    const idx = marks.value.findIndex(m => m.id === data.id);
    if (idx >= 0) {
      marks.value[idx] = data;
    } else {
      marks.value.push(data);
    }

    timerMap.set(data.id, window.setTimeout(() => setOnlineFalse(data.id), 5000));
    offlineTimerMap.set(data.id, window.setTimeout(() => removeDevice(data.id), 60_000));

    sortMarks(marks.value);   // 即时排序
  }

  let sortTimer: number | undefined;
  function start() {
    sortTimer = window.setInterval(() => sortMarks(marks.value), 5000);
  }
  function stop() {
    if (sortTimer !== undefined) clearInterval(sortTimer);
    timerMap.forEach(clearTimeout);
    offlineTimerMap.forEach(clearTimeout);
  }

  return { onMessage, start, stop };
}
