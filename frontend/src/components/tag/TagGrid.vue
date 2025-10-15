<template>
  <Card class="h-full w-full">
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Hash class="h-5 w-5" />
        标签列表
      </CardTitle>
      <CardDescription>查看所有标记使用的标签</CardDescription>
    </CardHeader>
    <CardContent class="p-3 sm:p-6">
      <div class="flex flex-wrap gap-1.5 sm:gap-2">
        <RouterLink
          v-for="tag in tags"
          :key="tag.id"
          :to="`/tag/${tag.id}`"
          class="block rounded-md focus:ring-2 focus:ring-offset-2 focus:outline-none"
        >
          <Badge
            variant="secondary"
            class="hover:bg-secondary/80 cursor-pointer px-2 py-1 text-xs transition-colors sm:px-3 sm:py-1.5 sm:text-sm"
          >
            # {{ tag.tag_name }}
          </Badge>
        </RouterLink>
      </div>
      <p
        v-if="!tags || tags.length === 0"
        class="text-muted-foreground mt-2 text-center text-xs sm:text-sm"
      >
        暂无标签
      </p>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Hash } from "lucide-vue-next";
import { ref, onMounted } from "vue";
import { listMarkTags } from "@/api/mark/tag";
import type { MarkTagResponse } from "@/types/mark";

const tags = ref<MarkTagResponse[]>();

onMounted(async () => {
  try {
    const res = await listMarkTags({
      /* 需要就传分页/搜索参数 */
    });
    // 后端包在 data 里，直接取
    tags.value = res.data.data ?? [];
  } catch (e) {
    console.error("加载标签失败", e);
  }
});
</script>
