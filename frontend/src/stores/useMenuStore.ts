import { defineStore } from "pinia";

export const useMenuStore = defineStore("menu", {
  state: () => ({
    activeIndex: "/", // 默认选中的页面路径
  }),
  actions: {
    setActiveIndex(index: string) {
      this.activeIndex = index;
    },
  },
});
