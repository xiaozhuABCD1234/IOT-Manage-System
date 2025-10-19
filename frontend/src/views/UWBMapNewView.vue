<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch } from "vue";
import { getLatestCustomMap } from "@/api/customMap";
import { listStations } from "@/api/station";
import { listIndoorFences, createPolygonFence, deletePolygonFence } from "@/api/polygonFence";
import type { CustomMapResp } from "@/types/customMap";
import type { StationResp } from "@/types/station";
import type { PolygonFenceResp, Point } from "@/types/polygonFence";
import { connectMQTT, disconnectMQTT, parseUWBMessage, type UWBFix } from "@/utils/mqtt";
import { useMarksStore } from "@/stores/marks";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
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
import { toast } from "vue-sonner";
import { Plus, Loader2, Trash2 } from "lucide-vue-next";
import MarkOnlineGrid from "@/components/device/MarkOnlineGrid.vue";
import {
  PixelScaler,
  drawBackgroundImage,
  drawGrid,
  drawAxisX,
  drawAxisY,
  drawStations,
  drawPolygonFences,
  drawCurrentPolygon,
  drawUWBDevices,
  drawMap,
  DoubleBufferCanvas,
  drawMapWithDoubleBuffer,
} from "@/utils/canvasDrawing";

// 数据存储
const mapData = ref<CustomMapResp | null>(null);
const stations = ref<StationResp[]>([]);
const fences = ref<PolygonFenceResp[]>([]);

// 使用 marks store
const marksStore = useMarksStore();

// UWB 设备坐标管理（保留用于位置数据）
const deviceCoordinates = ref<Map<string, UWBFix>>(new Map());

// 绘制多边形的状态
const isDrawing = ref(false);
const currentPolygon = ref<Point[]>([]);
const fenceName = ref("");
const fenceDescription = ref("");
const isIndoor = ref(true); // 默认室内围栏
const isSaving = ref(false);

// 删除确认对话框状态
const showDeleteDialog = ref(false);
const fenceToDelete = ref<{ id: string; name: string } | null>(null);
const deletingFenceId = ref<string | null>(null);

/**
 * 绘制整个地图 - 使用双缓冲技术避免闪动
 */
async function drawMapWrapper() {
  // 使用 requestAnimationFrame 确保在下一帧绘制，避免闪烁
  return new Promise<void>((resolve) => {
    requestAnimationFrame(async () => {
      if (!doubleBufferCanvas) {
        resolve();
        return;
      }

      // 调整Canvas尺寸（如果需要）
      doubleBufferCanvas.resize();

      await drawMapWithDoubleBuffer(
        doubleBufferCanvas,
        mapData.value,
        stations.value,
        fences.value,
        deviceCoordinates.value,
        marksStore.markList,
        marksStore.deviceNames,
        currentPolygon.value,
        isDrawing.value,
      );

      resolve();
    });
  });
}

/**
 * 加载所有数据
 */
async function loadData() {
  try {
    console.log("开始加载数据...");

    // 并行加载所有数据
    const [mapRes, stationsRes, fencesRes] = await Promise.all([
      getLatestCustomMap(),
      listStations(),
      listIndoorFences(true), // 只获取激活的围栏
    ]);

    console.log("地图响应:", mapRes);
    console.log("基站响应:", stationsRes);
    console.log("围栏响应:", fencesRes);

    // 响应拦截器已经处理了 code 检查，这里直接使用 data
    if (mapRes.data && mapRes.data.data) {
      mapData.value = mapRes.data.data;
      console.log("✅ 地图数据加载成功:", mapData.value);
    } else {
      console.error("❌ 地图数据加载失败:", mapRes.data?.message || mapRes);
    }

    if (stationsRes.data && stationsRes.data.data) {
      stations.value = stationsRes.data.data;
      console.log("✅ 基站数据加载成功，数量:", stations.value.length);
    } else {
      console.error("❌ 基站数据加载失败:", stationsRes.data?.message || stationsRes);
      stations.value = [];
    }

    if (fencesRes.data && fencesRes.data.data) {
      fences.value = fencesRes.data.data;
      console.log("✅ 围栏数据加载成功，数量:", fences.value.length);
    } else {
      console.error("❌ 围栏数据加载失败:", fencesRes.data?.message || fencesRes);
      fences.value = [];
    }

    // 加载完成后绘制地图
    console.log("准备绘制地图...");
    await drawMapWrapper();
  } catch (error) {
    console.error("❌ 加载数据时发生错误:", error);
  }
}

