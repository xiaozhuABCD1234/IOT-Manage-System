<template>
  <div class="user-info-container">
    <el-skeleton v-if="loading" :rows="1" animated />
    <el-dropdown
      v-else-if="user"
      trigger="click"
      @command="handleCommand"
    >
      <div class="user-info-wrapper">
        <div class="user-avatar">
          <el-avatar :size="36" :src="avatarUrl" />
        </div>
        <div class="user-details">
          <div class="user-name">{{ user.name }}</div>
          <div class="user-permissions">
            <el-tag
              size="small"
              :type="getPermissionTagType(user.permissions)"
            >
              {{ formatPermission(user.permissions) }}
            </el-tag>
          </div>
        </div>
        <el-icon class="el-icon--right">
          <ArrowDown />
        </el-icon>
      </div>
      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item command="profile" :icon="User">
            用户主页
          </el-dropdown-item>
          <el-dropdown-item command="logout" divided :icon="SwitchButton">
            退出登录
          </el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>
    <el-button v-else type="primary" @click="login">登录</el-button>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from "vue";
import { ArrowDown, SwitchButton, User } from "@element-plus/icons-vue";
import { ElMessage } from "element-plus";
import axios, { AxiosError } from "axios";

// 定义用户数据类型
interface User {
  id: number;
  name: string;
  email: string;
  permissions: string;
}

// API 响应类型
interface ApiResponse<T> {
  data?: T;
  error?: string;
  status: number;
}

// 用户数据和加载状态
const user = ref<User | null>(null);
const loading = ref<boolean>(true);
const avatarUrl = ref<string>(
  "https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png",
);

// 权限标签颜色映射
const permissionTagMap: Record<string, string> = {
  admin: "danger",
  manager: "warning",
  user: "success",
  guest: "info",
};

// 格式化权限显示
const formatPermission = (permission: string): string => {
  const map: Record<string, string> = {
    admin: "管理员",
    manager: "经理",
    user: "用户",
    guest: "访客",
  };
  return map[permission] || permission;
};

// 获取权限标签类型
const getPermissionTagType = (permission: string): string => {
  return permissionTagMap[permission] || "";
};

// 获取用户信息
const fetchUserInfo = async (): Promise<void> => {
  try {
    loading.value = true;
    const token = localStorage.getItem("token");

    if (!token) {
      user.value = null;
      return;
    }

    const response = await axios.get<ApiResponse<User>>("/api/user/auth/me", {
      headers: {
        "Accept": "application/json",
        "Authorization": `Bearer ${token}`,
      },
    });

    if (response.data.data) {
      user.value = response.data.data;
    } else {
      throw new Error(response.data.error || "获取用户信息失败");
    }
  } catch (error) {
    const axiosError = error as AxiosError<ApiResponse<User>>;
    if (axiosError.response?.status === 401) {
      // 未认证，清空用户信息
      user.value = null;
      localStorage.removeItem("token");
    } else {
      ElMessage.error(
        "获取用户信息失败: " +
          (axiosError.response?.data?.error || axiosError.message),
      );
    }
  } finally {
    loading.value = false;
  }
};

// 处理下拉菜单命令
const handleCommand = (command: string): void => {
  switch (command) {
    case "profile":
      // 跳转到用户主页
      window.location.href = "/profile";
      break;
    case "logout":
      logout();
      break;
  }
};

// 退出登录
const logout = (): void => {
  localStorage.removeItem("token");
  user.value = null;
  ElMessage.success("已退出登录");
  // 可以添加重定向到登录页的逻辑
  // window.location.href = '/login'
};

// 登录
const login = (): void => {
  // 跳转到登录页
  window.location.href = "/login";
};

// 组件挂载时获取用户信息
onMounted(() => {
  fetchUserInfo();
});

// 如果需要，可以暴露刷新方法
defineExpose({
  refresh: fetchUserInfo,
});
</script>

<style scoped>
.user-info-container {
  height: 100%;
  display: flex;
  align-items: center;
  padding: 0 10px;
  cursor: pointer;
}

.user-info-wrapper {
  display: flex;
  align-items: center;
  height: 100%;
  padding: 0 8px;
}

.user-info-wrapper:hover {
  background-color: var(--el-color-primary-light-9);
}

.user-avatar {
  margin-right: 10px;
}

.user-details {
  display: flex;
  flex-direction: column;
  justify-content: center;
  margin-right: 8px;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  line-height: 1;
  margin-bottom: 4px;
}

.user-permissions {
  display: flex;
  gap: 4px;
}

.el-tag {
  margin-right: 4px;
}

.el-icon--right {
  margin-left: 4px;
  color: var(--el-text-color-secondary);
}
</style>
