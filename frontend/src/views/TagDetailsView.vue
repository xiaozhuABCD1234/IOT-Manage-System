<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 分组信息卡片 -->
    <TagInfoCard :tagInfo="tagData" @updated="loadTagData" />

    <!-- 标记列表 -->
    <MarkTablePager :fetcher="fetchByTag" />
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { getMarksByTagID, getMarkTagByID } from "@/api/mark/tag";
import MarkTablePager from "@/components/mark/MarkTablePager.vue";
import TagInfoCard from "@/components/mark/TagInfoCard.vue";
import type { MarkTagResponse } from "@/types/mark";

const route = useRoute();

/* 1. 保证拿到的是数字；2. 用 computed 让 id 随路由实时变化 */
const tagId = computed(() => {
  const raw = route.params.tagId;
  const id = Array.isArray(raw) ? raw[0] : raw;
  return Number(id) || 0; // 如果转换失败就返回 0，也可以按业务抛错
});

/* fetcher 每次都会被 MarkTablePager 重新调用，所以能拿到最新的 tagId */
const fetchByTag = (p: any) => getMarksByTagID(tagId.value, p);

const tagData = ref<MarkTagResponse>({
  id: 1,
  tag_name: "示例分组",
});

async function loadTagData() {
  try {
    const res = await getMarkTagByID(tagId.value);
    if (res.data?.data) {
      tagData.value = res.data.data;
    }
  } catch {
  } finally {
  }
}

onMounted(async () => {
  await loadTagData();
});
</script>
