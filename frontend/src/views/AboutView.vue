<template>
  <div>
    <el-skeleton v-if="loading" :rows="4" animated />
    <div v-else-if="error" class="error">
      <el-alert :title="error" type="error" show-icon />
    </div>
    <div v-else>
      <h2>用户信息</h2>
      <el-descriptions direction="vertical" :column="1" border>
        <el-descriptions-item label="ID">{{ user?.id }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{
          user?.name
        }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{
          user?.email
        }}</el-descriptions-item>
        <el-descriptions-item label="权限">
          {{ user?.permissions }}
        </el-descriptions-item>
      </el-descriptions>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref } from "vue";
import axios, { AxiosError } from "axios";
import Cookies from "js-cookie";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";

interface User {
  id: number;
  name: string;
  email: string;
  permissions: string[];
}

export default defineComponent({
  setup() {
    const loading = ref(true);
    const user = ref<User | null>(null);
    const error = ref<string>("");
    const router = useRouter();

    const fetchUserData = async () => {
      try {
        const token = Cookies.get("access_token");
        if (!token) {
          throw new Error("未找到有效的 Token");
        }

        const response = await axios.get<User>("/api/user/auth/me", {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        user.value = response.data;
      } catch (err) {
        handleError(err);
      } finally {
        loading.value = false;
      }
    };

    const handleError = (err: unknown) => {
      if (err instanceof AxiosError) {
        const errorResponse = err.response;
        if (errorResponse) {
          const message = errorResponse.data?.message ||
            `状态码：${errorResponse.status}`;
          error.value = message;
          if (errorResponse.status === 401) {
            router.push("/login"); // 跳转登录页
          }
        } else {
          error.value = "网络错误";
        }
      } else {
        error.value = (err as Error).message || "未知错误";
      }
      ElMessage.error(error.value); // 可选：全局提示
    };

    onMounted(() => {
      fetchUserData();
    });

    return {
      loading,
      user,
      error,
    };
  },
});
</script>

<style>
.error {
  color: red;
  font-weight: bold;
  margin: 20px 0;
}
</style>
