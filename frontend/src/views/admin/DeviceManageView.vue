<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import { markApi, typeApi } from "@/api";
import type { MarkResponse, MarkTypeResponse } from "@/types/mark";
import type { MarkCreateRequest, MarkUpdateRequest } from "@/types/mark";
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
import { Switch } from "@/components/ui/switch";
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
import {
  TagsInput,
  TagsInputInput,
  TagsInputItem,
  TagsInputItemText,
  TagsInputItemDelete,
} from "@/components/ui/tags-input";
import { Plus, Pencil, Trash2, Search, Package } from "lucide-vue-next";

// State
const marks = ref<MarkResponse[]>([]);
const types = ref<MarkTypeResponse[]>([]);
const loading = ref(false);
const searchQuery = ref("");
const currentPage = ref(1);
const totalPages = ref(1);
const totalItems = ref(0);
const perPage = ref(10);

// Dialog state
const dialogOpen = ref(false);
const dialogMode = ref<"create" | "edit">("create");
const formDeviceId = ref("");
const formMarkName = ref("");
const formTypeId = ref<string>("");
const formTags = ref<string[]>([]);
const formMqttTopic = ref("");
const formPersistMqtt = ref(false);
const formDangerZone = ref<string>("");
const editingMarkId = ref<string | null>(null);
const formSubmitting = ref(false);

// Delete confirmation
const deleteDialogOpen = ref(false);
const deletingMark = ref<MarkResponse | null>(null);
const deleteSubmitting = ref(false);

// Filtered marks
const filteredMarks = computed(() => {
  if (!searchQuery.value) return marks.value;
  const q = searchQuery.value.toLowerCase();
  return marks.value.filter(
    (m) =>
      m.device_id.toLowerCase().includes(q) ||
      m.mark_name.toLowerCase().includes(q),
  );
});

// Type badge variant
function typeBadgeVariant(typeName: string | null) {
  if (!typeName) return "outline";
  switch (typeName) {
    case "UWB":
      return "default";
    case "RTK":
      return "destructive";
    default:
      return "secondary";
  }
}

// Fetch marks
async function fetchMarks() {
  loading.value = true;
  try {
    const res = await markApi.listMarks({
      page: currentPage.value,
      limit: perPage.value,
      preload: true,
    });
    marks.value = (res.data.data as unknown as MarkResponse[]) ?? [];
    totalPages.value = res.data.pagination?.totalPages ?? 1;
    totalItems.value = res.data.pagination?.totalItems ?? 0;
  } catch {
    toast.error("获取设备列表失败");
  } finally {
    loading.value = false;
  }
}

// Fetch types
async function fetchTypes() {
  try {
    const res = await typeApi.listMarkTypes({ limit: 100 });
    types.value = res.data.data ?? [];
  } catch (err) {
    console.error("获取设备类型失败:", err);
    toast.error("获取设备类型失败");
  }
}

// Open create dialog
function openCreateDialog() {
  dialogMode.value = "create";
  formDeviceId.value = "";
  formMarkName.value = "";
  formTypeId.value = "";
  formTags.value = [];
  formMqttTopic.value = "";
  formPersistMqtt.value = false;
  formDangerZone.value = "";
  editingMarkId.value = null;
  dialogOpen.value = true;
}

// Open edit dialog
function openEditDialog(mark: MarkResponse) {
  dialogMode.value = "edit";
  formDeviceId.value = mark.device_id;
  formMarkName.value = mark.mark_name;
  formTypeId.value = mark.mark_type ? String(mark.mark_type.id) : "";
  formTags.value = mark.tags.map((t) => t.tag_name);
  formMqttTopic.value = mark.mqtt_topic.join(", ");
  formPersistMqtt.value = mark.persist_mqtt;
  formDangerZone.value = mark.danger_zone_m != null ? String(mark.danger_zone_m) : "";
  editingMarkId.value = mark.id;
  dialogOpen.value = true;
}

