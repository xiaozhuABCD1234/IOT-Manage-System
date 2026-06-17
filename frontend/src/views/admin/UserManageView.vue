<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import { userApi } from "@/api";
import { UserType } from "@/api/user";
import type { User } from "@/api/user";
import { toast } from "vue-sonner";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Plus, Pencil, Trash2, Search, Users } from "lucide-vue-next";

// State
const users = ref<User[]>([]);
const loading = ref(false);
const searchQuery = ref("");
const currentPage = ref(1);
const totalPages = ref(1);
const totalItems = ref(0);
const perPage = ref(10);

// Current user (to prevent self-deletion)
const currentUserId = ref<string | null>(null);

// Dialog state
const dialogOpen = ref(false);
const dialogMode = ref<"create" | "edit">("create");
const formUsername = ref("");
const formPassword = ref("");
const formUserType = ref<UserType>(UserType.User);
const editingUserId = ref<string | null>(null);
const formSubmitting = ref(false);

// Delete confirmation
const deleteDialogOpen = ref(false);
const deletingUser = ref<User | null>(null);
const deleteSubmitting = ref(false);

// Filtered users
const filteredUsers = computed(() => {
  if (!searchQuery.value) return users.value;
  const q = searchQuery.value.toLowerCase();
  return users.value.filter(
    (u) =>
      u.username.toLowerCase().includes(q) ||
      u.user_type.toLowerCase().includes(q),
  );
});

// Role badge variant
function roleBadgeVariant(type: UserType) {
  switch (type) {
    case UserType.Root:
      return "destructive";
    case UserType.Admin:
      return "default";
    case UserType.User:
      return "secondary";
    default:
      return "outline";
  }
}

function roleLabel(type: UserType) {
  switch (type) {
    case UserType.Root:
      return "超级管理员";
    case UserType.Admin:
      return "管理员";
    case UserType.User:
      return "普通用户";
    default:
      return type;
  }
}

// Fetch users
async function fetchUsers() {
  loading.value = true;
  try {
    const res = await userApi.listUsers({
      page: currentPage.value,
      limit: perPage.value,
    });
    users.value = res.data.data ?? [];
    totalPages.value = res.data.pagination?.totalPages ?? 1;
    totalItems.value = res.data.pagination?.totalItems ?? 0;
  } catch (err) {
    console.error("获取用户列表失败:", err);
    toast.error("获取用户列表失败");
  } finally {
    loading.value = false;
  }
}

// Fetch current user
async function fetchCurrentUser() {
  try {
    const res = await userApi.getMe();
    currentUserId.value = res.data.data.id;
  } catch (err) {
    console.error("获取当前用户信息失败:", err);
  }
}

// Open create dialog
function openCreateDialog() {
  dialogMode.value = "create";
  formUsername.value = "";
  formPassword.value = "";
  formUserType.value = UserType.User;
  editingUserId.value = null;
  dialogOpen.value = true;
}

// Open edit dialog
function openEditDialog(user: User) {
  dialogMode.value = "edit";
  formUsername.value = user.username;
  formPassword.value = "";
  formUserType.value = user.user_type;
  editingUserId.value = user.id;
  dialogOpen.value = true;
}

// Submit form
async function handleSubmit() {
  const username = formUsername.value.trim();

  if (!username) {
    toast.error("请输入用户名");
    return;
  }
  if (username.length < 3) {
    toast.error("用户名至少需要 3 个字符");
    return;
  }
  if (username.length > 32) {
    toast.error("用户名不能超过 32 个字符");
    return;
  }

  if (dialogMode.value === "create") {
    if (!formPassword.value) {
      toast.error("请输入密码");
      return;
    }
    if (formPassword.value.length < 6) {
      toast.error("密码至少需要 6 个字符");
      return;
    }
    if (formPassword.value.length > 64) {
      toast.error("密码不能超过 64 个字符");
      return;
    }
  }

  formSubmitting.value = true;
  try {
    if (dialogMode.value === "create") {
      await userApi.createUser({
        username,
        password: formPassword.value,
        user_type: formUserType.value,
      });
      toast.success("用户创建成功");
    } else if (editingUserId.value) {
      const data: { username?: string; user_type?: UserType } = {};
      data.username = username;
      data.user_type = formUserType.value;
      await userApi.updateUser(editingUserId.value, data);
      toast.success("用户更新成功");
    }
    dialogOpen.value = false;
    await fetchUsers();
  } catch (err) {
    // Error toast already shown by interceptor; log for debugging
    console.error("提交用户表单失败:", err);
  } finally {
    formSubmitting.value = false;
  }
}

// Delete user
function openDeleteDialog(user: User) {
  deletingUser.value = user;
  deleteDialogOpen.value = true;
}

async function handleDelete() {
  if (!deletingUser.value) return;
  deleteSubmitting.value = true;
  try {
    await userApi.deleteUser(deletingUser.value.id);
    toast.success("用户已删除");
    deleteDialogOpen.value = false;
    await fetchUsers();
  } catch (err) {
    // Error toast already shown by interceptor; log for debugging
    console.error("删除用户失败:", err);
  } finally {
    deleteSubmitting.value = false;
  }
}

// Pagination
function goToPage(page: number) {
  if (page < 1 || page > totalPages.value) return;
  currentPage.value = page;
  fetchUsers();
}

