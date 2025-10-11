<!-- src/components/mark/MarkManagePanel.vue -->
<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { required, helpers } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { toast } from "vue-sonner";
import { Plus, Pen, Trash, Tag } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
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
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import {
  TagsInput,
  TagsInputInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from "@/components/ui/tags-input";
import { createMark, updateMark, deleteMark, listMarks } from "@/api/mark";
import type { MarkResponse, MarkCreateRequest, MarkUpdateRequest } from "@/types/mark";
import DeviceIDSelect from "@/components/device/DeviceIDSelect.vue";
import TypeSelect from "@/components/type/TypeSelect.vue";

/* -------------------------------------------------- */
/* 类型定义                                           */
/* -------------------------------------------------- */
interface CreateFormState {
  device_id: string;
  mark_name: string;
  persist_mqtt: boolean;
  danger_zone_m: number | null;
  mark_type_id: number;
  tags: string[] | undefined;
}

interface UpdateFormState {
  mark_name: string;
  persist_mqtt: boolean;
  danger_zone_m: number | null;
  mark_type_id: number | undefined;
  tags: string[] | undefined;
}

/* -------------------------------------------------- */
/* 标记列表                                           */
/* -------------------------------------------------- */
const marks = ref<MarkResponse[]>([]);
const loading = ref(false);

async function loadMarks() {
  loading.value = true;
  try {
    const response = await listMarks({ page: 1, limit: 1000, preload: true });
    marks.value = response.data.data || [];
  } catch (e: any) {
    if (!e._handled) {
      toast.error("加载标记列表失败", {
        description: e.response?.data?.message || e.message,
      });
    }
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  loadMarks();
});

/* -------------------------------------------------- */
/* 创建标记                                           */
/* -------------------------------------------------- */
const createDialogOpen = ref(false);
const createFormInitial: CreateFormState = {
  device_id: "",
  mark_name: "",
  persist_mqtt: false,
  danger_zone_m: null,
  mark_type_id: 1,
  tags: undefined,
};

const createForm = reactive<CreateFormState>({ ...createFormInitial });

const createRules = {
  device_id: { required: helpers.withMessage("请选择设备ID", required) },
  mark_name: { required: helpers.withMessage("请输入标记名称", required) },
};

const createV$ = useVuelidate(createRules, createForm);
const isCreating = ref(false);

async function handleCreate() {
  const valid = await createV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }

  if (isCreating.value) return;
  isCreating.value = true;

  try {
    const payload = Object.fromEntries(
      Object.entries(createForm).filter(([_, value]) => value !== undefined),
    ) as unknown as MarkCreateRequest;

    await createMark(payload);

    toast.success("标记创建成功");
    createDialogOpen.value = false;
    Object.assign(createForm, createFormInitial);
    createV$.value.$reset();
    await loadMarks();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "创建失败";
      toast.error("创建标记失败", { description: errorMsg });
    }
  } finally {
    isCreating.value = false;
  }
}

/* -------------------------------------------------- */
/* 编辑标记                                           */
/* -------------------------------------------------- */
const editDialogOpen = ref(false);
const editingMark = ref<MarkResponse | null>(null);
const editForm = reactive<UpdateFormState>({
  mark_name: "",
  persist_mqtt: false,
  danger_zone_m: null,
  mark_type_id: undefined,
  tags: undefined,
});

const editRules = {
  mark_name: { required: helpers.withMessage("请输入标记名称", required) },
};

const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);

function openEditDialog(mark: MarkResponse) {
  editingMark.value = mark;
  editForm.mark_name = mark.mark_name;
  editForm.persist_mqtt = mark.persist_mqtt;
  editForm.danger_zone_m = mark.danger_zone_m === -1 ? null : mark.danger_zone_m;
  editForm.mark_type_id = mark.mark_type?.id;
  editForm.tags = (mark.tags ?? []).map((t) => t.tag_name);
  editV$.value.$reset();
  editDialogOpen.value = true;
}

async function handleUpdate() {
  const valid = await editV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }

  if (!editingMark.value || isUpdating.value) return;
  isUpdating.value = true;

  try {
    const payload: MarkUpdateRequest = {};
    Object.entries(editForm).forEach(([k, v]) => {
      if (v != null) {
        (payload as any)[k as keyof MarkUpdateRequest] = v;
      }
    });

    await updateMark(editingMark.value.id, payload);

    toast.success("标记更新成功");
    editDialogOpen.value = false;
    await loadMarks();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新标记失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}

/* -------------------------------------------------- */
/* 删除标记                                           */
/* -------------------------------------------------- */
const isDeleting = ref<Record<string, boolean>>({});