// Submit form
async function handleSubmit() {
  const device_id = formDeviceId.value.trim();
  const mark_name = formMarkName.value.trim();

  if (!device_id) {
    toast.error("请输入设备ID");
    return;
  }
  if (!mark_name) {
    toast.error("请输入设备名称");
    return;
  }

  formSubmitting.value = true;
  try {
    if (dialogMode.value === "create") {
      const data: MarkCreateRequest = {
        device_id,
        mark_name,
      };
      if (formTypeId.value) {
        data.mark_type_id = Number(formTypeId.value);
      }
      if (formTags.value.length > 0) {
        data.tags = formTags.value;
      }
      if (formMqttTopic.value.trim()) {
        data.mqtt_topic = formMqttTopic.value
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean);
      }
      data.persist_mqtt = formPersistMqtt.value;
      if (formDangerZone.value.trim()) {
        data.danger_zone_m = Number(formDangerZone.value);
      }
      await markApi.createMark(data);
      toast.success("设备创建成功");
    } else if (editingMarkId.value) {
      const data: MarkUpdateRequest = {};
      data.mark_name = mark_name;
      if (formTypeId.value) {
        data.mark_type_id = Number(formTypeId.value);
      }
      data.tags = formTags.value;
      if (formMqttTopic.value.trim()) {
        data.mqtt_topic = formMqttTopic.value
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean);
      } else {
        data.mqtt_topic = [];
      }
      data.persist_mqtt = formPersistMqtt.value;
      if (formDangerZone.value.trim()) {
        data.danger_zone_m = Number(formDangerZone.value);
      }
      await markApi.updateMark(editingMarkId.value, data);
      toast.success("设备更新成功");
    }
    dialogOpen.value = false;
    await fetchMarks();
  } catch (err) {
    // Error toast already shown by interceptor; log for debugging
    console.error("提交设备表单失败:", err);
  } finally {
    formSubmitting.value = false;
  }
}

// Delete mark
function openDeleteDialog(mark: MarkResponse) {
  deletingMark.value = mark;
  deleteDialogOpen.value = true;
}

async function handleDelete() {
  if (!deletingMark.value) return;
  deleteSubmitting.value = true;
  try {
    await markApi.deleteMark(deletingMark.value.id);
    toast.success("设备已删除");
    deleteDialogOpen.value = false;
    await fetchMarks();
  } catch (err) {
    // Error toast already shown by interceptor; log for debugging
    console.error("删除设备失败:", err);
  } finally {
    deleteSubmitting.value = false;
  }
}

// Pagination
function goToPage(page: number) {
  if (page < 1 || page > totalPages.value) return;
  currentPage.value = page;
  fetchMarks();
}

