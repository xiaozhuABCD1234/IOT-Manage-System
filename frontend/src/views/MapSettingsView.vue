<!-- src/views/MapSettingsView.vue -->
<script setup lang="ts">
import { ref, reactive, onMounted, computed } from "vue";
import { required, helpers } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { toast } from "vue-sonner";
import { Plus, Pen, Trash, Map, Image as ImageIcon, Eye } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
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
import { customMapApi } from "@/api";
import type { CustomMapResp, CustomMapCreateReq, CustomMapUpdateReq } from "@/types/customMap";

/* -------------------------------------------------- */
/* 类型定义                                           */
/* -------------------------------------------------- */
interface FormState {
  map_name: string;
  image_base64?: string;
  image_ext?: ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp";
  x_min: number | string;
  x_max: number | string;
  y_min: number | string;
  y_max: number | string;
  center_x: number | string;
  center_y: number | string;
  scale_ratio: number | string;
  description?: string;
}

/* -------------------------------------------------- */
/* 地图列表                                           */
/* -------------------------------------------------- */
const customMaps = ref<CustomMapResp[]>([]);
const loading = ref(false);

async function loadCustomMaps() {
  loading.value = true;
  try {
    const response = await customMapApi.listCustomMaps();
    customMaps.value = response.data.data || [];
  } catch (e: any) {
    if (!e._handled) {
      toast.error("加载地图列表失败", {
        description: e.response?.data?.message || e.message,
      });
    }
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  loadCustomMaps();
});

/* -------------------------------------------------- */
/* 图片上传处理                                       */
/* -------------------------------------------------- */
function getImageExtension(filename: string): ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp" {
  const ext = filename.toLowerCase().split(".").pop() || "";
  const extMap: Record<string, ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp"> = {
    jpg: ".jpg",
    jpeg: ".jpeg",
    png: ".png",
    gif: ".gif",
    webp: ".webp",
  };
  return extMap[ext] || ".png";
}

function handleImageUpload(event: Event, form: FormState) {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];

  if (!file) return;

  // 检查文件类型
  const allowedTypes = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"];
  if (!allowedTypes.includes(file.type)) {
    toast.error("不支持的图片格式", {
      description: "请上传 JPG, JPEG, PNG, GIF 或 WEBP 格式的图片",
    });
    return;
  }

  // 检查文件大小（限制为 5MB）
  const maxSize = 5 * 1024 * 1024; // 5MB
  if (file.size > maxSize) {
    toast.error("图片文件过大", {
      description: "请上传小于 5MB 的图片",
    });
    return;
  }

  const reader = new FileReader();
  reader.onload = (e) => {
    const base64 = e.target?.result as string;
    // 移除 data:image/xxx;base64, 前缀
    const base64Data = base64.split(",")[1];
    form.image_base64 = base64Data;
    form.image_ext = getImageExtension(file.name);
    toast.success("图片上传成功");
  };
  reader.onerror = () => {
    toast.error("图片读取失败");
  };
  reader.readAsDataURL(file);
}

/* -------------------------------------------------- */
/* 创建地图                                           */
/* -------------------------------------------------- */
const createDialogOpen = ref(false);
const createFormInitial: FormState = {
  map_name: "",
  image_base64: undefined,
  image_ext: undefined,
  x_min: 0,
  x_max: 100,
  y_min: 0,
  y_max: 100,
  center_x: 50,
  center_y: 50,
  scale_ratio: 1.0,
  description: "",
};

const createForm = reactive<FormState>({ ...createFormInitial });

// 自定义验证器
const isValidNumber = (value: any) => {
  if (value === undefined || value === null) return false;
  if (value === 0 || value === "0") return true;
  if (value === "" || (typeof value === "string" && value.trim() === "")) return false;
  const num = Number(value);
  return !isNaN(num) && isFinite(num);
};

const createRules = {
  map_name: { required: helpers.withMessage("请输入地图名称", required) },
  x_min: { isValidNumber: helpers.withMessage("请输入有效的X最小值", isValidNumber) },
  x_max: { isValidNumber: helpers.withMessage("请输入有效的X最大值", isValidNumber) },
  y_min: { isValidNumber: helpers.withMessage("请输入有效的Y最小值", isValidNumber) },
  y_max: { isValidNumber: helpers.withMessage("请输入有效的Y最大值", isValidNumber) },
  center_x: { isValidNumber: helpers.withMessage("请输入有效的中心X坐标", isValidNumber) },
  center_y: { isValidNumber: helpers.withMessage("请输入有效的中心Y坐标", isValidNumber) },
  scale_ratio: { isValidNumber: helpers.withMessage("请输入有效的缩放比例", isValidNumber) },
};

