<script setup lang="ts">
import { Sun, Moon, UserRound } from "lucide-vue-next";
import { useColorMode } from "@vueuse/core";
import { Button } from "@/components/ui/button";
import { HoverCard, HoverCardContent, HoverCardTrigger } from "@/components/ui/hover-card";

const mode = useColorMode(); // light | dark | auto
</script>

<template>
  <div class="flex gap-2">
    <HoverCard>
      <HoverCardTrigger>
        <RouterLink to="/profile">
          <Button variant="outline" size="icon"> <UserRound class="h-5 w-5" /> </Button
        ></RouterLink>
      </HoverCardTrigger>
      <HoverCardContent>
        <div class="space-y-1">
          <h4 class="text-sm font-semibold">用户资料</h4>
          <p class="text-muted-foreground text-sm">悬停查看更多信息，点击按钮可跳转到个人中心。</p>
        </div>
      </HoverCardContent></HoverCard
    >

    <Button
      variant="outline"
      size="icon"
      class="rounded-md p-2"
      @click="mode = mode === 'light' ? 'dark' : 'light'"
    >
      <Sun v-if="mode === 'light'" class="h-5 w-5" />
      <Moon v-else class="h-5 w-5" />
    </Button>
  </div>
</template>
