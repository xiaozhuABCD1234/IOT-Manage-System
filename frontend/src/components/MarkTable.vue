<script setup lang="ts">
import type { MarkResponse } from "@/types/mark";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ScrollArea } from "@/components/ui/scroll-area";

defineProps<{
  rows: MarkResponse[];
}>();
</script>

<template>
  <ScrollArea class="mx-auto mb-4 h-auto w-full max-w-4xl flex-1 rounded-md border">
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>设备ID</TableHead>
          <TableHead>标签名称</TableHead>
          <TableHead>类型</TableHead>
          <TableHead>标签</TableHead>
          <TableHead>最后在线时间</TableHead>
        </TableRow>
      </TableHeader>

      <TableBody>
        <TableRow
          v-for="mark in rows"
          :key="mark.id"
          class="h-15 border transition-colors hover:bg-gray-200 dark:hover:bg-gray-700"
        >
          <TableCell>{{ mark.device_id }}</TableCell>
          <TableCell>{{ mark.mark_name }}</TableCell>
          <TableCell>{{ mark.mark_type?.type_name || "-" }}</TableCell>
          <TableCell>
            <div class="flex flex-wrap gap-1">
              <template v-if="mark.tags?.length">
                <Badge v-for="tag in mark.tags" :key="tag.id" variant="outline">
                  {{ tag.tag_name }}
                </Badge>
              </template>
              <span v-else>-</span>
            </div>
          </TableCell>
          <TableCell>
            {{ mark.last_online_at ? new Date(mark.last_online_at).toLocaleString() : "从未上线" }}
          </TableCell>
        </TableRow>
      </TableBody>
    </Table>
  </ScrollArea>
</template>
