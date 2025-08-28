// src/api/user.ts
import request from "@/utils/request";

/* ----------------- 枚举 ----------------- */
export enum UserType {
  Root = "root",
  User = "user",
  Admin = "admin",
}

/* ----------------- 请求/响应 DTO ----------------- */
// 登录
export interface UserLoginRequest {
  username: string;
  password: string;
}
export interface LoginResponse {
  access_token: string;
  refresh_token: string;
}

// 刷新 token
export interface RefreshTokenRequest {
  refresh_token: string;
}
export interface RefreshTokenResponse {
  access_token: string;
}

// 创建用户
export interface UserCreateRequest {
  username: string;
  password: string;
  user_type: UserType;
}

// 更新用户（字段可选，用 Partial 即可）
export interface UserUpdateRequest {
  username?: string;
  user_type?: UserType;
}

// 用户信息（后端 User 表）
export interface User {
  id: string;
  username: string;
  user_type: UserType;
  created_at: string;
  updated_at: string;
}

// 统一分页响应（复用后端 PaginatedResponse<T>）
export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
  has_next: boolean;
  has_prev: boolean;
}

/* ----------------- API 方法 ----------------- */

/** 创建用户 POST /api/v1/users */
export const createUser = (data: UserCreateRequest) => request.post<User>("/users", data);

/** 用户登录 POST /api/v1/users/token */
export const login = (data: UserLoginRequest) => request.post<LoginResponse>("/users/token", data);

/** 刷新令牌 POST /api/v1/users/refresh */
export const refreshToken = (data: RefreshTokenRequest) =>
  request.post<RefreshTokenResponse>("/users/refresh", data);

/** 获取当前登录用户信息 GET /api/v1/users/me */
export const getMe = () => request.get<User>("/users/me");

/** 根据 id 获取用户详情 GET /api/v1/users/:id */
export const getUser = (id: string) => request.get<User>(`/users/${id}`);

/** 更新用户 PUT /api/v1/users/:id */
export const updateUser = (id: string, data: UserUpdateRequest) =>
  request.put<User>(`/users/${id}`, data);

/** 删除用户 DELETE /api/v1/users/:id */
export const deleteUser = (id: string) => request.delete(`/users/${id}`);

/** 分页查询用户 GET /api/v1/users */
export const listUsers = (params: { page?: number; per_page?: number } = {}) =>
  request.get<PaginatedResponse<User>>("/users", { params });

/* ----------------- 统一导出 ----------------- */
export * as userApi from "./user";
