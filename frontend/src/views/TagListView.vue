<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题卡片 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Hash class="h-5 w-5" />
              所有分组
            </CardTitle>
            <CardDescription>查看和管理所有分组的详细信息</CardDescription>
          </div>
        </div>
      </CardHeader>
    </Card>

    <!-- 分组列表 -->
    <TagTablePager :fetcher="listMarkTags" />
  </div>
</template>

<script setup lang="ts">
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Hash } from "lucide-vue-next";
import TagTablePager from "@/components/mark/TagTablePager.vue";
import { listMarkTags } from "@/api/mark/tag";
</script>
