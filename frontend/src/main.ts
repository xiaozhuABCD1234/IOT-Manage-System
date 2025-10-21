import { createApp } from "vue";
import { createPinia } from "pinia";
import App from "./App.vue";
import router from "./router";
import HighchartsVue from 'highcharts-vue'

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

const pinia = createPinia();
const app = createApp(App);

app.use(pinia);
app.use(router);
app.use(HighchartsVue)

app.mount("#app");
