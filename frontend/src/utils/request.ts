// src/utils/request.ts
import axios, { type AxiosResponse, type AxiosError } from "axios";
import { toast } from "vue-sonner";
import type { ApiResponse } from "@/types/response";

/* ========== 类型声明 ========== */

/* ========== Axios 实例 ========== */

const service = axios.create({
  baseURL: import.meta.env.VITE_API_BASE as string,
  timeout: 10000,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
});

/* ========== 请求拦截器：携带 token ========== */
service.interceptors.request.use((config) => {
  const token = localStorage.getItem("access_token");
  if (token && token !== "undefined") {
    config.headers.set("Authorization", `Bearer ${token}`);
  }
  return config;
});

service.interceptors.response.use(
  <T>(response: AxiosResponse<ApiResponse<T>>) => {
    const { success, message, error } = response.data;
    if (success) return response;

    const errorMessage = message || error?.message || "请求失败";
    toast.error(errorMessage);
    (response as unknown as { _handled: boolean })._handled = true;
    return Promise.reject(response);
  },

  (error: AxiosError<ApiResponse>) => {
    const { response, message } = error;

    // HTTP 状态码错误处理
    if (response?.status) {
      if (response.status >= 500) {
        toast.error("服务器内部错误");
      } else if (response.status >= 400) {
        toast.error("网络错误");
      } else {
        toast.error("网络异常");
      }
    } else {
      // 网络连接问题
      toast.error("网络连接失败");
    }

    (error as unknown as { _handled: boolean })._handled = true;
    return Promise.reject(error);
  },
);

/* ========== 导出 ========== */
export default service;
