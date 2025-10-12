<!-- src\components\station\StationManagePanel.vue -->
<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { required, helpers } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { toast } from "vue-sonner";
import { Plus, Pen, Trash, MapPin } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
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
import { stationApi } from "@/api";
import type { StationResp, StationCreateReq, StationUpdateReq } from "@/types/station";

/* -------------------------------------------------- */
/* 类型定义                                           */
/* -------------------------------------------------- */
interface FormState {
  station_name: string;
  coordinate_x: number | string;
  coordinate_y: number | string;
}

/* -------------------------------------------------- */
/* 基站列表                                           */
/* -------------------------------------------------- */
const stations = ref<StationResp[]>([]);
const loading = ref(false);

async function loadStations() {
  loading.value = true;
  try {
    const response = await stationApi.listStations();
    stations.value = response.data.data || [];
  } catch (e: any) {
    // 如果错误已经在 request.ts 中处理过，就不再重复提示
    if (!e._handled) {
      toast.error("加载基站列表失败", {
        description: e.response?.data?.message || e.message,
      });
    }
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  loadStations();
});

/* -------------------------------------------------- */
/* 创建基站                                           */
/* -------------------------------------------------- */
const createDialogOpen = ref(false);
const createFormInitial: FormState = {
  station_name: "",
  coordinate_x: "",
  coordinate_y: "",
};

const createForm = reactive<FormState>({ ...createFormInitial });

const createRules = {
  station_name: { required: helpers.withMessage("请输入基站名称", required) },
  coordinate_x: { required: helpers.withMessage("请输入X坐标", required) },
  coordinate_y: { required: helpers.withMessage("请输入Y坐标", required) },
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
    await stationApi.createStation({
      station_name: createForm.station_name,
      coordinate_x: Number(createForm.coordinate_x),
      coordinate_y: Number(createForm.coordinate_y),
    });

    toast.success("基站创建成功");
    createDialogOpen.value = false;
    Object.assign(createForm, createFormInitial);
    createV$.value.$reset();
    await loadStations();
  } catch (e: any) {
    // 如果错误已经在 request.ts 中处理过，就不再重复提示
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "创建失败";
      toast.error("创建基站失败", { description: errorMsg });
    }
  } finally {
    isCreating.value = false;
  }
}

/* -------------------------------------------------- */
/* 编辑基站                                           */
/* -------------------------------------------------- */
const editDialogOpen = ref(false);
const editingStation = ref<StationResp | null>(null);
const editForm = reactive<FormState>({
  station_name: "",
  coordinate_x: "",
  coordinate_y: "",
});

const editRules = {
  station_name: { required: helpers.withMessage("请输入基站名称", required) },
  coordinate_x: { required: helpers.withMessage("请输入X坐标", required) },
  coordinate_y: { required: helpers.withMessage("请输入Y坐标", required) },
};

const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);

function openEditDialog(station: StationResp) {
  editingStation.value = station;
  editForm.station_name = station.station_name;
  editForm.coordinate_x = station.coordinate_x;
  editForm.coordinate_y = station.coordinate_y;
  editV$.value.$reset();
  editDialogOpen.value = true;
}

async function handleUpdate() {
  const valid = await editV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }

  if (!editingStation.value || isUpdating.value) return;
  isUpdating.value = true;

  try {
    await stationApi.updateStation(editingStation.value.id, {
      station_name: editForm.station_name,
      coordinate_x: Number(editForm.coordinate_x),
      coordinate_y: Number(editForm.coordinate_y),
    });

    toast.success("基站更新成功");
    editDialogOpen.value = false;
    await loadStations();
  } catch (e: any) {
    // 如果错误已经在 request.ts 中处理过，就不再重复提示
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新基站失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}

/* -------------------------------------------------- */
/* 删除基站                                           */
/* -------------------------------------------------- */
const isDeleting = ref<Record<string, boolean>>({});

