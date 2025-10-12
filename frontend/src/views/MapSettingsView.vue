<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题卡片 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Settings class="h-5 w-5" />
              地图设置
            </CardTitle>
            <CardDescription>配置地图显示和行为选项</CardDescription>
          </div>
        </div>
      </CardHeader>
    </Card>

    <!-- 设置内容 -->
    <Card>
      <CardContent class="p-6">
        <div class="space-y-6">
          <!-- 地图显示设置 -->
          <div class="space-y-4">
            <h3 class="text-lg font-semibold">显示设置</h3>

            <div class="flex items-center justify-between">
              <div class="space-y-0.5">
                <Label>显示标记名称</Label>
                <p class="text-muted-foreground text-sm">在地图上显示标记的名称标签</p>
              </div>
              <Switch v-model:checked="settings.showMarkNames" />
            </div>

            <Separator />

            <div class="flex items-center justify-between">
              <div class="space-y-0.5">
                <Label>显示安全区域</Label>
                <p class="text-muted-foreground text-sm">显示标记周围的安全距离范围</p>
              </div>
              <Switch v-model:checked="settings.showSafetyZones" />
            </div>

            <Separator />

            <div class="flex items-center justify-between">
              <div class="space-y-0.5">
                <Label>显示基站位置</Label>
                <p class="text-muted-foreground text-sm">在地图上显示 UWB 基站位置</p>
              </div>
              <Switch v-model:checked="settings.showStations" />
            </div>

            <Separator />

            <div class="flex items-center justify-between">
              <div class="space-y-0.5">
                <Label>显示历史轨迹</Label>
                <p class="text-muted-foreground text-sm">显示标记的移动轨迹路径</p>
              </div>
              <Switch v-model:checked="settings.showTrajectory" />
            </div>
          </div>

          <Separator class="my-6" />

          <!-- 地图交互设置 -->
          <div class="space-y-4">
            <h3 class="text-lg font-semibold">交互设置</h3>

            <div class="flex items-center justify-between">
              <div class="space-y-0.5">
                <Label>自动缩放</Label>
                <p class="text-muted-foreground text-sm">自动调整地图缩放以显示所有标记</p>
              </div>
              <Switch v-model:checked="settings.autoZoom" />
            </div>

            <Separator />

            <div class="flex items-center justify-between">
              <div class="space-y-0.5">
                <Label>实时更新</Label>
                <p class="text-muted-foreground text-sm">启用标记位置的实时更新</p>
              </div>
              <Switch v-model:checked="settings.realtimeUpdate" />
            </div>

            <Separator />

            <div class="space-y-2">
              <Label>更新频率（秒）</Label>
              <div class="flex items-center gap-4">
                <Input
                  v-model.number="settings.updateInterval"
                  type="number"
                  min="1"
                  max="60"
                  step="1"
                  class="w-32"
                />
                <span class="text-muted-foreground text-sm">
                  每 {{ settings.updateInterval }} 秒更新一次
                </span>
              </div>
            </div>
          </div>

          <Separator class="my-6" />

          <!-- 地图样式设置 -->
          <div class="space-y-4">
            <h3 class="text-lg font-semibold">样式设置</h3>

            <div class="space-y-2">
              <Label>标记图标大小</Label>
              <div class="flex items-center gap-4">
                <Input
                  v-model.number="settings.markerSize"
                  type="number"
                  min="10"
                  max="50"
                  step="1"
                  class="w-32"
                />
                <span class="text-muted-foreground text-sm">{{ settings.markerSize }} 像素</span>
              </div>
            </div>

            <Separator />

            <div class="space-y-2">
              <Label>安全区域透明度</Label>
              <div class="flex items-center gap-4">
                <Input
                  v-model.number="settings.zoneOpacity"
                  type="number"
                  min="0"
                  max="100"
                  step="5"
                  class="w-32"
                />
                <span class="text-muted-foreground text-sm">{{ settings.zoneOpacity }}%</span>
              </div>
            </div>
          </div>

          <!-- 操作按钮 -->
          <div class="flex justify-end gap-4 pt-6">
            <Button variant="outline" @click="resetSettings">恢复默认</Button>
            <Button @click="saveSettings" :disabled="isSaving">
              {{ isSaving ? "保存中..." : "保存设置" }}
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from "vue";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Separator } from "@/components/ui/separator";
import { Settings } from "lucide-vue-next";
import { toast } from "vue-sonner";

interface MapSettings {
  showMarkNames: boolean;
  showSafetyZones: boolean;
  showStations: boolean;
  showTrajectory: boolean;
  autoZoom: boolean;
  realtimeUpdate: boolean;
  updateInterval: number;
  markerSize: number;
  zoneOpacity: number;
}

const defaultSettings: MapSettings = {
  showMarkNames: true,
  showSafetyZones: true,
  showStations: true,
  showTrajectory: false,
  autoZoom: true,
  realtimeUpdate: true,
  updateInterval: 5,
  markerSize: 24,
  zoneOpacity: 30,
};

const settings = reactive<MapSettings>({ ...defaultSettings });
const isSaving = ref(false);

// 加载设置
onMounted(() => {
  const saved = localStorage.getItem("mapSettings");
  if (saved) {
    try {
      Object.assign(settings, JSON.parse(saved));
    } catch (e) {
      console.error("Failed to load settings:", e);
    }
  }
});

// 保存设置
async function saveSettings() {
  isSaving.value = true;
  try {
    localStorage.setItem("mapSettings", JSON.stringify(settings));
    // 模拟异步保存
    await new Promise((resolve) => setTimeout(resolve, 500));
    toast.success("设置已保存");
  } catch (e: any) {
    toast.error("保存失败", { description: e.message });
  } finally {
    isSaving.value = false;
  }
}

// 恢复默认设置
function resetSettings() {
  Object.assign(settings, defaultSettings);
  toast.info("已恢复默认设置");
}
</script>

