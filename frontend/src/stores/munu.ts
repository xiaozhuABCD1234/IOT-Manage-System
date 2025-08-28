// src/stores/menu.ts
import { defineStore } from "pinia";
import { computed } from "vue";
import { useRouter } from "vue-router";

export const useMenuStore = defineStore("menu", () => {
  const router = useRouter();

  // 当前高亮索引
  const activeIndex = computed(() => {
    switch (router.currentRoute.value.name) {
      case "home":
        return 0;
      case "map":
        return 1;
      case "tags":
        return 2;
      case "user":
        return 3;
      default:
        return 0;
    }
  });

  // 点击跳转
  function jump(idx: number) {
    const names = ["home", "map", "tags", "user"] as const;
    router.push({ name: names[idx] });
  }

  return { activeIndex, jump };
});