async function handleDelete(id: string) {
  if (isDeleting.value[id]) return;
  isDeleting.value[id] = true;

  try {
    await deleteMark(id);
    toast.success("标记删除成功");
    await loadMarks();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "删除失败";
      toast.error("删除标记失败", { description: errorMsg });
    }
  } finally {
    isDeleting.value[id] = false;
  }
}
</script>

<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题和创建按钮 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Tag class="h-5 w-5" />
              标记管理
            </CardTitle>
            <CardDescription>管理所有标记的信息</CardDescription>
          </div>

          <!-- 创建标记对话框 -->
          <Dialog v-model:open="createDialogOpen">
            <DialogTrigger as-child>
              <Button>
                <Plus class="mr-2 h-4 w-4" />
                新建标记
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[500px]">
              <DialogHeader>
                <DialogTitle>新建标记</DialogTitle>
                <DialogDescription>填写标记信息并提交</DialogDescription>
              </DialogHeader>

              <form @submit.prevent="handleCreate">
                <div class="space-y-4 py-4">
                  <!-- 设备ID -->
                  <div class="flex flex-col gap-2">
                    <Label for="createDeviceId">设备ID</Label>
                    <DeviceIDSelect v-model="createForm.device_id" />
                    <span v-if="createV$.device_id.$error" class="text-destructive text-sm">
                      {{ createV$.device_id.$errors[0].$message }}
                    </span>
                  </div>

                  <!-- 标记名称 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createMarkName">标记名称</Label>
                    <Input
                      id="createMarkName"
                      v-model="createForm.mark_name"
                      placeholder="请输入标记名称"
                      :class="{ 'border-destructive': createV$.mark_name.$error }"
                    />
                    <span v-if="createV$.mark_name.$error" class="text-destructive text-sm">
                      {{ createV$.mark_name.$errors[0].$message }}
                    </span>
                  </div>

                  <!-- 标记类型 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createMarkType">标记类型</Label>
                    <TypeSelect v-model="createForm.mark_type_id" />
                  </div>

                  <!-- 安全距离 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createDangerZone">安全距离（米）</Label>
                    <Input
                      id="createDangerZone"
                      :value="createForm.danger_zone_m ?? ''"
                      type="number"
                      step="0.1"
                      placeholder="留空表示使用类型默认值"
                      @input="
                        ($event.target as HTMLInputElement).value === ''
                          ? (createForm.danger_zone_m = null)
                          : (createForm.danger_zone_m = parseFloat(
                              ($event.target as HTMLInputElement).value,
                            ))
                      "
                    />
                  </div>

                  <!-- 标签 -->
                  <div class="flex flex-col gap-2">
                    <Label>标签</Label>
                    <TagsInput v-model="createForm.tags">
                      <template v-if="createForm.tags && createForm.tags.length">
                        <TagsInputItem v-for="tag in createForm.tags" :key="tag" :value="tag">
                          <TagsInputItemText />
                          <TagsInputItemDelete />
                        </TagsInputItem>
                      </template>
                      <TagsInputInput placeholder="输入标签后按 Enter 添加" />
                    </TagsInput>
                  </div>

                  <!-- 保存历史轨迹 -->
                  <div class="flex items-center gap-2">
                    <Switch id="createPersistMqtt" v-model:checked="createForm.persist_mqtt" />
                    <Label for="createPersistMqtt">保存历史轨迹</Label>
                  </div>
                </div>

                <DialogFooter>
                  <Button type="button" variant="outline" @click="createDialogOpen = false">
                    取消
                  </Button>
                  <Button type="submit" :disabled="isCreating">
                    {{ isCreating ? "创建中..." : "创建" }}
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </CardHeader>
    </Card>

    <!-- 标记列表 -->
    <Card class="flex-1">
      <CardContent class="p-0">
        <ScrollArea class="h-[calc(100vh-16rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>设备ID</TableHead>
                <TableHead>标记名称</TableHead>
                <TableHead>类型</TableHead>
                <TableHead>安全距离</TableHead>
                <TableHead>标签</TableHead>
                <TableHead class="hidden md:table-cell">最后在线</TableHead>
                <TableHead class="hidden md:table-cell">创建时间</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              <TableRow v-if="loading">
                <TableCell colspan="8" class="text-center">加载中...</TableCell>
              </TableRow>

              <TableRow v-else-if="marks.length === 0">
                <TableCell colspan="8" class="text-muted-foreground text-center">
                  暂无标记数据，点击右上角创建新标记
                </TableCell>
              </TableRow>

              <TableRow v-else v-for="mark in marks" :key="mark.id" class="hover:bg-muted/50">
                <TableCell class="font-medium">{{ mark.device_id }}</TableCell>
                <TableCell>{{ mark.mark_name }}</TableCell>
                <TableCell>
                  <span v-if="mark.mark_type">{{ mark.mark_type.type_name }}</span>
                  <span v-else class="text-muted-foreground">-</span>
                </TableCell>
                <TableCell>
                  {{ mark.danger_zone_m !== -1 ? mark.danger_zone_m + "m" : "-" }}
                </TableCell>
                <TableCell>
                  <div class="flex flex-wrap gap-1">
                    <template v-if="mark.tags?.length">
                      <Badge v-for="tag in mark.tags" :key="tag.id" variant="outline">
                        {{ tag.tag_name }}
                      </Badge>
                    </template>
                    <span v-else class="text-muted-foreground">-</span>
                  </div>
                </TableCell>
                <TableCell class="hidden md:table-cell">
                  {{
                    mark.last_online_at
                      ? new Date(mark.last_online_at).toLocaleString()
                      : "从未上线"
                  }}
                </TableCell>
                <TableCell class="hidden md:table-cell">
                  {{ new Date(mark.createdAt).toLocaleString() }}
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 编辑按钮 -->
                    <Button
                      variant="outline"
                      size="icon"
                      @click="openEditDialog(mark)"
                      title="编辑"
                    >
                      <Pen class="h-4 w-4" />
                    </Button>

                    <!-- 删除按钮 -->
                    <AlertDialog>
                      <AlertDialogTrigger as-child>
                        <Button variant="outline" size="icon" class="text-red-500" title="删除">
                          <Trash class="h-4 w-4" />
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle>确认删除标记？</AlertDialogTitle>
                          <AlertDialogDescription>
                            你将永久删除标记 "<strong>{{ mark.mark_name }}</strong
                            >"，此操作无法撤销。
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>取消</AlertDialogCancel>
                          <AlertDialogAction
                            class="bg-red-500 hover:bg-red-600"
                            :disabled="isDeleting[mark.id]"
                            @click="handleDelete(mark.id)"
                          >
                            {{ isDeleting[mark.id] ? "删除中..." : "确认删除" }}
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </ScrollArea>
      </CardContent>
    </Card>

    <!-- 编辑标记对话框 -->
    <Dialog v-model:open="editDialogOpen">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>编辑标记</DialogTitle>
          <DialogDescription>修改标记信息</DialogDescription>
        </DialogHeader>

        <form @submit.prevent="handleUpdate">
          <div class="space-y-4 py-4">
            <!-- 标记名称 -->
            <div class="flex flex-col gap-2">
              <Label for="editMarkName">标记名称</Label>
              <Input
                id="editMarkName"
                v-model="editForm.mark_name"
                placeholder="请输入标记名称"
                :class="{ 'border-destructive': editV$.mark_name.$error }"
              />
              <span v-if="editV$.mark_name.$error" class="text-destructive text-sm">
                {{ editV$.mark_name.$errors[0].$message }}
              </span>
            </div>

            <!-- 标记类型 -->
            <div class="flex flex-col gap-2">
              <Label for="editMarkType">标记类型</Label>
              <TypeSelect v-model="editForm.mark_type_id" />
            </div>

            <!-- 安全距离 -->
            <div class="flex flex-col gap-2">
              <Label for="editDangerZone">安全距离（米）</Label>
              <Input
                id="editDangerZone"
                :value="editForm.danger_zone_m ?? ''"
                type="number"
                step="0.1"
                placeholder="留空表示使用类型默认值"
                @input="
                  ($event.target as HTMLInputElement).value === ''
                    ? (editForm.danger_zone_m = null)
                    : (editForm.danger_zone_m = parseFloat(
                        ($event.target as HTMLInputElement).value,
                      ))
                "
              />
            </div>

            <!-- 标签 -->
            <div class="flex flex-col gap-2">
              <Label>标签</Label>
              <TagsInput v-model="editForm.tags">
                <template v-if="editForm.tags && editForm.tags.length">
                  <TagsInputItem v-for="tag in editForm.tags" :key="tag" :value="tag">
                    <TagsInputItemText />
                    <TagsInputItemDelete />
                  </TagsInputItem>
                </template>
                <TagsInputInput placeholder="输入标签后按 Enter 添加" />
              </TagsInput>
              <span class="text-muted-foreground text-xs">
                留空表示不改动标签；删除全部后按保存可清空标签
              </span>
            </div>

            <!-- 保存历史轨迹 -->
            <div class="flex items-center gap-2">
              <Switch id="editPersistMqtt" v-model:checked="editForm.persist_mqtt" />
              <Label for="editPersistMqtt">保存历史轨迹</Label>
            </div>
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" @click="editDialogOpen = false"> 取消 </Button>
            <Button type="submit" :disabled="isUpdating">
              {{ isUpdating ? "更新中..." : "更新" }}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  </div>
</template>