async function handleDelete(id: string) {
  if (isDeleting.value[id]) return;
  isDeleting.value[id] = true;

  try {
    await stationApi.deleteStation(id);
    toast.success("基站删除成功");
    await loadStations();
  } catch (e: any) {
    // 如果错误已经在 request.ts 中处理过，就不再重复提示
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "删除失败";
      toast.error("删除基站失败", { description: errorMsg });
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
              <MapPin class="h-5 w-5" />
              基站管理
            </CardTitle>
            <CardDescription>管理所有基站的信息</CardDescription>
          </div>

          <!-- 创建基站对话框 -->
          <Dialog v-model:open="createDialogOpen">
            <DialogTrigger as-child>
              <Button>
                <Plus class="mr-2 h-4 w-4" />
                新建基站
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[500px]">
              <DialogHeader>
                <DialogTitle>新建基站</DialogTitle>
                <DialogDescription>填写基站信息并提交</DialogDescription>
              </DialogHeader>

              <form @submit.prevent="handleCreate">
                <div class="space-y-4 py-4">
                  <!-- 基站名称 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createStationName">基站名称</Label>
                    <Input
                      id="createStationName"
                      v-model="createForm.station_name"
                      placeholder="例如：东区-01"
                      :class="{ 'border-destructive': createV$.station_name.$error }"
                    />
                    <span v-if="createV$.station_name.$error" class="text-destructive text-sm">
                      {{ createV$.station_name.$errors[0].$message }}
                    </span>
                  </div>

                  <!-- X 坐标 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createLocX">X 坐标</Label>
                    <Input
                      id="createLocX"
                      v-model="createForm.coordinate_x"
                      type="number"
                      step="0.01"
                      placeholder="0.00"
                      :class="{ 'border-destructive': createV$.coordinate_x.$error }"
                    />
                    <span v-if="createV$.coordinate_x.$error" class="text-destructive text-sm">
                      {{ createV$.coordinate_x.$errors[0].$message }}
                    </span>
                  </div>

                  <!-- Y 坐标 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createLocY">Y 坐标</Label>
                    <Input
                      id="createLocY"
                      v-model="createForm.coordinate_y"
                      type="number"
                      step="0.01"
                      placeholder="0.00"
                      :class="{ 'border-destructive': createV$.coordinate_y.$error }"
                    />
                    <span v-if="createV$.coordinate_y.$error" class="text-destructive text-sm">
                      {{ createV$.coordinate_y.$errors[0].$message }}
                    </span>
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

    <!-- 基站列表 -->
    <Card class="flex-1">
      <CardContent class="p-0">
        <ScrollArea class="h-[calc(100vh-16rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>基站名称</TableHead>
                <TableHead>X 坐标</TableHead>
                <TableHead>Y 坐标</TableHead>
                <TableHead class="hidden md:table-cell">创建时间</TableHead>
                <TableHead class="hidden md:table-cell">更新时间</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              <TableRow v-if="loading">
                <TableCell colspan="6" class="text-center">加载中...</TableCell>
              </TableRow>

              <TableRow v-else-if="stations.length === 0">
                <TableCell colspan="6" class="text-muted-foreground text-center">
                  暂无基站数据，点击右上角创建新基站
                </TableCell>
              </TableRow>

              <TableRow
                v-else
                v-for="station in stations"
                :key="station.id"
                class="hover:bg-muted/50"
              >
                <TableCell class="font-medium">{{ station.station_name }}</TableCell>
                <TableCell>{{ station.coordinate_x }}</TableCell>
                <TableCell>{{ station.coordinate_y }}</TableCell>
                <TableCell class="hidden md:table-cell">
                  {{ new Date(station.created_at).toLocaleString() }}
                </TableCell>
                <TableCell class="hidden md:table-cell">
                  {{ new Date(station.updated_at).toLocaleString() }}
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 编辑按钮 -->
                    <Button
                      variant="outline"
                      size="icon"
                      @click="openEditDialog(station)"
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
                          <AlertDialogTitle>确认删除基站？</AlertDialogTitle>
                          <AlertDialogDescription>
                            你将永久删除基站 "<strong>{{ station.station_name }}</strong
                            >"，此操作无法撤销。
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>取消</AlertDialogCancel>
                          <AlertDialogAction
                            class="bg-red-500 hover:bg-red-600"
                            :disabled="isDeleting[station.id]"
                            @click="handleDelete(station.id)"
                          >
                            {{ isDeleting[station.id] ? "删除中..." : "确认删除" }}
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

    <!-- 编辑基站对话框 -->
    <Dialog v-model:open="editDialogOpen">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>编辑基站</DialogTitle>
          <DialogDescription>修改基站信息</DialogDescription>
        </DialogHeader>

        <form @submit.prevent="handleUpdate">
          <div class="space-y-4 py-4">
            <!-- 基站名称 -->
            <div class="flex flex-col gap-2">
              <Label for="editStationName">基站名称</Label>
              <Input
                id="editStationName"
                v-model="editForm.station_name"
                placeholder="例如：东区-01"
                :class="{ 'border-destructive': editV$.station_name.$error }"
              />
              <span v-if="editV$.station_name.$error" class="text-destructive text-sm">
                {{ editV$.station_name.$errors[0].$message }}
              </span>
            </div>

            <!-- X 坐标 -->
            <div class="flex flex-col gap-2">
              <Label for="editLocX">X 坐标</Label>
              <Input
                id="editLocX"
                v-model="editForm.coordinate_x"
                type="number"
                step="0.01"
                placeholder="0.00"
                :class="{ 'border-destructive': editV$.coordinate_x.$error }"
              />
              <span v-if="editV$.coordinate_x.$error" class="text-destructive text-sm">
                {{ editV$.coordinate_x.$errors[0].$message }}
              </span>
            </div>

            <!-- Y 坐标 -->
            <div class="flex flex-col gap-2">
              <Label for="editLocY">Y 坐标</Label>
              <Input
                id="editLocY"
                v-model="editForm.coordinate_y"
                type="number"
                step="0.01"
                placeholder="0.00"
                :class="{ 'border-destructive': editV$.coordinate_y.$error }"
              />
              <span v-if="editV$.coordinate_y.$error" class="text-destructive text-sm">
                {{ editV$.coordinate_y.$errors[0].$message }}
              </span>
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