/**
 * 初始化位置数据 MQTT 连接（仅用于位置数据，在线状态由 marks store 处理）
 */
function initLocationMQTT() {
  try {
    console.log("正在连接位置数据 MQTT...");
    const locationClient = connectMQTT();

    locationClient.on("connect", () => {
      console.log("✅ 位置数据 MQTT 连接成功");

      // 订阅位置数据主题（包含 UWB 坐标）
      locationClient.subscribe("location/#", (err: any) => {
        if (err) {
          console.error("❌ 订阅位置数据主题失败:", err);
        } else {
          console.log("✅ 已订阅位置数据主题: location/#");
        }
      });
    });

    locationClient.on("message", (topic: string, payload: Buffer) => {
      try {
        console.log(`📨 收到位置 MQTT 消息: ${topic}`);
        console.log(`📦 消息内容:`, payload.toString());

        if (topic.startsWith("location/")) {
          // 处理位置数据（包含 UWB 坐标）
          try {
            const uwbData = parseUWBMessage(topic, payload);
            deviceCoordinates.value.set(uwbData.id, uwbData);
            console.log(`📍 设备 ${uwbData.id} UWB 坐标: (${uwbData.x}, ${uwbData.y})`);

            // 重新绘制地图以显示新的设备位置
            drawMapWrapper();
          } catch (error) {
            // 如果解析 UWB 数据失败，可能是 RTK 数据，忽略
            console.log(`⚠️ 位置消息解析失败，可能是 RTK 数据: ${topic}`, error);
            console.log(`📦 原始消息内容:`, payload.toString());
          }
        } else {
          console.log(`❓ 未知位置主题: ${topic}`);
        }
      } catch (error) {
        console.error("❌ 处理位置 MQTT 消息失败:", error);
        console.log(`📦 原始消息内容:`, payload.toString());
      }
    });

    locationClient.on("error", (error: any) => {
      console.error("❌ 位置数据 MQTT 连接错误:", error);
    });

    locationClient.on("offline", () => {
      console.warn("⚠️ 位置数据 MQTT 连接离线");
    });

    return locationClient;
  } catch (error) {
    console.error("❌ 初始化位置数据 MQTT 失败:", error);
    return null;
  }
}

// 位置数据 MQTT 客户端
let locationMqttClient: any = null;

// 双缓冲 Canvas 实例
let doubleBufferCanvas: DoubleBufferCanvas | null = null;

/**
 * 处理canvas点击事件 - 添加多边形顶点
 */
function handleCanvasClick(event: MouseEvent) {
  if (!isDrawing.value || !mapData.value) return;

  const canvas = event.target as HTMLCanvasElement;
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;

  // 计算像素坐标
  const px = event.clientX - rect.left;
  const py = event.clientY - rect.top;

  // 创建坐标转换器
  const scaler = new PixelScaler(
    rect.width,
    rect.height,
    mapData.value.x_min,
    mapData.value.x_max,
    mapData.value.y_min,
    mapData.value.y_max,
  );

  // 转换为逻辑坐标
  const { x, y } = scaler.toXY(px, py);

  // 添加点到当前多边形
  currentPolygon.value.push({ x: Math.round(x), y: Math.round(y) });

  console.log("添加新点:", { x: Math.round(x), y: Math.round(y) });
  console.log("当前顶点数:", currentPolygon.value.length);

  // 重新绘制
  drawMapWrapper();

  // 滚动到底部以显示新添加的点
  setTimeout(() => {
    const pointsList = document.querySelector(".points-list-container");
    if (pointsList) {
      pointsList.scrollTop = pointsList.scrollHeight;
    }
  }, 100);
}

/**
 * 开始绘制多边形
 */
function startDrawing() {
  isDrawing.value = true;
  currentPolygon.value = [];
  fenceName.value = "";
  fenceDescription.value = "";
  isIndoor.value = true; // 重置为默认室内围栏
}

/**
 * 取消绘制
 */
function cancelDrawing() {
  isDrawing.value = false;
  currentPolygon.value = [];
  drawMapWrapper();
}

/**
 * 删除指定的点
 */
function removePoint(index: number) {
  currentPolygon.value.splice(index, 1);
  drawMapWrapper();
}

/**
 * 更新点的坐标
 */
