<script setup lang="ts">
import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
  navigationMenuTriggerStyle,
} from "@/components/ui/navigation-menu";
import { Separator } from "@/components/ui/separator";
import { Map, MapPinned, History, Fence, Bookmark, Info, List } from "lucide-vue-next";

import HomeButton from "@/components/layout/HomeLogo.vue";
import ThemeToggle from "./RightControlStrip.vue";
</script>

<template>
  <div class="font-maplemono bg-accent flex h-full w-full items-center justify-between space-x-4">
    <div class="flex">
      <HomeButton class="mr-2 hidden md:flex"></HomeButton>
      <NavigationMenu>
        <NavigationMenuList>
          <NavigationMenuItem>
            <NavigationMenuTrigger class="flex items-center space-x-2">
              <Map class="h-4 w-4" />
              <span>地图</span>
            </NavigationMenuTrigger>
            <NavigationMenuContent class="w-[75vw]">
              <ul
                class="grid w-full gap-3 p-4 md:w-[400px] lg:w-[500px] lg:grid-cols-[minmax(0,.75fr)_minmax(0,1fr)]"
              >
                <li class="row-span-4">
                  <NavigationMenuLink as-child>
                    <RouterLink
                      class="from-muted/50 to-muted flex h-full w-full flex-col rounded-md bg-gradient-to-b p-6 no-underline outline-none select-none focus:shadow-md"
                      to="/map"
                    >
                      <div class="h-[40%] w-full shrink-0">
                        <Map class="h-fit w-fit" />
                      </div>
                      <div class="flex flex-1 flex-col justify-start">
                        <div class="mt-4 mb-2 text-lg font-medium">地图总览</div>
                        <p class="text-muted-foreground line-clamp-2 text-sm leading-snug">
                          实时 RTK + UWB 地图
                        </p>
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>

                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/rtk"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        实时 RTK 地图 <MapPinned class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>

                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/uwb"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        实时 UWB 地图 <MapPinned class="h-4 w-4" />
                      </div>
                    </RouterLink> </NavigationMenuLink
                  ><Separator />
                </li>

                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/rtk"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        历史轨迹 <History class="h-4 w-4" />
                      </div>
                    </RouterLink> </NavigationMenuLink
                  ><Separator />
                </li>

                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/uwb"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        电子围栏管理 <Fence class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
              </ul>
            </NavigationMenuContent>
          </NavigationMenuItem>
          <NavigationMenuItem>
            <NavigationMenuTrigger class="flex items-center space-x-2">
              <Bookmark class="h-4 w-4" />
              <span>电子标记</span>
            </NavigationMenuTrigger>
            <NavigationMenuContent class="w-[75vw]">
              <ul
                class="grid w-full gap-3 p-4 md:w-[400px] lg:w-[500px] lg:grid-cols-[minmax(0,.75fr)_minmax(0,1fr)]"
              >
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/marks/status"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div class="flex items-center justify-between text-sm font-medium">
                        标记状态 <History class="h-4 w-4" />
                      </div>

                    </RouterLink>
                  </NavigationMenuLink>
                </li>
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/marks/manage"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div class="flex items-center justify-between text-sm font-medium">
                        标记管理 <Fence class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/marks/list"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div class="flex items-center justify-between text-sm font-medium">
                        标记列表 <List class="h-4 w-4" />
                      </div>

                    </RouterLink>
                  </NavigationMenuLink>
                </li>
              </ul>
            </NavigationMenuContent>
          </NavigationMenuItem>
          <NavigationMenuItem class="hidden md:flex">
            <NavigationMenuLink :class="navigationMenuTriggerStyle()">
              <RouterLink to="/about" class="flex flex-row items-center space-x-2">
                <Info class="text- h-4 w-4" />
                <span class="">关于</span>
                <!-- 确保文字颜色也匹配 -->
              </RouterLink>
            </NavigationMenuLink>
          </NavigationMenuItem>
        </NavigationMenuList>
      </NavigationMenu>
    </div>

    <ThemeToggle class="m-1.5"></ThemeToggle>
  </div>
</template>
