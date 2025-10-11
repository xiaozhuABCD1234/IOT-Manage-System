<template>
  <div class="flex h-full w-full flex-col items-center justify-start gap-4 md:justify-center">
    <TypeInfoCard :typeInfo="typeData" class="mt-4" /> <MarkTablePager :fetcher="fetchByType" />
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import { getMarksByTypeID, getMarkTypeByID } from "@/api/mark/type";
import MarkTablePager from "@/components/mark/MarkTablePager.vue";
import TypeInfoCard from "@/components/mark/TypeInfoCard.vue";
import type { MarkTypeResponse } from "@/types/mark";
import { ref, onMounted } from "vue";

const route = useRoute();

/* 1. 保证拿到的是数字；2. 用 computed 让 id 随路由实时变化 */
const typeId = computed(() => {
  const raw = route.params.typeId;
  const id = Array.isArray(raw) ? raw[0] : raw;
  return Number(id) || 0; // 如果转换失败就返回 0，也可以按业务抛错
});

/* fetcher 每次都会被 MarkTablePager 重新调用，所以能拿到最新的 typeId */
const fetchByType = (p: any) => getMarksByTypeID(typeId.value, p);

const typeData = ref<MarkTypeResponse>({
  id: 1,
  type_name: "警示标志",
  default_danger_zone_m: 5.0,
});

onMounted(async () => {
  try {
    const res = await getMarkTypeByID(typeId.value);
    if (res.data?.data) {
      typeData.value = res.data.data;
    }
  } catch {
  } finally {
  }
});
</script>
