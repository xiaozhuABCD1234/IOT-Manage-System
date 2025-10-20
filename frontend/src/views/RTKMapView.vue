<!-- src/views/RTKMapView.vue -->
<script setup lang="ts">
import { ref, onMounted } from "vue";
import NewMap from "@/components/maps/RealtimeMap.vue";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import { listOutdoorFences, createPolygonFence, deletePolygonFence } from "@/api/polygonFence";
import type { PolygonFenceResp, Point } from "@/types/polygonFence";
import { toast } from "vue-sonner";

const mapRef = ref<InstanceType<typeof NewMap> | null>(null);

const fences = ref<PolygonFenceResp[]>([]);
const isDrawing = ref(false);
const currentPolygon = ref<Point[]>([]);
const fenceName = ref("");
const fenceDescription = ref("");
const isSaving = ref(false);
const deletingFenceId = ref<string | null>(null);

async function loadOutdoorFences() {
  const res = await listOutdoorFences(true);
  if (res.data && res.data.data) {
    fences.value = res.data.data;
    mapRef.value?.setOutdoorFences(fences.value);
  } else {
    fences.value = [];
  }
}

function startDrawing() {
  isDrawing.value = true;
  currentPolygon.value = [];
  fenceName.value = "";
  fenceDescription.value = "";
  mapRef.value?.startPolygonDrawing();
}

function cancelDrawing() {
  isDrawing.value = false;
  currentPolygon.value = [];
  mapRef.value?.cancelDrawing();
}

function onPolygonDrawn(points: { x: number; y: number }[]) {
  isDrawing.value = true;
  currentPolygon.value = points.map((p) => ({ x: p.x, y: p.y }));
}

async function finishDrawing() {
  if (currentPolygon.value.length < 3) {
    toast.error("多边形至少需要3个顶点");
    return;
  }
  if (!fenceName.value.trim()) {
    toast.error("请输入围栏名称");
    return;
  }
  isSaving.value = true;
  try {
    await createPolygonFence({
      is_indoor: false,
      fence_name: fenceName.value,
      points: currentPolygon.value,
      description: fenceDescription.value,
    });
    toast.success("围栏创建成功");
    await loadOutdoorFences();
    cancelDrawing();
  } catch (e) {
    toast.error("创建围栏失败");
  } finally {
    isSaving.value = false;
  }
}

async function removeFence(id: string) {
  deletingFenceId.value = id;
  try {
    await deletePolygonFence(id);
    toast.success("删除成功");
    await loadOutdoorFences();
  } catch (e) {
    toast.error("删除失败");
  } finally {
    deletingFenceId.value = null;
  }
}

onMounted(() => {
  loadOutdoorFences();
});
</script>

<template>
  <div class="h-[calc(100vh-3rem)] w-full bg-gray-50 p-4">
    <ResizablePanelGroup direction="horizontal" class="h-full rounded-lg border">
      <ResizablePanel :default-size="65" :min-size="30">
        <div class="relative h-full w-full">
          <NewMap ref="mapRef" @polygon-drawn="onPolygonDrawn" />
        </div>
      </ResizablePanel>
      <ResizableHandle with-handle />
      <ResizablePanel :default-size="35" :min-size="25">
        <Card class="h-full rounded-none border-0">
          <CardHeader>
            <CardTitle>室外电子围栏</CardTitle>
          </CardHeader>
          <CardContent class="h-[calc(100%-80px)]">
            <ScrollArea class="h-full pr-4">
              <div class="space-y-4">
                <div v-if="!isDrawing" class="space-y-2">
                  <Button class="w-full" @click="startDrawing">开始绘制围栏</Button>
                  <p class="text-muted-foreground text-sm">在地图上点击绘制多边形</p>
                </div>
                <div v-else class="space-y-4">
                  <div class="rounded-lg bg-blue-50 p-3 text-sm text-blue-800">
                    <p class="font-semibold">绘制模式已激活</p>
                    <p class="mt-1">完成鼠标绘制后可编辑名称并保存</p>
                  </div>
                  <div class="space-y-2">
                    <Label for="fence-name">围栏名称 *</Label>
                    <Input id="fence-name" v-model="fenceName" placeholder="例如：室外区域A" />
                  </div>
                  <div class="space-y-2">
                    <Label for="fence-description">描述（可选）</Label>
                    <Input
                      id="fence-description"
                      v-model="fenceDescription"
                      placeholder="围栏用途说明"
                    />
                  </div>
                  <div class="space-y-2">
                    <Label>顶点 ({{ currentPolygon.length }} 个)</Label>
                    <div v-if="currentPolygon.length === 0" class="text-muted-foreground text-sm">
                      暂无顶点
                    </div>
                    <div v-else class="max-h-72 space-y-2 overflow-y-auto">
                      <div
                        v-for="(pt, idx) in currentPolygon"
                        :key="`pt-${idx}-${pt.x}-${pt.y}`"
                        class="flex items-center gap-3 rounded border bg-white p-2"
                      >
                        <span class="w-6 text-center text-blue-600">{{ idx + 1 }}</span>
                        <div class="flex gap-2 text-sm">
                          <span>X: {{ pt.x }}</span>
                          <span>Y: {{ pt.y }}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="flex gap-2">
                    <Button
                      class="flex-1"
                      :disabled="currentPolygon.length < 3 || !fenceName.trim() || isSaving"
                      @click="finishDrawing"
                    >
                      {{ isSaving ? "保存中..." : "完成并保存" }}
                    </Button>
                    <Button
                      class="flex-1"
                      variant="outline"
                      :disabled="isSaving"
                      @click="cancelDrawing"
                      >取消</Button
                    >
                  </div>
                </div>

                <div class="mt-4 space-y-2">
                  <Label>已有室外围栏 ({{ fences.length }} 个)</Label>
                  <div v-if="fences.length === 0" class="text-muted-foreground text-sm">
                    暂无围栏
                  </div>
                  <div v-else class="space-y-2">
                    <div v-for="f in fences" :key="f.id" class="rounded-lg border bg-white p-3">
                      <div class="flex items-center justify-between gap-2">
                        <div class="flex-1">
                          <p class="font-semibold">{{ f.fence_name }}</p>
                          <p class="text-muted-foreground text-xs">
                            {{ f.points.length }} 个顶点
                            <span class="text-orange-600">· 室外</span>
                            <span v-if="f.is_active" class="text-blue-600">· 已激活</span>
                            <span v-else class="text-gray-400">· 未激活</span>
                          </p>
                        </div>
                        <Button
                          variant="destructive"
                          size="sm"
                          :disabled="deletingFenceId === f.id"
                          @click="removeFence(f.id)"
                        >
                          {{ deletingFenceId === f.id ? "删除中..." : "删除" }}
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
  </div>
</template>