const createV$ = useVuelidate(createRules, createForm);
const isCreating = ref(false);

const createImagePreview = computed(() => {
  if (createForm.image_base64) {
    return `data:image/${createForm.image_ext?.replace(".", "")};base64,${createForm.image_base64}`;
  }
  return null;
});

async function handleCreate() {
  const valid = await createV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }

  if (isCreating.value) return;
  isCreating.value = true;

  try {
    const data: CustomMapCreateReq = {
      map_name: createForm.map_name,
      image_base64: createForm.image_base64,
      image_ext: createForm.image_ext,
      x_min: Number(createForm.x_min),
      x_max: Number(createForm.x_max),
      y_min: Number(createForm.y_min),
      y_max: Number(createForm.y_max),
      center_x: Number(createForm.center_x),
      center_y: Number(createForm.center_y),
      scale_ratio: Number(createForm.scale_ratio),
      description: createForm.description || undefined,
    };

    await customMapApi.createCustomMap(data);
    toast.success("地图创建成功");
    createDialogOpen.value = false;
    Object.assign(createForm, createFormInitial);
    createV$.value.$reset();
    await loadCustomMaps();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "创建失败";
      toast.error("创建地图失败", { description: errorMsg });
    }
  } finally {
    isCreating.value = false;
  }
}

/* -------------------------------------------------- */
/* 编辑地图                                           */
/* -------------------------------------------------- */
const editDialogOpen = ref(false);
const editingMap = ref<CustomMapResp | null>(null);
const editForm = reactive<FormState>({
  map_name: "",
  image_base64: undefined,
  image_ext: undefined,
  x_min: "",
  x_max: "",
  y_min: "",
  y_max: "",
  center_x: "",
  center_y: "",
  scale_ratio: "",
  description: "",
});

const editRules = {
  map_name: { required: helpers.withMessage("请输入地图名称", required) },
  x_min: { isValidNumber: helpers.withMessage("请输入有效的X最小值", isValidNumber) },
  x_max: { isValidNumber: helpers.withMessage("请输入有效的X最大值", isValidNumber) },
  y_min: { isValidNumber: helpers.withMessage("请输入有效的Y最小值", isValidNumber) },
  y_max: { isValidNumber: helpers.withMessage("请输入有效的Y最大值", isValidNumber) },
  center_x: { isValidNumber: helpers.withMessage("请输入有效的中心X坐标", isValidNumber) },
  center_y: { isValidNumber: helpers.withMessage("请输入有效的中心Y坐标", isValidNumber) },
  scale_ratio: { isValidNumber: helpers.withMessage("请输入有效的缩放比例", isValidNumber) },
};

const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);

const editImagePreview = computed(() => {
  if (editForm.image_base64) {
    return `data:image/${editForm.image_ext?.replace(".", "")};base64,${editForm.image_base64}`;
  }
  if (editingMap.value?.image_url) {
    return editingMap.value.image_url;
  }
  return null;
});

function openEditDialog(map: CustomMapResp) {
  editingMap.value = map;
  editForm.map_name = map.map_name;
  editForm.x_min = map.x_min;
  editForm.x_max = map.x_max;
  editForm.y_min = map.y_min;
  editForm.y_max = map.y_max;
  editForm.center_x = map.center_x;
  editForm.center_y = map.center_y;
  editForm.scale_ratio = map.scale_ratio;
  editForm.description = map.description;
  editForm.image_base64 = undefined;
  editForm.image_ext = undefined;
  editV$.value.$reset();
  editDialogOpen.value = true;
}

async function handleUpdate() {
  const valid = await editV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }

  if (!editingMap.value || isUpdating.value) return;
  isUpdating.value = true;

  try {
    const data: CustomMapUpdateReq = {
      map_name: editForm.map_name,
      x_min: Number(editForm.x_min),
      x_max: Number(editForm.x_max),
      y_min: Number(editForm.y_min),
      y_max: Number(editForm.y_max),
      center_x: Number(editForm.center_x),
      center_y: Number(editForm.center_y),
      scale_ratio: Number(editForm.scale_ratio),
      description: editForm.description || undefined,
    };

    // 只有在上传了新图片时才包含图片数据
    if (editForm.image_base64) {
      data.image_base64 = editForm.image_base64;
      data.image_ext = editForm.image_ext;
    }

    await customMapApi.updateCustomMap(editingMap.value.id, data);
    toast.success("地图更新成功");
    editDialogOpen.value = false;
    await loadCustomMaps();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新地图失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}

