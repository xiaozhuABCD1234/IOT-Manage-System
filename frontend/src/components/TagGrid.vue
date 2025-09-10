<template>
  <Card>
    <CardHeader>
      <CardTitle>标签列表</CardTitle>
      <CardDescription></CardDescription>
    </CardHeader>
    <CardContent>
      <div class="flex flex-wrap gap-2">
        <Badge v-for="tag in tags" :key="tag.id">
          {{ tag.tag_name }}
        </Badge>
      </div>
    </CardContent>
    <!-- <CardFooter> Card Footer </CardFooter> -->
  </Card>
</template>

<script setup lang="ts">
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

import { ref, onMounted } from "vue";
import { listMarkTags } from "@/api/markTag";
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
