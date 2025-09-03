// src/utils/request.ts
import axios, { type AxiosResponse, type AxiosError } from "axios";
import { toast } from "vue-sonner";

/* ========== 类型声明 ========== */

/** 后端统一返回结构 */
interface ErrorObj {
  code: string;
  message: string;
  details?: unknown;
}

interface PaginationObj {
  currentPage: number;
  totalPages: number;
  totalItems: number;
  itemsPerPage: number;
  has_next: boolean;
  has_prev: boolean;
}

interface ApiResponse<T = unknown> {
  success: boolean;
  data: T;
  message?: string;
  error?: ErrorObj;
  pagination?: PaginationObj;
  timestamp: string;
}

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

/* ========== 响应拦截器 ========== */
service.interceptors.response.use(
  <T>(response: AxiosResponse<ApiResponse<T>>) => {
    const { success, message } = response.data;
    if (success) return response;

    // ② 用 toast 替换 ElMessage
    toast.error(message || "请求失败");
    (response as unknown as { _handled: boolean })._handled = true;
    return Promise.reject(response);
  },

  (error: AxiosError<ApiResponse>) => {
    const { response, message } = error;

    // 404
    if (response?.status === 404) {
      toast.error("无法连接到后端，请稍后再试");
      (error as unknown as { _handled: boolean })._handled = true;
      return Promise.reject(error);
    }

    // 其余错误
    const msg = response?.data?.message || message || "网络异常";
    toast.error(msg);
    (error as unknown as { _handled: boolean })._handled = true;
    return Promise.reject(error);
  },
);

/* ========== 导出 ========== */
export default service;
export type { ApiResponse, PaginationObj, ErrorObj };
