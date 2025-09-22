import { defineStore } from "pinia";
import { ref } from "vue";
import type { MarkOnline } from "@/utils/mqtt";
import { createDeviceStateMachine } from "@/utils/deviceState";

export const useMarksStore = defineStore("marks", () => {
  const marks = ref<MarkOnline[]>([]);

  /* 把状态机直接建在 store 内部，生命周期跟随 store */
  const sm = createDeviceStateMachine(marks);

  // 可选：对外暴露只读列表
  const markList = marks;

  return {
    markList,
    onMessage: sm.onMessage, // 组件里直接 markStore.onMessage(data)
    start: sm.start,
    stop: sm.stop,
  };
});