function updatePoint(index: number, axis: "x" | "y", value: string) {
  const numValue = parseFloat(value);
  if (!isNaN(numValue)) {
    currentPolygon.value[index][axis] = Math.round(numValue);
    console.log(`更新点 ${index + 1} 的 ${axis} 坐标为: ${Math.round(numValue)}`);
    drawMapWrapper();
  }
}

/**
 * 打开删除确认对话框
 */
function openDeleteDialog(fenceId: string, fenceName: string) {
  fenceToDelete.value = { id: fenceId, name: fenceName };
  showDeleteDialog.value = true;
}

/**
 * 确认删除围栏
 */
async function confirmDeleteFence() {
  if (!fenceToDelete.value) return;

  const { id, name } = fenceToDelete.value;
  deletingFenceId.value = id;
  showDeleteDialog.value = false;

  try {
    const res = await deletePolygonFence(id);
    // 响应拦截器已经处理了错误，能到这里说明成功
    toast.success("删除成功", {
      description: `围栏"${name}"已被删除`,
    });

    // 重新加载围栏列表
    const fencesRes = await listIndoorFences(true);
    if (fencesRes.data && fencesRes.data.data) {
      fences.value = fencesRes.data.data;
    }

    // 重新绘制地图
    await drawMapWrapper();
  } catch (error) {
    // 错误已在拦截器中处理
    console.error("Error deleting fence:", error);
    toast.error("删除围栏时发生错误", {
      description: "请检查网络连接后重试",
    });
  } finally {
    deletingFenceId.value = null;
    fenceToDelete.value = null;
  }
}

/**
 * 完成绘制并保存围栏
 */
async function finishDrawing() {
  if (currentPolygon.value.length < 3) {
    toast.error("多边形至少需要3个顶点", {
      description: "请在地图上继续添加更多顶点",
    });
    return;
  }

  if (!fenceName.value.trim()) {
    toast.error("请输入围栏名称", {
      description: "围栏名称是必填项",
    });
    return;
  }

  isSaving.value = true;

  try {
    const res = await createPolygonFence({
      is_indoor: isIndoor.value,
      fence_name: fenceName.value,
      points: currentPolygon.value,
      description: fenceDescription.value,
    });

    // 响应拦截器已经处理了错误，能到这里说明成功
    toast.success("围栏创建成功", {
      description: `围栏"${fenceName.value}"已成功创建`,
    });
    // 重新加载围栏列表
    const fencesRes = await listIndoorFences(true);
    if (fencesRes.data && fencesRes.data.data) {
      fences.value = fencesRes.data.data;
    }
    // 清空当前绘制
    cancelDrawing();
  } catch (error) {
    // 错误已在拦截器中处理
    console.error("Error creating fence:", error);
    toast.error("创建围栏时发生错误", {
      description: "请检查网络连接后重试",
    });
  } finally {
    isSaving.value = false;
  }
}

// ResizeObserver 实例
let resizeObserver: ResizeObserver | null = null;

// 组件挂载时加载数据
onMounted(() => {
  console.log("Component mounted, loading data...");

  // 初始化双缓冲Canvas
  const displayCanvas = document.getElementById("uwb-map-canvas") as HTMLCanvasElement;
  if (displayCanvas) {
    doubleBufferCanvas = new DoubleBufferCanvas(displayCanvas);
    console.log("✅ 双缓冲Canvas初始化成功");
    console.log("🎯 使用双缓冲技术解决Canvas重绘闪动问题");
  } else {
    console.error("❌ 无法找到Canvas元素");
  }

  loadData();

  // 启动 marks store 的 MQTT 连接（处理在线状态）
  marksStore.startMQTT();

  // 初始化位置数据 MQTT 连接（处理位置数据）
  locationMqttClient = initLocationMQTT();

  // 调试：检查设备名称加载情况
  console.log("🔍 检查设备名称加载情况:");
  console.log("设备名称映射:", marksStore.deviceNames);
  console.log("设备名称映射大小:", marksStore.deviceNames.size);
  console.log("设备列表:", marksStore.markList);
  console.log("设备列表长度:", marksStore.markList.length);

  // 检查具体设备名称
  marksStore.markList.forEach((device) => {
    const name = marksStore.deviceNames.get(device.id);
    console.log(`设备 ${device.id}: 名称="${name}" (类型: ${typeof name})`);
  });

  // 监听设备名称变化
  watch(
    () => marksStore.deviceNames,
    (newDeviceNames) => {
      console.log("🔄 设备名称映射已更新:", newDeviceNames);
      console.log("设备名称映射大小:", newDeviceNames.size);

      // 检查具体设备名称
      marksStore.markList.forEach((device) => {
        const name = newDeviceNames.get(device.id);
        console.log(`设备 ${device.id}: 名称="${name}" (类型: ${typeof name})`);
      });
    },
    { deep: true },
  );

  // 监听窗口大小变化，重新绘制
  window.addEventListener("resize", drawMapWrapper);

  // 监听 canvas 容器大小变化（用于 Resizable 面板调整）
  const canvasElement = document.getElementById("uwb-map-canvas");
  if (canvasElement) {
    resizeObserver = new ResizeObserver(() => {
      console.log("Canvas size changed, redrawing...");
      // 使用 requestAnimationFrame 确保在下一帧重绘
      requestAnimationFrame(() => {
        drawMapWrapper();
      });
    });
    resizeObserver.observe(canvasElement);
  }
});