/* -------------------------------------------------- */
/* 删除地图                                           */
/* -------------------------------------------------- */
const isDeleting = ref<Record<string, boolean>>({});

async function handleDelete(id: string) {
  if (isDeleting.value[id]) return;
  isDeleting.value[id] = true;

  try {
    await customMapApi.deleteCustomMap(id);
    toast.success("地图删除成功");
    await loadCustomMaps();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "删除失败";
      toast.error("删除地图失败", { description: errorMsg });
    }
  } finally {
    isDeleting.value[id] = false;
  }
}

/* -------------------------------------------------- */
/* 预览地图                                           */
/* -------------------------------------------------- */
const previewDialogOpen = ref(false);
const previewMap = ref<CustomMapResp | null>(null);

function openPreviewDialog(map: CustomMapResp) {
  previewMap.value = map;
  previewDialogOpen.value = true;
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
              <Map class="h-5 w-5" />
              地图管理
            </CardTitle>
            <CardDescription>管理自定义地图配置</CardDescription>
          </div>

          <!-- 创建地图对话框 -->
          <Dialog v-model:open="createDialogOpen">
            <DialogTrigger as-child>
              <Button>
                <Plus class="mr-2 h-4 w-4" />
                新建地图
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[600px]">
              <DialogHeader>
                <DialogTitle>新建地图</DialogTitle>
                <DialogDescription>填写地图配置信息并上传地图图片</DialogDescription>
              </DialogHeader>

              <form @submit.prevent="handleCreate">
                <ScrollArea class="max-h-[calc(100vh-16rem)]">
                  <div class="space-y-4 px-1 py-4">
                    <!-- 地图名称 -->
                    <div class="flex flex-col gap-2">
                      <Label for="createMapName">地图名称</Label>
                      <Input
                        id="createMapName"
                        v-model="createForm.map_name"
                        placeholder="例如：一楼平面图"
                        :class="{ 'border-destructive': createV$.map_name.$error }"
                      />
                      <span v-if="createV$.map_name.$error" class="text-destructive text-sm">
                        {{ createV$.map_name.$errors[0].$message }}
                      </span>
                    </div>

                    <!-- 地图描述 -->
                    <div class="flex flex-col gap-2">
                      <Label for="createDescription">描述（可选）</Label>
                      <Textarea
                        id="createDescription"
                        v-model="createForm.description"
                        placeholder="地图描述..."
                        rows="2"
                      />
                    </div>

                    <!-- 图片上传 -->
                    <div class="flex flex-col gap-2">
                      <Label for="createImage">地图图片（可选）</Label>
                      <Input
                        id="createImage"
                        type="file"
                        accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
                        @change="(e: Event) => handleImageUpload(e, createForm)"
                      />
                      <span class="text-muted-foreground text-xs">
                        支持 JPG, PNG, GIF, WEBP 格式，最大 5MB
                      </span>
                      <!-- 图片预览 -->
                      <div v-if="createImagePreview" class="mt-2">
                        <img
                          :src="createImagePreview"
                          alt="预览"
                          class="max-h-40 rounded border object-contain"
                        />
                      </div>
                    </div>

                    <!-- 坐标范围 -->
                    <div class="grid grid-cols-2 gap-4">
                      <div class="flex flex-col gap-2">
                        <Label for="createXMin">X 最小值</Label>
                        <Input
                          id="createXMin"
                          v-model="createForm.x_min"
                          type="number"
                          step="0.01"
                          placeholder="0"
                          :class="{ 'border-destructive': createV$.x_min.$error }"
                        />
                        <span v-if="createV$.x_min.$error" class="text-destructive text-sm">
                          {{ createV$.x_min.$errors[0].$message }}
                        </span>
                      </div>

                      <div class="flex flex-col gap-2">
                        <Label for="createXMax">X 最大值</Label>
                        <Input
                          id="createXMax"
                          v-model="createForm.x_max"
                          type="number"
                          step="0.01"
                          placeholder="100"
                          :class="{ 'border-destructive': createV$.x_max.$error }"
                        />
                        <span v-if="createV$.x_max.$error" class="text-destructive text-sm">
                          {{ createV$.x_max.$errors[0].$message }}
                        </span>
                      </div>

                      <div class="flex flex-col gap-2">
                        <Label for="createYMin">Y 最小值</Label>
                        <Input
                          id="createYMin"
                          v-model="createForm.y_min"
                          type="number"
                          step="0.01"
                          placeholder="0"
                          :class="{ 'border-destructive': createV$.y_min.$error }"
                        />
                        <span v-if="createV$.y_min.$error" class="text-destructive text-sm">
                          {{ createV$.y_min.$errors[0].$message }}
                        </span>
                      </div>

                      <div class="flex flex-col gap-2">
                        <Label for="createYMax">Y 最大值</Label>
                        <Input
                          id="createYMax"
                          v-model="createForm.y_max"
                          type="number"
                          step="0.01"
                          placeholder="100"
                          :class="{ 'border-destructive': createV$.y_max.$error }"
                        />
                        <span v-if="createV$.y_max.$error" class="text-destructive text-sm">
                          {{ createV$.y_max.$errors[0].$message }}
                        </span>
                      </div>
                    </div>

                    <!-- 中心点坐标 -->
                    <div class="grid grid-cols-2 gap-4">
                      <div class="flex flex-col gap-2">
                        <Label for="createCenterX">中心 X 坐标</Label>
                        <Input
                          id="createCenterX"
                          v-model="createForm.center_x"
                          type="number"
                          step="0.01"
                          placeholder="50"
                          :class="{ 'border-destructive': createV$.center_x.$error }"
                        />
                        <span v-if="createV$.center_x.$error" class="text-destructive text-sm">
                          {{ createV$.center_x.$errors[0].$message }}
                        </span>
                      </div>

                      <div class="flex flex-col gap-2">
                        <Label for="createCenterY">中心 Y 坐标</Label>
                        <Input
                          id="createCenterY"
                          v-model="createForm.center_y"
                          type="number"
                          step="0.01"
                          placeholder="50"
                          :class="{ 'border-destructive': createV$.center_y.$error }"
                        />
                        <span v-if="createV$.center_y.$error" class="text-destructive text-sm">
                          {{ createV$.center_y.$errors[0].$message }}
                        </span>
                      </div>
                    </div>

                    <!-- 缩放比例 -->
                    <!-- <div class="flex flex-col gap-2">
                      <Label for="createScaleRatio">缩放比例</Label>
                      <Input
                        id="createScaleRatio"
                        v-model="createForm.scale_ratio"
                        type="number"
                        step="0.1"
                        placeholder="1.0"
                        :class="{ 'border-destructive': createV$.scale_ratio.$error }"
                      />
                      <span v-if="createV$.scale_ratio.$error" class="text-destructive text-sm">
                        {{ createV$.scale_ratio.$errors[0].$message }}
                      </span>
                    </div> -->
                  </div>
                </ScrollArea>

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

    <!-- 地图列表 -->
    <Card class="flex-1">
      <CardContent class="p-0">
        <ScrollArea class="h-[calc(100vh-16rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>地图名称</TableHead>
                <TableHead>坐标范围</TableHead>
                <TableHead>中心点</TableHead>
                <TableHead>缩放比例</TableHead>
                <TableHead class="hidden md:table-cell">创建时间</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              <TableRow v-if="loading">
                <TableCell colspan="6" class="text-center">加载中...</TableCell>
              </TableRow>

              <TableRow v-else-if="customMaps.length === 0">
                <TableCell colspan="6" class="text-muted-foreground text-center">
                  暂无地图数据，点击右上角创建新地图
                </TableCell>
              </TableRow>

              <TableRow v-else v-for="map in customMaps" :key="map.id" class="hover:bg-muted/50">
                <TableCell class="font-medium">
                  <div class="flex flex-col">
                    <span>{{ map.map_name }}</span>
                    <span v-if="map.description" class="text-muted-foreground text-xs">
                      {{ map.description }}
                    </span>
                  </div>
                </TableCell>
                <TableCell>
                  <div class="text-sm">
                    <div>X: {{ map.x_min }} ~ {{ map.x_max }}</div>
                    <div>Y: {{ map.y_min }} ~ {{ map.y_max }}</div>
                  </div>
                </TableCell>
                <TableCell>
                  <div class="text-sm">({{ map.center_x }}, {{ map.center_y }})</div>
                </TableCell>
                <TableCell>{{ map.scale_ratio }}</TableCell>
                <TableCell class="hidden md:table-cell">
                  {{ new Date(map.created_at).toLocaleString() }}
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 预览按钮 -->
                    <Button
                      variant="outline"
                      size="icon"
                      @click="openPreviewDialog(map)"
                      title="预览"
                    >
                      <Eye class="h-4 w-4" />
                    </Button>

                    <!-- 编辑按钮 -->
                    <Button variant="outline" size="icon" @click="openEditDialog(map)" title="编辑">
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
                          <AlertDialogTitle>确认删除地图？</AlertDialogTitle>
                          <AlertDialogDescription>
                            你将永久删除地图 "<strong>{{ map.map_name }}</strong
                            >"，此操作无法撤销。
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>取消</AlertDialogCancel>
                          <AlertDialogAction
                            class="bg-red-500 hover:bg-red-600"
                            :disabled="isDeleting[map.id]"
                            @click="handleDelete(map.id)"
                          >
                            {{ isDeleting[map.id] ? "删除中..." : "确认删除" }}
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

    <!-- 编辑地图对话框 -->
    <Dialog v-model:open="editDialogOpen">
      <DialogContent class="sm:max-w-[600px]">
        <DialogHeader>
          <DialogTitle>编辑地图</DialogTitle>
          <DialogDescription>修改地图配置信息</DialogDescription>
        </DialogHeader>

        <form @submit.prevent="handleUpdate">
          <ScrollArea class="max-h-[calc(100vh-16rem)]">
            <div class="space-y-4 px-1 py-4">
              <!-- 地图名称 -->
              <div class="flex flex-col gap-2">
                <Label for="editMapName">地图名称</Label>
                <Input
                  id="editMapName"
                  v-model="editForm.map_name"
                  placeholder="例如：一楼平面图"
                  :class="{ 'border-destructive': editV$.map_name.$error }"
                />
                <span v-if="editV$.map_name.$error" class="text-destructive text-sm">
                  {{ editV$.map_name.$errors[0].$message }}
                </span>
              </div>

              <!-- 地图描述 -->
              <div class="flex flex-col gap-2">
                <Label for="editDescription">描述（可选）</Label>
                <Textarea
                  id="editDescription"
                  v-model="editForm.description"
                  placeholder="地图描述..."
                  rows="2"
                />
              </div>

              <!-- 图片上传 -->
              <div class="flex flex-col gap-2">
                <Label for="editImage">更换地图图片（可选）</Label>
                <Input
                  id="editImage"
                  type="file"
                  accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
                  @change="(e: Event) => handleImageUpload(e, editForm)"
                />
                <span class="text-muted-foreground text-xs"> 不上传则保持原图片不变 </span>
                <!-- 图片预览 -->
                <div v-if="editImagePreview" class="mt-2">
                  <img
                    :src="editImagePreview"
                    alt="预览"
                    class="max-h-40 rounded border object-contain"
                  />
                </div>
              </div>

              <!-- 坐标范围 -->
              <div class="grid grid-cols-2 gap-4">
                <div class="flex flex-col gap-2">
                  <Label for="editXMin">X 最小值</Label>
                  <Input
                    id="editXMin"
                    v-model="editForm.x_min"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.x_min.$error }"
                  />
                  <span v-if="editV$.x_min.$error" class="text-destructive text-sm">
                    {{ editV$.x_min.$errors[0].$message }}
                  </span>
                </div>

                <div class="flex flex-col gap-2">
                  <Label for="editXMax">X 最大值</Label>
                  <Input
                    id="editXMax"
                    v-model="editForm.x_max"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.x_max.$error }"
                  />
                  <span v-if="editV$.x_max.$error" class="text-destructive text-sm">
                    {{ editV$.x_max.$errors[0].$message }}
                  </span>
                </div>

                <div class="flex flex-col gap-2">
                  <Label for="editYMin">Y 最小值</Label>
                  <Input
                    id="editYMin"
                    v-model="editForm.y_min"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.y_min.$error }"
                  />
                  <span v-if="editV$.y_min.$error" class="text-destructive text-sm">
                    {{ editV$.y_min.$errors[0].$message }}
                  </span>
                </div>

                <div class="flex flex-col gap-2">
                  <Label for="editYMax">Y 最大值</Label>
                  <Input
                    id="editYMax"
                    v-model="editForm.y_max"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.y_max.$error }"
                  />
                  <span v-if="editV$.y_max.$error" class="text-destructive text-sm">
                    {{ editV$.y_max.$errors[0].$message }}
                  </span>
                </div>
              </div>

              <!-- 中心点坐标 -->
              <div class="grid grid-cols-2 gap-4">
                <div class="flex flex-col gap-2">
                  <Label for="editCenterX">中心 X 坐标</Label>
                  <Input
                    id="editCenterX"
                    v-model="editForm.center_x"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.center_x.$error }"
                  />
                  <span v-if="editV$.center_x.$error" class="text-destructive text-sm">
                    {{ editV$.center_x.$errors[0].$message }}
                  </span>
                </div>

                <div class="flex flex-col gap-2">
                  <Label for="editCenterY">中心 Y 坐标</Label>
                  <Input
                    id="editCenterY"
                    v-model="editForm.center_y"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.center_y.$error }"
                  />
                  <span v-if="editV$.center_y.$error" class="text-destructive text-sm">
                    {{ editV$.center_y.$errors[0].$message }}
                  </span>
                </div>
              </div>

              <!-- 缩放比例 -->
              <div class="flex flex-col gap-2">
                <Label for="editScaleRatio">缩放比例</Label>
                <Input
                  id="editScaleRatio"
                  v-model="editForm.scale_ratio"
                  type="number"
                  step="0.1"
                  :class="{ 'border-destructive': editV$.scale_ratio.$error }"
                />
                <span v-if="editV$.scale_ratio.$error" class="text-destructive text-sm">
                  {{ editV$.scale_ratio.$errors[0].$message }}
                </span>
              </div>
            </div>
          </ScrollArea>

          <DialogFooter>
            <Button type="button" variant="outline" @click="editDialogOpen = false"> 取消 </Button>
            <Button type="submit" :disabled="isUpdating">
              {{ isUpdating ? "更新中..." : "更新" }}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>

    <!-- 预览地图对话框 -->
    <Dialog v-model:open="previewDialogOpen">
      <DialogContent class="sm:max-w-[800px]">
        <DialogHeader>
          <DialogTitle>{{ previewMap?.map_name }}</DialogTitle>
          <DialogDescription v-if="previewMap?.description">
            {{ previewMap.description }}
          </DialogDescription>
        </DialogHeader>

        <div v-if="previewMap" class="space-y-4">
          <!-- 地图图片 -->
          <div v-if="previewMap.image_url" class="rounded border">
            <img
              :src="previewMap.image_url"
              :alt="previewMap.map_name"
              class="h-auto w-full rounded object-contain"
            />
          </div>
          <div v-else class="bg-muted flex items-center justify-center rounded border p-8">
            <div class="text-muted-foreground flex items-center gap-2">
              <ImageIcon class="h-5 w-5" />
              <span>暂无地图图片</span>
            </div>
          </div>

          <!-- 地图信息 -->
          <div class="grid grid-cols-2 gap-4 rounded border p-4 text-sm">
            <div>
              <span class="text-muted-foreground">坐标范围 X：</span>
              <span class="font-medium">{{ previewMap.x_min }} ~ {{ previewMap.x_max }}</span>
            </div>
            <div>
              <span class="text-muted-foreground">坐标范围 Y：</span>
              <span class="font-medium">{{ previewMap.y_min }} ~ {{ previewMap.y_max }}</span>
            </div>
            <div>
              <span class="text-muted-foreground">中心点：</span>
              <span class="font-medium"
                >({{ previewMap.center_x }}, {{ previewMap.center_y }})</span
              >
            </div>
            <div>
              <span class="text-muted-foreground">缩放比例：</span>
              <span class="font-medium">{{ previewMap.scale_ratio }}</span>
            </div>
            <div class="col-span-2">
              <span class="text-muted-foreground">创建时间：</span>
              <span class="font-medium">{{
                new Date(previewMap.created_at).toLocaleString()
              }}</span>
            </div>
            <div class="col-span-2">
              <span class="text-muted-foreground">更新时间：</span>
              <span class="font-medium">{{
                new Date(previewMap.updated_at).toLocaleString()
              }}</span>
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" @click="previewDialogOpen = false">关闭</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
