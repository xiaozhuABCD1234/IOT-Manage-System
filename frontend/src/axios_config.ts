import axios from "axios";
import Cookies from "js-cookie";
import { useConfigStore } from "@/stores/config";

// 创建一个 axios 实例
const axiosInstance = axios.create({
  baseURL: useConfigStore().effectiveHttpUrl, // 设置基础 URL
  timeout: 10000, // 设置超时时间
  headers: {
    Accept: "application/json", // 默认 Accept 类型
  },
});

// 请求拦截器
axiosInstance.interceptors.request.use(
  (config) => {
    const token = Cookies.get("access_token");
    if (token) {
      // 设置 Authorization 头部

      config.headers["Authorization"] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);

export default axiosInstance;
