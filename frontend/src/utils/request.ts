// src/utils/request.ts
import axios, { type AxiosResponse, type AxiosError } from "axios";
import { toast } from "vue-sonner";
import type { ApiResponse } from "@/types/response";

/* ========== 类型声明 ========== */

/* ========== 友好错误提示 ========== */
const VALIDATION_HINTS: Record<string, string> = {
  Username: "用户名",
  Password: "密码",
  UserType: "用户类型",
  user_type: "用户类型",
};

function friendlyError(raw: string): string {
  // Go 结构体验证错误: Key: 'Xxx' Error:Field validation for 'Field' failed on 'tag'
  const goMatch = raw.match(
    /Field validation for '(\w+)' failed on the '(\w+)'/,
  );
  if (goMatch) {
    const field = VALIDATION_HINTS[goMatch[1]] || goMatch[1];
    const tag = goMatch[2];
    const hints: Record<string, string> = {
      required: `${field}不能为空`,
      min: `${field}长度不符合要求`,
      max: `${field}长度不符合要求`,
      email: `${field}格式不正确`,
      oneof: `${field}取值不正确`,
    };
    return hints[tag] || raw;
  }

  // "请求参数错误: ..." → 只保留后半段
  if (raw.startsWith("请求参数错误")) {
    const colon = raw.indexOf(": ");
    if (colon !== -1 && colon + 2 < raw.length) {
      const rest = raw.slice(colon + 2);
      // 如果后半段仍是 Go 错误，递归处理
      if (/Field validation/.test(rest)) return friendlyError(rest);
      return rest;
    }
  }

  return raw;
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

service.interceptors.response.use(
  <T>(response: AxiosResponse<ApiResponse<T>>) => {
    const { success, message, error } = response.data;
    if (success) return response;

    const raw = message || error?.message || "请求失败";
    toast.error(friendlyError(raw));
    (response as unknown as { _handled: boolean })._handled = true;
    return Promise.reject(response);
  },

  (error: AxiosError<ApiResponse>) => {
    const body = error.response?.data as ApiResponse | undefined;
    // 优先取后端返回的 message
    if (body?.message || body?.error?.message) {
      const raw = body.message || body.error!.message;
      toast.error(friendlyError(raw));
    } else if (error.response?.status) {
      const status = error.response.status;
      if (status >= 500) {
        toast.error("服务器内部错误，请稍后重试");
      } else if (status === 404) {
        toast.error("请求的资源不存在");
      } else if (status === 401) {
        toast.error("登录已过期，请重新登录");
      } else if (status >= 400) {
        toast.error("请求参数有误");
      }
    } else {
      toast.error("网络连接失败，请检查网络");
    }

    (error as unknown as { _handled: boolean })._handled = true;
    return Promise.reject(error);
  },
);

/* ========== 导出 ========== */
export default service;
