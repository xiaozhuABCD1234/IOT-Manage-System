<template>
  <TypeInfoCard :typeInfo="typeData" />
  <MarkTablePager :fetcher="fetchByType" />
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import { getMarksByTypeID } from "@/api/markType";
import MarkTablePager from "@/components/MarkTablePager.vue";
import TypeInfoCard from "@/components/mark/TypeInfoCard.vue";
import type { MarkTypeResponse } from "@/types/mark";
import { ref, onMounted } from "vue";
import { getMarkTypeByID } from "@/api/markType";

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
  default_safe_distance_m: 5.0,
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