onMounted(() => {
  fetchUsers();
  fetchCurrentUser();
});
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold tracking-tight">用户管理</h1>
        <p class="text-muted-foreground">管理系统用户和权限</p>
      </div>
      <Button @click="openCreateDialog">
        <Plus class="mr-2 h-4 w-4" />
        添加用户
      </Button>
    </div>

    <!-- Search -->
    <div class="flex items-center gap-4">
      <div class="relative max-w-sm flex-1">
        <Search class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input v-model="searchQuery" placeholder="搜索用户名或角色..." class="pl-9" />
      </div>
      <div class="text-sm text-muted-foreground">
        共 {{ totalItems }} 个用户
      </div>
    </div>

    <!-- Table -->
    <div class="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead class="w-[80px]">ID</TableHead>
            <TableHead>用户名</TableHead>
            <TableHead>角色</TableHead>
            <TableHead>创建时间</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <template v-if="loading">
            <TableRow v-for="i in 5" :key="i">
              <TableCell><Skeleton class="h-4 w-16" /></TableCell>
              <TableCell><Skeleton class="h-4 w-24" /></TableCell>
              <TableCell><Skeleton class="h-5 w-16" /></TableCell>
              <TableCell><Skeleton class="h-4 w-32" /></TableCell>
              <TableCell><Skeleton class="h-4 w-20" /></TableCell>
            </TableRow>
          </template>
          <template v-else-if="filteredUsers.length === 0">
            <TableRow>
              <TableCell colspan="5" class="h-24 text-center text-muted-foreground">
                <div class="flex flex-col items-center gap-2">
                  <Users class="h-8 w-8 text-muted-foreground/50" />
                  <span>暂无用户数据</span>
                </div>
              </TableCell>
            </TableRow>
          </template>
          <template v-else>
            <TableRow v-for="user in filteredUsers" :key="user.id">
              <TableCell class="font-mono text-xs">{{ user.id.slice(0, 8) }}</TableCell>
              <TableCell class="font-medium">{{ user.username }}</TableCell>
              <TableCell>
                <Badge :variant="roleBadgeVariant(user.user_type)">
                  {{ roleLabel(user.user_type) }}
                </Badge>
              </TableCell>
              <TableCell class="text-muted-foreground">
                {{ new Date(user.created_at).toLocaleDateString("zh-CN") }}
              </TableCell>
              <TableCell class="text-right">
                <div class="flex items-center justify-end gap-1">
                  <Button variant="ghost" size="icon" @click="openEditDialog(user)">
                    <Pencil class="h-4 w-4" />
                  </Button>
                  <Button
                    v-if="user.id !== currentUserId"
                    variant="ghost"
                    size="icon"
                    class="text-destructive hover:text-destructive"
                    @click="openDeleteDialog(user)"
                  >
                    <Trash2 class="h-4 w-4" />
                  </Button>
                </div>
              </TableCell>
            </TableRow>
          </template>
        </TableBody>
      </Table>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="flex items-center justify-between">
      <p class="text-sm text-muted-foreground">
        第 {{ currentPage }} / {{ totalPages }} 页
      </p>
      <div class="flex items-center gap-2">
        <Button
          variant="outline"
          size="sm"
          :disabled="currentPage <= 1"
          @click="goToPage(currentPage - 1)"
        >
          上一页
        </Button>
        <Button
          variant="outline"
          size="sm"
          :disabled="currentPage >= totalPages"
          @click="goToPage(currentPage + 1)"
        >
          下一页
        </Button>
      </div>
    </div>

    <!-- Create/Edit Dialog -->
    <Dialog v-model:open="dialogOpen">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{{ dialogMode === "create" ? "添加用户" : "编辑用户" }}</DialogTitle>
          <DialogDescription>
            {{ dialogMode === "create" ? "创建新的系统用户" : "修改用户信息" }}
          </DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="username" class="text-right">用户名</Label>
            <Input
              id="username"
              v-model="formUsername"
              class="col-span-3"
              placeholder="请输入用户名"
            />
          </div>
          <div v-if="dialogMode === 'create'" class="grid grid-cols-4 items-center gap-4">
            <Label for="password" class="text-right">密码</Label>
            <Input
              id="password"
              v-model="formPassword"
              type="password"
              class="col-span-3"
              placeholder="请输入密码"
            />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="role" class="text-right">角色</Label>
            <Select v-model="formUserType">
              <SelectTrigger class="col-span-3">
                <SelectValue placeholder="选择角色" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem :value="UserType.User">普通用户</SelectItem>
                <SelectItem :value="UserType.Admin">管理员</SelectItem>
                <SelectItem :value="UserType.Root">超级管理员</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="dialogOpen = false">取消</Button>
          <Button :disabled="formSubmitting" @click="handleSubmit">
            {{ formSubmitting ? "提交中..." : "确认" }}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Delete Confirmation -->
    <AlertDialog v-model:open="deleteDialogOpen">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>确认删除</AlertDialogTitle>
          <AlertDialogDescription>
            确定要删除用户「{{ deletingUser?.username }}」吗？此操作不可撤销。
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>取消</AlertDialogCancel>
          <AlertDialogAction
            class="bg-destructive text-white hover:bg-destructive/90"
            :disabled="deleteSubmitting"
            @click="handleDelete"
          >
            {{ deleteSubmitting ? "删除中..." : "删除" }}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>