onMounted(() => {
  fetchMarks();
  fetchTypes();
});
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold tracking-tight">设备管理</h1>
        <p class="text-muted-foreground">管理设备标记、类型和标签</p>
      </div>
      <Button @click="openCreateDialog">
        <Plus class="mr-2 h-4 w-4" />
        添加设备
      </Button>
    </div>

    <!-- Search -->
    <div class="flex items-center gap-4">
      <div class="relative max-w-sm flex-1">
        <Search class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input v-model="searchQuery" placeholder="搜索设备ID或名称..." class="pl-9" />
      </div>
      <div class="text-sm text-muted-foreground">
        共 {{ totalItems }} 个设备
      </div>
    </div>

    <!-- Table -->
    <div class="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead class="w-[120px]">设备ID</TableHead>
            <TableHead>设备名称</TableHead>
            <TableHead>类型</TableHead>
            <TableHead>标签</TableHead>
            <TableHead>MQTT持久化</TableHead>
            <TableHead>最后在线</TableHead>
            <TableHead>创建时间</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <template v-if="loading">
            <TableRow v-for="i in 5" :key="i">
              <TableCell><Skeleton class="h-4 w-20" /></TableCell>
              <TableCell><Skeleton class="h-4 w-24" /></TableCell>
              <TableCell><Skeleton class="h-5 w-16" /></TableCell>
              <TableCell><Skeleton class="h-4 w-20" /></TableCell>
              <TableCell><Skeleton class="h-5 w-12" /></TableCell>
              <TableCell><Skeleton class="h-4 w-28" /></TableCell>
              <TableCell><Skeleton class="h-4 w-28" /></TableCell>
              <TableCell><Skeleton class="h-4 w-20" /></TableCell>
            </TableRow>
          </template>
          <template v-else-if="filteredMarks.length === 0">
            <TableRow>
              <TableCell colspan="8" class="h-24 text-center text-muted-foreground">
                <div class="flex flex-col items-center gap-2">
                  <Package class="h-8 w-8 text-muted-foreground/50" />
                  <span>暂无设备数据</span>
                </div>
              </TableCell>
            </TableRow>
          </template>
          <template v-else>
            <TableRow v-for="mark in filteredMarks" :key="mark.id">
              <TableCell class="font-mono text-xs">{{ mark.device_id }}</TableCell>
              <TableCell class="font-medium">{{ mark.mark_name }}</TableCell>
              <TableCell>
                <Badge :variant="typeBadgeVariant(mark.mark_type?.type_name ?? null)">
                  {{ mark.mark_type?.type_name ?? "未分类" }}
                </Badge>
              </TableCell>
              <TableCell>
                <div v-if="mark.tags.length > 0" class="flex flex-wrap gap-1">
                  <Badge v-for="tag in mark.tags" :key="tag.id" variant="outline" class="text-xs">
                    {{ tag.tag_name }}
                  </Badge>
                </div>
                <span v-else class="text-muted-foreground text-xs">-</span>
              </TableCell>
              <TableCell>
                <Badge :variant="mark.persist_mqtt ? 'default' : 'secondary'">
                  {{ mark.persist_mqtt ? "是" : "否" }}
                </Badge>
              </TableCell>
              <TableCell class="text-muted-foreground text-xs">
                {{ mark.last_online_at ? new Date(mark.last_online_at).toLocaleString("zh-CN") : "-" }}
              </TableCell>
              <TableCell class="text-muted-foreground text-xs">
                {{ new Date(mark.created_at).toLocaleDateString("zh-CN") }}
              </TableCell>
              <TableCell class="text-right">
                <div class="flex items-center justify-end gap-1">
                  <Button variant="ghost" size="icon" @click="openEditDialog(mark)">
                    <Pencil class="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    class="text-destructive hover:text-destructive"
                    @click="openDeleteDialog(mark)"
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
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>{{ dialogMode === "create" ? "添加设备" : "编辑设备" }}</DialogTitle>
          <DialogDescription>
            {{ dialogMode === "create" ? "创建新的设备标记" : "修改设备信息" }}
          </DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="device_id" class="text-right">设备ID</Label>
            <Input
              id="device_id"
              v-model="formDeviceId"
              class="col-span-3"
              placeholder="请输入设备ID"
              :disabled="dialogMode === 'edit'"
            />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="mark_name" class="text-right">设备名称</Label>
            <Input
              id="mark_name"
              v-model="formMarkName"
              class="col-span-3"
              placeholder="请输入设备名称"
            />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="mark_type" class="text-right">设备类型</Label>
            <Select v-model="formTypeId">
              <SelectTrigger class="col-span-3">
                <SelectValue placeholder="选择类型" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem
                  v-for="t in types"
                  :key="t.id"
                  :value="String(t.id)"
                >
                  {{ t.type_name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label class="text-right">标签</Label>
            <div class="col-span-3">
              <TagsInput v-model="formTags" class="w-full">
                <TagsInputItem
                  v-for="tag in formTags"
                  :key="tag"
                  :value="tag"
                >
                  <TagsInputItemText />
                  <TagsInputItemDelete />
                </TagsInputItem>
                <TagsInputInput placeholder="输入标签后回车" />
              </TagsInput>
            </div>
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="mqtt_topic" class="text-right">MQTT主题</Label>
            <Input
              id="mqtt_topic"
              v-model="formMqttTopic"
              class="col-span-3"
              placeholder="逗号分隔多个主题"
            />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="persist_mqtt" class="text-right">MQTT持久化</Label>
            <div class="col-span-3 flex items-center gap-2">
              <Switch id="persist_mqtt" v-model:checked="formPersistMqtt" />
              <span class="text-sm text-muted-foreground">
                {{ formPersistMqtt ? "开启" : "关闭" }}
              </span>
            </div>
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="danger_zone" class="text-right">危险区域(m)</Label>
            <Input
              id="danger_zone"
              v-model="formDangerZone"
              type="number"
              class="col-span-3"
              placeholder="可选，留空使用类型默认值"
            />
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
            确定要删除设备「{{ deletingMark?.mark_name }}」吗？此操作不可撤销。
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