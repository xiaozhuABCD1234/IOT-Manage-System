<template>
  <Card class="h-full w-full">
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Hash class="h-5 w-5" />
        标签列表
      </CardTitle>
      <CardDescription>查看所有标记使用的标签</CardDescription>
    </CardHeader>
    <CardContent>
      <div class="flex flex-wrap gap-2">
        <Badge v-for="tag in tags" :key="tag.id" variant="secondary" class="text-sm">
          # {{ tag.tag_name }}
        </Badge>
      </div>
      <p v-if="!tags || tags.length === 0" class="text-muted-foreground text-center text-sm">
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
