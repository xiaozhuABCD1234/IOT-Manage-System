<template>
  <div
    class="grid gap-4 p-4"
    :style="{ gridTemplateColumns: `repeat(auto-fill, minmax(${cardMinW}px, 1fr))` }"
  >
    <Card v-for="t in types" :key="t.id" class="p-3">
      <h3 class="text-sm font-semibold">{{ t.type_name }}</h3>
      <p class="text-muted-foreground text-xs">安全距离：{{ t.default_safe_distance_m }} m</p>
    </Card>
  </div>

  <!-- 底部提示 -->
  <div class="text-muted-foreground py-4 text-center text-xs">
    <span v-if="loading">加载中…</span>
    <span v-else-if="finished">没有更多了</span>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Card } from "@/components/ui/card";
import { listMarkTypes } from "@/api/markType";
import type { MarkTypeResponse } from "@/types/mark";

/* ---------- 状态 ---------- */
const types = ref<MarkTypeResponse[]>([]);
const cardMinW = 150;
const loading = ref(false);
const finished = ref(false);
const page = ref(1);
const SIZE = 20; // 每页条数

/* ---------- 拉数据 ---------- */
async function loadNext() {
  if (loading.value || finished.value) return;
  loading.value = true;
  try {
    const { data } = await listMarkTypes({ page: page.value, limit: SIZE });
    const list = data.data ?? [];
    types.value.push(...list);
    // 后端返回不足一页说明到底了
    if (list.length < SIZE) finished.value = true;
    else page.value += 1;
  } finally {
    loading.value = false;
  }
}

/* ---------- 滚动到底检测 ---------- */
function onScroll(e: Event) {
  const el = e.target as HTMLElement;
  const { scrollTop, scrollHeight, clientHeight } = el;
  // 距离底部 <= 60px 就触发
  if (scrollHeight - scrollTop - clientHeight <= 60) {
    loadNext();
  }
}

/* ---------- 首次 ---------- */
onMounted(() => loadNext());
</script>
