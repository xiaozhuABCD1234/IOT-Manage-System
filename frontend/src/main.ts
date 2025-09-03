import { createApp } from "vue";
import { createPinia } from "pinia";
import App from "./App.vue";
import router from "./router";

import "@/styles/index.css";

// 仅用到的两个自动引入即可
// eslint-disable-next-line @typescript-eslint/no-unused-vars
import { usePreferredDark, useDark } from "@vueuse/core";

// 让 <html> 自动跟随系统深浅色
useDark({
  selector: "html",
  attribute: "class",
  valueDark: "dark",
  valueLight: "",
  storageKey: null, // 完全跟随系统
});

createApp(App).use(createPinia()).use(router).mount("#app");
