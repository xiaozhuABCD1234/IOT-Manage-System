//src/axios_config.ts
import axios from "axios";
import { useConfigStore } from "@/stores/config";
import { ElMessage } from "element-plus";
import { useAuthStore } from "@/stores/auth";


const authStore = useAuthStore();
// 创建一个 axios 实例
const axiosInstance = axios.create({
  baseURL: useConfigStore().effectiveHttpUrl, // 设置基础 URL
  timeout: 10000, // 设置超时时间
  headers: {
    Accept: "application/json", // 默认 Accept 类型
  },
  withCredentials: true, // 允许携带凭证
});

// 请求拦截器
axiosInstance.interceptors.request.use(
  (config) => {
    const token = authStore.accessToken;
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

// 响应拦截器
axiosInstance.interceptors.response.use(
  (response) => {
    // 响应成功，返回响应数据
    return response;
  },
  (error) => {
    // 响应失败，统一处理错误
    const { response } = error;
    if (response) {
      // 服务器返回了状态码
      switch (response.status) {
        case 400:
          ElMessage.error("请求参数错误");
          break;
        case 401:
          ElMessage.error("未授权，请登录");
          authStore.logout();
          break;
        case 403:
          ElMessage.error("禁止访问");
          break;
        case 404:
          ElMessage.error("请求资源未找到");
          break;
        case 500:
          ElMessage.error("服务器内部错误");
          break;
        default:
          ElMessage.error(`服务器错误：${response.status}`);
      }
    } else if (error.message) {
      // 网络错误或请求超时
      ElMessage.error(`请求失败：${error.message}`);
    }
    return Promise.reject(error);
  },
);

export default axiosInstance;
