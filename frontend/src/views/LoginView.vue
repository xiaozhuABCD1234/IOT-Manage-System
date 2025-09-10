<template>
  <!-- 模板部分保持不变 -->
  <div class="login-container">
    <el-card class="login-card">
      <div class="login-header">
        <h2>用户登录</h2>
      </div>
      
      <!-- 标题下方的水平分隔器 -->
      <div class="login-divider"></div>

      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        @keyup.enter="handleLogin"
      >
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="请输入用户名"
            prefix-icon="User"
            clearable
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            placeholder="请输入密码"
            prefix-icon="Lock"
            show-password
            clearable
          />
        </el-form-item>

        <el-form-item prop="remember">
          <el-checkbox v-model="loginForm.remember">记住我</el-checkbox>
        </el-form-item>
        
        <!-- 登录按钮上方的水平分隔器 -->
        <div class="login-divider"></div>

        <el-form-item>
          <el-button
            type="primary"
            @click="handleLogin"
            :loading="loading"
            style="width: 100%"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, reactive, ref } from "vue";
import type { FormInstance, FormRules } from "element-plus";
import { ElMessage } from "element-plus";
import axios from "axios";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import { authApi } from "@/api/auth";
const authStore = useAuthStore();
const router = useRouter();

// 登录表单引用
const loginFormRef = ref<FormInstance>();

// 登录表单数据
const loginForm = reactive({
  username: "",
  password: "",
  remember: false,
});

// 加载状态
const loading = ref(false);

// 表单验证规则
const loginRules = reactive<FormRules>({
  username: [
    { required: true, message: "请输入用户名", trigger: "blur" },
    { min: 3, max: 20, message: "长度在 3 到 20 个字符", trigger: "blur" },
  ],
  password: [
    { required: true, message: "请输入密码", trigger: "blur" },
    { min: 6, max: 20, message: "长度在 6 到 20 个字符", trigger: "blur" },
  ],
});

// 设置Cookie的函数
const setCookie = (name: string, value: string, days?: number) => {
  let expires = "";
  if (days) {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    expires = "; expires=" + date.toUTCString();
  }
  document.cookie = name + "=" + (value || "") + expires + "; path=/";
};

// 登录方法
const handleLogin = async () => {
  try {
    const valid = await loginFormRef.value?.validate();
    if (!valid) return;

    loading.value = true;
    // 调用登录API
    const response = await authApi.login(
      loginForm.username,
      loginForm.password,
    );
    console.log("登录响应:", response);
    // 处理登录成功
    const { access_token, token_type } = response.data;

    authStore.setToken(access_token);
    // 使用Cookie存储token（根据remember决定有效期）
    if (loginForm.remember) {
      // 记住我 - 设置30天有效期
      setCookie("access_token", access_token, 30);
      setCookie("token_type", token_type, 30);
    } else {
      // 会话Cookie（浏览器关闭后失效）
      setCookie("access_token", access_token);
      setCookie("token_type", token_type);
    }

    ElMessage.success("登录成功");

    // 跳转到仪表盘页面
    const redirectPath = router.currentRoute.value.query.redirect as string;
    await router.push(redirectPath || "/dashboard");
  } catch (error) {
    if (axios.isAxiosError(error)) {
      if (error.response?.status === 401) {
        ElMessage.error("用户名或密码错误");
      } else {
        ElMessage.error(`登录失败: ${error.message}`);
      }
    } else {
      ElMessage.error("发生未知错误");
      console.error(error);
    }
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  useAuthStore().logout();
});
</script>

<style scoped>
/* 样式保持不变 */
.login-container {
  height: 100vh;
  width: 100vw;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(to right, #f0f0f0, #3498db);
}

.login-card {
  width: 400px;
  padding: 30px 35px 15px 35px;
  border-radius: 8px;
  box-shadow: 0 0 25px rgba(0, 0, 0, 0.1);
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.login-header h2 {
  color: #333;
  font-size: 24px;
  font-weight: 500;
}

.login-footer {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
}

/* 登录页面水平分隔器样式 */
.login-divider {
  height: 1px;
  background: linear-gradient(to right, rgba(52, 152, 219, 0.1), rgba(52, 152, 219, 0.8), rgba(52, 152, 219, 0.1));
  margin: 15px 0;
  border-radius: 1px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .login-card {
    width: 90%;
    max-width: 400px;
    padding: 20px 25px 10px 25px;
  }
  
  .login-divider {
    margin: 10px 0;
  }
}
</style>
