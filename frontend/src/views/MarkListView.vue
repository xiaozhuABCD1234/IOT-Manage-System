<template>
  <div class="flex h-full w-full flex-col items-center justify-start gap-4 md:justify-center">
    <Card class="mx-auto w-full max-w-4xl">
      <CardHeader>
        <CardTitle class="text-center text-2xl">所有标记</CardTitle>
      </CardHeader>
    </Card>
    <MarkTablePager :fetcher="listMarks" />
  </div>
</template>

<script setup lang="ts">
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import MarkTablePager from "@/components/mark/MarkTablePager.vue";
import { listMarks } from "@/api/mark";
</script>
