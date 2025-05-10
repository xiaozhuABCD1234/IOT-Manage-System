// api/user.ts
import axiosInstance from "@/axios_config";

export const userApi = {
  getCurrentUser: () => axiosInstance.get("/api/user/auth/me"),
};
