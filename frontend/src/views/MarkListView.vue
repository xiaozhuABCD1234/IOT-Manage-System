<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题卡片 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Tag class="h-5 w-5" />
              所有标记
            </CardTitle>
            <CardDescription>查看和管理所有标记的详细信息</CardDescription>
          </div>
        </div>
      </CardHeader>
    </Card>

    <!-- 标记列表 -->
    <MarkTablePager :fetcher="listMarks" />
  </div>
</template>

<script setup lang="ts">
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Tag } from "lucide-vue-next";
import MarkTablePager from "@/components/mark/MarkTablePager.vue";
import { listMarks } from "@/api/mark";
</script>
