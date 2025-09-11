// src/api/warning.ts
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";

/* ----------------- 常量 ----------------- */
const URLS = {
  start: "/api/v1/mqtt/warning/:deviceId/start",
  stop: "/api/v1/mqtt/warning/:deviceId/end",
} as const;

/* ----------------- API 方法 ----------------- */

/** 开始告警（纯触发，无请求体） */
export async function startWarning(deviceId: string | number) {
  const url = URLS.start.replace(":deviceId", String(deviceId));
  return request.post<ApiResponse<null>>(url, {});
}

/** 结束告警（纯触发，无请求体） */
export async function endWarning(deviceId: string | number) {
  const url = URLS.stop.replace(":deviceId", String(deviceId));
  return request.post<ApiResponse<null>>(url, {});
}
