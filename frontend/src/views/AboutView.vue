<template>
  <div>
    <div v-if="loading">Loading...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else>
      <h2>用户信息</h2>
      <p>ID: {{ user?.id }}</p>
      <p>姓名: {{ user?.name }}</p>
      <p>邮箱: {{ user?.email }}</p>
      <p>权限: {{ user?.permissions }}</p>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref } from "vue";
import axios, { AxiosError } from "axios";
import Cookies from "js-cookie";

interface User {
  id: number;
  name: string;
  email: string;
  permissions: string;
}

export default defineComponent({
  setup() {
    const loading = ref(true);
    const user = ref<User | null>(null);
    const error = ref<string | null>(null);

    const fetchUserData = async () => {
      try {
        // 从 Cookie 中获取 token
        const token = Cookies.get("access_token");
        if (!token) {
          throw new Error("未找到有效的 Token");
        }

        const response = await axios.get<User>("/api/user/auth/me", {
          headers: {
            "Accept": "application/json",
            "Authorization": `Bearer ${token}`,
          },
        });
        // console.log(response.data);
        if (response.status === 200) {
          user.value = response.data;
          console.log(user.value);
        }
      } catch (err) {
        if (err instanceof AxiosError) {
          const errorResponse = err.response;
          if (errorResponse) {
            switch (errorResponse.status) {
              case 401:
                error.value = "请先登录";
                break;
              default:
                error.value = "获取用户信息失败";
            }
          } else {
            error.value = "网络错误";
          }
        } else {
          error.value = (err as Error).message || "未知错误";
        }
      } finally {
        loading.value = false;
      }
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
}
</style>
