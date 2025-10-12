<script setup lang="ts">
import Autoplay from "embla-carousel-autoplay";
import { Carousel, CarouselContent, CarouselItem } from "@/components/ui/carousel";

const plugin = Autoplay({ delay: 2000, stopOnMouseEnter: true, stopOnInteraction: false });
</script>

<template>
  <!-- 全屏轮播 -->
  <Carousel
    class="h-full w-full"
    :opts="{ loop: true }"
    :plugins="[plugin]"
    @mouseenter="plugin.stop"
    @mouseleave="[plugin.reset(), plugin.play()]"
  >
    <CarouselContent class="h-[calc(100vh-3rem)]">
      <!-- 第 1 张 -->
      <CarouselItem class="relative h-full w-full">
        <div class="h-full w-full bg-cover bg-center" style="background-image: url(/img/map.jpg)">
          <div class="absolute inset-0 bg-black/30" />
          <!-- 蒙层，可选 -->
          <div class="relative flex h-full items-center justify-center">
            <h1 class="text-5xl font-bold text-white">地图</h1>
          </div>
        </div>
      </CarouselItem>

      <!-- 第 2 张 -->
      <CarouselItem class="relative h-full w-full">
        <div class="h-full w-full bg-cover bg-center" style="background-image: url(/img/tags.jpg)">
          <div class="absolute inset-0 bg-black/30" />
          <div class="relative flex h-full items-center justify-center">
            <h1 class="text-5xl font-bold text-white">标签管理</h1>
          </div>
        </div>
      </CarouselItem>

      <CarouselItem class="relative h-full w-full">
        <div class="h-full w-full bg-cover bg-center" style="background-image: url(/img/tags.jpg)">
          <div class="absolute inset-0 bg-black/30" />
          <div class="relative flex h-full items-center justify-center">
            <h1 class="text-5xl font-bold text-white">实时报警</h1>
          </div>
        </div>
      </CarouselItem>
    </CarouselContent>
  </Carousel>
</template>

<style lang="css" scoped>
:deep(.embla__container) {
  height: 100%;
}
</style>
