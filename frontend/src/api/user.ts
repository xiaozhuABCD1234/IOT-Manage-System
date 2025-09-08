// src/api/user.ts
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";

/* ----------------- 枚举 ----------------- */
export enum UserType {
  Root = "root",
  User = "user",
  Admin = "admin",
}

/* ----------------- DTO ----------------- */

/* 登录 */
export interface LoginRequest {
  username: string;
  password: string;
}
export interface LoginResponse {
  access_token: string;
  refresh_token: string;
}

/* 刷新 token */
export interface RefreshTokenRequest {
  refresh_token: string;
}
export interface RefreshTokenResponse {
  access_token: string;
}

/* 创建用户 */
export interface CreateRequest {
  username: string;
  password: string;
  user_type: UserType;
}

/* 更新用户（所有字段可选） */
export type UpdateRequest = Partial<Pick<CreateRequest, "username" | "user_type">>;

/* 用户信息（后端 User 表） */
export interface User {
  id: string;
  username: string;
  user_type: UserType;
  created_at: string;
  updated_at: string;
}

/* 分页查询参数 */
export interface ListParams {
  page?: number;
  per_page?: number;
}

/* ----------------- 常量 ----------------- */
const URLS = {
  users: "/api/v1/users",
  token: "/api/v1/users/token",
  refresh: "/api/v1/users/refresh",
  me: "/api/v1/users/me",
} as const;

/* ----------------- API 方法 ----------------- */
export async function createUser(data: CreateRequest) {
  return request.post<ApiResponse<User>>(URLS.users, data);
}

export async function login(data: LoginRequest) {
  return request.post<ApiResponse<LoginResponse>>(URLS.token, data);
}

export async function refreshToken(data: RefreshTokenRequest) {
  return request.post<ApiResponse<RefreshTokenResponse>>(URLS.refresh, data);
}

export async function getMe() {
  return request.get<ApiResponse<User>>(URLS.me);
}

export async function getUser(id: string) {
  return request.get<ApiResponse<User>>(`${URLS.users}/${id}`);
}

export async function updateUser(id: string, data: UpdateRequest) {
  return request.put<ApiResponse<User>>(`${URLS.users}/${id}`, data);
}

export async function deleteUser(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.users}/${id}`);
}

export async function listUsers(params: ListParams = {}) {
  return request.get<ApiResponse<User[]>>(URLS.users, { params });
}

export * as userApi from "./user";
