<template>
  <!-- 模板部分保持不变 -->
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

<script setup lang="ts">
import { onMounted, ref } from "vue";
import { userApi } from "@/api/user"; // 导入封装好的 API
import { AxiosError } from "axios"; // 修复 AxiosError 的导入方式

interface User {
  id: number;
  name: string;
  email: string;
  permissions: string[];
}

const loading = ref(true);
const user = ref<User | null>(null);
const error = ref<string>("");

const fetchUserData = async () => {
  try {
    // 直接调用封装好的 API 方法
    const response = await userApi.getCurrentUser();
    console.log(response);
    user.value = response.data; // 修复类型不匹配问题
  } catch (err) {
    handleError(err);
  } finally {
    loading.value = false;
  }
};

const handleError = (err: unknown) => {
  if (err instanceof AxiosError) {
    // 适配后端错误响应格式
    const errorResponse = err.response?.data;
    error.value = errorResponse?.detail || `请求失败：${err.message}`;
  } else {
    error.value = (err as Error).message || "未知错误";
  }
};

onMounted(() => {
  fetchUserData();
});
</script>

<style>
/* 样式保持不变 */
.error {
  color: red;
  font-weight: bold;
  margin: 20px 0;
}
</style>