// 组件卸载时清理
onUnmounted(() => {
  // 清理双缓冲Canvas
  if (doubleBufferCanvas) {
    console.log("正在清理双缓冲Canvas...");
    doubleBufferCanvas.destroy();
    doubleBufferCanvas = null;
    console.log("✅ 双缓冲Canvas已清理");
  }

  // 断开位置数据 MQTT 连接
  if (locationMqttClient) {
    console.log("正在断开位置数据 MQTT 连接...");
    disconnectMQTT(locationMqttClient);
    locationMqttClient = null;
    console.log("✅ 位置数据 MQTT 连接已断开");
  }

  // 注意：不在这里停止 marks store 的 MQTT，因为其他组件可能也在使用
  // marksStore.stopMQTT(); // 如果需要完全停止，可以取消注释

  window.removeEventListener("resize", drawMapWrapper);
  if (resizeObserver) {
    resizeObserver.disconnect();
    resizeObserver = null;
  }
});
</script>

<template>
  <div class="h-full w-full bg-gray-50 p-4">
    <ResizablePanelGroup direction="horizontal" class="h-full rounded-lg border">
      <!-- 左侧：地图画布 -->
      <ResizablePanel :default-size="65" :min-size="30">
        <div class="flex h-full items-center justify-center">
          <canvas
            id="uwb-map-canvas"
            class="h-full w-full rounded-lg border-2 border-gray-300 shadow-lg"
            :class="{ 'cursor-crosshair': isDrawing }"
            @click="handleCanvasClick"
          />
        </div>
      </ResizablePanel>

      <!-- 分隔条 -->
      <ResizableHandle with-handle />

      <!-- 右侧：控制面板 -->
      <ResizablePanel :default-size="35" :min-size="25">
        <Card class="h-full rounded-none border-0">
          <CardHeader>
            <CardTitle>电子围栏绘制</CardTitle>
          </CardHeader>
          <CardContent class="h-[calc(100%-80px)]">
            <ScrollArea class="h-full pr-4">
              <div class="space-y-4">
                <!-- 绘制控制 -->
                <div v-if="!isDrawing" class="space-y-2">
                  <Button class="w-full" @click="startDrawing">
                    <Plus class="mr-2 h-4 w-4" />
                    开始绘制围栏
                  </Button>
                  <p class="text-muted-foreground text-sm">
                    点击"开始绘制围栏"按钮，然后在地图上点击以添加多边形顶点
                  </p>
                </div>

                <!-- 绘制中 -->
                <div v-else class="space-y-4">
                  <div class="rounded-lg bg-orange-50 p-3 text-sm text-orange-800">
                    <p class="font-semibold">绘制模式已激活</p>
                    <p class="mt-1">点击地图添加顶点，至少需要3个顶点才能完成</p>
                  </div>

                  <!-- 围栏名称 -->
                  <div class="space-y-2">
                    <Label for="fence-name">围栏名称 *</Label>
                    <Input id="fence-name" v-model="fenceName" placeholder="例如：区域A" />
                  </div>

                  <!-- 围栏描述 -->
                  <div class="space-y-2">
                    <Label for="fence-description">描述（可选）</Label>
                    <Input
                      id="fence-description"
                      v-model="fenceDescription"
                      placeholder="围栏用途说明"
                    />
                  </div>

                  <!-- 顶点列表 -->
                  <div class="space-y-2">
                    <Label>多边形顶点 ({{ currentPolygon.length }}个)</Label>
                    <div v-if="currentPolygon.length === 0" class="text-muted-foreground text-sm">
                      暂无顶点，点击地图添加
                    </div>
                    <div v-else class="points-list-container max-h-96 space-y-2 overflow-y-auto">
                      <div
                        v-for="(point, index) in currentPolygon"
                        :key="`point-${index}-${point.x}-${point.y}`"
                        class="flex items-center gap-2 rounded-lg border bg-white p-2"
                      >
                        <span class="w-6 text-center font-semibold text-orange-600">
                          {{ index + 1 }}
                        </span>
                        <div class="flex flex-1 items-center gap-2">
                          <div class="flex flex-1 items-center gap-1">
                            <Label class="text-xs">X:</Label>
                            <Input
                              :model-value="point.x"
                              type="number"
                              class="h-8 flex-1 text-sm"
                              @update:model-value="(val) => updatePoint(index, 'x', String(val))"
                            />
                          </div>
                          <div class="flex flex-1 items-center gap-1">
                            <Label class="text-xs">Y:</Label>
                            <Input
                              :model-value="point.y"
                              type="number"
                              class="h-8 flex-1 text-sm"
                              @update:model-value="(val) => updatePoint(index, 'y', String(val))"
                            />
                          </div>
                        </div>
                        <Button variant="destructive" size="sm" @click="removePoint(index)">
                          删除
                        </Button>
                      </div>
                    </div>
                  </div>

                  <!-- 操作按钮 -->
                  <div class="flex gap-2">
                    <Button
                      class="flex-1"
                      variant="default"
                      :disabled="currentPolygon.length < 3 || !fenceName.trim() || isSaving"
                      @click="finishDrawing"
                    >
                      <Loader2 v-if="isSaving" class="mr-2 h-4 w-4 animate-spin" />
                      {{ isSaving ? "保存中..." : "完成并保存" }}
                    </Button>
                    <Button
                      class="flex-1"
                      variant="outline"
                      :disabled="isSaving"
                      @click="cancelDrawing"
                    >
                      取消
                    </Button>
                  </div>
                </div>

                <!-- UWB 设备状态 -->
                <div class="mt-4 space-y-2">
                  <Label>UWB 设备状态 ({{ marksStore.markList.length }}个)</Label>
                  <div class="h-48">
                    <MarkOnlineGrid
                      :marks="marksStore.markList"
                      :device-names="marksStore.deviceNames"
                    />
                  </div>
                </div>

                <!-- 已有围栏列表 -->
                <div class="mt-6 space-y-2">
                  <Label>已有围栏 ({{ fences.length }}个)</Label>
                  <div v-if="fences.length === 0" class="text-muted-foreground text-sm">
                    暂无围栏
                  </div>
                  <div v-else class="space-y-2">
                    <div
                      v-for="fence in fences"
                      :key="fence.id"
                      class="rounded-lg border bg-white p-3"
                    >
                      <div class="flex items-center justify-between gap-2">
                        <div class="flex-1">
                          <p class="font-semibold">{{ fence.fence_name }}</p>
                          <p class="text-muted-foreground text-xs">
                            {{ fence.points.length }} 个顶点
                            <span v-if="fence.is_indoor" class="text-green-600">· 室内</span>
                            <span v-else class="text-orange-600">· 室外</span>
                            <span v-if="fence.is_active" class="text-blue-600">· 已激活</span>
                            <span v-else class="text-gray-400">· 未激活</span>
                          </p>
                        </div>
                        <Button
                          variant="destructive"
                          size="sm"
                          :disabled="deletingFenceId === fence.id"
                          @click="openDeleteDialog(fence.id, fence.fence_name)"
                        >
                          <Loader2
                            v-if="deletingFenceId === fence.id"
                            class="mr-2 h-4 w-4 animate-spin"
                          />
                          <Trash2 v-else class="h-4 w-4" />
                          {{ deletingFenceId === fence.id ? "删除中..." : "删除" }}
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </ScrollArea>
          </CardContent>
        </Card>
      </ResizablePanel>
    </ResizablePanelGroup>

    <!-- 删除确认对话框 -->
    <AlertDialog v-model:open="showDeleteDialog">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>确定要删除这个围栏吗？</AlertDialogTitle>
          <AlertDialogDescription>
            此操作无法撤销。将永久删除围栏"{{ fenceToDelete?.name }}"及其所有数据。
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>取消</AlertDialogCancel>
          <AlertDialogAction
            class="bg-destructive hover:bg-destructive/90"
            @click="confirmDeleteFence"
          >
            删除
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>
