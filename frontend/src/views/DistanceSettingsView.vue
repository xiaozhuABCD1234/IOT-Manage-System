<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 页面标题和显示控制 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Ruler class="h-5 w-5" />
              距离设置管理
            </CardTitle>
            <CardDescription>配置标记、分组和类型之间的安全距离</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent class="flex justify-between">
        <!-- 功能说明 -->
        <div class="flex items-start gap-3">
          <Info class="mt-0.5 h-5 w-5 flex-shrink-0 text-blue-500" />
          <div class="space-y-2">
            <h3 class="text-sm font-semibold">功能说明</h3>
            <div class="text-muted-foreground space-y-1 text-xs sm:text-sm">
              <p>• <strong>单对距离设置</strong>：为两个特定标记设置安全距离</p>
              <p>• <strong>组合距离设置</strong>：为多个标记批量设置统一距离</p>
              <p>• <strong>笛卡尔积距离设置</strong>：为两组不同类型的对象设置距离</p>
              <p>• <strong>距离列表</strong>：查看、编辑和删除已设置的标记对距离</p>
            </div>
          </div>
        </div>

        <!-- 显示控制 -->
        <div class="flex flex-col gap-3">
          <div class="flex items-center gap-2">
            <Eye class="text-muted-foreground h-4 w-4" />
            <span class="text-sm font-medium">显示设置</span>
          </div>
          <div class="flex flex-col gap-2">
            <Button
              v-for="option in displayOptions"
              :key="option.key"
              :variant="selectedDisplays.includes(option.key) ? 'default' : 'outline'"
              :size="'sm'"
              @click="toggleDisplay(option.key)"
              class="flex w-full items-center justify-start gap-2"
            >
              <component :is="option.icon" class="h-4 w-4" />
              {{ option.label }}
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>

    <!-- 设置表单网格 -->
    <div
      v-if="
        hasSelectedDisplays &&
        (selectedDisplays.includes('pair') ||
          selectedDisplays.includes('combinations') ||
          selectedDisplays.includes('cartesian'))
      "
      class="grid grid-cols-1 gap-4 lg:grid-cols-[repeat(auto-fit,minmax(320px,1fr))] xl:grid-cols-[repeat(auto-fit,minmax(320px,1fr))]"
    >
      <!-- 单对距离设置 -->
      <div v-if="selectedDisplays.includes('pair')" class="flex flex-col">
        <PairDistanceForm class="flex-1" />
      </div>

      <!-- 组合距离设置 -->
      <div v-if="selectedDisplays.includes('combinations')" class="flex flex-col">
        <CombinationsDistanceForm class="flex-1" />
      </div>

      <!-- 笛卡尔积距离设置 -->
      <div
        v-if="selectedDisplays.includes('cartesian')"
        class="flex flex-col lg:col-span-2 xl:col-span-1"
      >
        <CartesianDistanceForm class="flex-1" />
      </div>
    </div>

    <!-- 距离列表 -->
    <div v-if="selectedDisplays.includes('pairs-list')" class="flex-1">
      <PairTablePager :limit="10" />
    </div>

    <!-- 空状态 -->
    <Card v-if="!hasSelectedDisplays" class="flex-1">
      <CardContent class="flex flex-col items-center justify-center py-12 text-center">
        <div class="bg-muted mb-4 flex h-16 w-16 items-center justify-center rounded-full">
          <EyeOff class="text-muted-foreground h-8 w-8" />
        </div>
        <h3 class="mb-2 text-lg font-semibold">未选择任何功能</h3>
        <p class="text-muted-foreground text-sm">请在上方选择要显示的距离设置功能</p>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { Ruler, Info, Eye, EyeOff, Link2, Network, Grid3x3, Table } from "lucide-vue-next";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import PairDistanceForm from "@/components/distance/PairDistanceForm.vue";
import CombinationsDistanceForm from "@/components/distance/CombinationsDistanceForm.vue";
import CartesianDistanceForm from "@/components/distance/CartesianDistanceForm.vue";
import PairTablePager from "@/components/mark/PairTablePager.vue";

// 显示选项配置
const displayOptions = [
  {
    key: "pair",
    label: "单对设置",
    icon: Link2,
  },
  {
    key: "combinations",
    label: "组合设置",
    icon: Network,
  },
  {
    key: "cartesian",
    label: "笛卡尔积",
    icon: Grid3x3,
  },
  {
    key: "pairs-list",
    label: "距离列表",
    icon: Table,
  },
];

// 选中的显示项
const selectedDisplays = ref<string[]>(["pair", "cartesian", "pairs-list"]);

// 是否有选中的显示项
const hasSelectedDisplays = computed(() => selectedDisplays.value.length > 0);

// 切换显示状态
const toggleDisplay = (key: string) => {
  const index = selectedDisplays.value.indexOf(key);
  if (index > -1) {
    selectedDisplays.value.splice(index, 1);
  } else {
    selectedDisplays.value.push(key);
  }
};
</script>
