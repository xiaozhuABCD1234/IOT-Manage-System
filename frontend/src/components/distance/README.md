# 距离设置组件

3个用于设置标记对安全距离的组件，使用 shadcn-vue 和 Lucide 图标构建。

## 组件列表

### 1. PairDistanceForm - 单对距离设置

为两个标记之间设置安全距离。

**使用示例：**

```vue
<script setup>
import { PairDistanceForm } from "@/components/distance";
</script>

<template>
  <PairDistanceForm />
</template>
```

**API调用：**

- `getAllMarkIDToName()` - 获取所有标记ID到名称的映射
- `setPairDistance()` - 设置单对标记距离

### 2. CombinationsDistanceForm - 组合距离设置

为多个标记之间批量设置统一的安全距离（两两组合）。

**使用示例：**

```vue
<script setup>
import { CombinationsDistanceForm } from "@/components/distance";
</script>

<template>
  <CombinationsDistanceForm />
</template>
```

**API调用：**

- `getAllMarkIDToName()` - 获取所有标记ID到名称的映射
- `setCombinationsDistance()` - 批量设置标记组合距离

### 3. CartesianDistanceForm - 笛卡尔积距离设置

为两组标记、标签或类型之间批量设置距离（笛卡尔积方式）。

**使用示例：**

```vue
<script setup>
import { CartesianDistanceForm } from "@/components/distance";
</script>

<template>
  <CartesianDistanceForm />
</template>
```

**API调用：**

- `getAllMarkIDToName()` - 获取所有标记ID到名称的映射
- `getAllTagIDToName()` - 获取所有标签ID到名称的映射
- `getAllTypeIDToName()` - 获取所有类型ID到名称的映射
- `setCartesianDistance()` - 笛卡尔积方式设置距离

## 完整使用示例

```vue
<template>
  <div class="container mx-auto space-y-6 p-6">
    <div class="space-y-2">
      <h1 class="text-3xl font-bold">距离设置管理</h1>
      <p class="text-muted-foreground">配置标记、标签和类型之间的安全距离</p>
    </div>

    <div class="grid grid-cols-1 gap-6 lg:grid-cols-2 xl:grid-cols-3">
      <PairDistanceForm />
      <CombinationsDistanceForm />
      <CartesianDistanceForm />
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  PairDistanceForm,
  CombinationsDistanceForm,
  CartesianDistanceForm,
} from "@/components/distance";
</script>
```

## 路由配置

访问路径: `/marks/distance`

## 功能特性

✅ 响应式设计，支持移动端和桌面端  
✅ 实时表单验证  
✅ 加载状态提示  
✅ 成功/错误提示  
✅ 表单重置功能  
✅ 使用 shadcn-vue 组件库  
✅ Lucide 图标集成  
✅ TypeScript 类型安全

## 错误处理

- 如果后端API不可用，组件会显示友好的错误提示
- 表单会自动禁用，防止提交无效数据
- 错误信息包含API端点路径，方便排查问题

## 图标说明

- **Link2** - 单对距离设置
- **Network** - 组合距离设置
- **Grid3x3** - 笛卡尔积距离设置
- **Save** - 保存按钮
- **RotateCcw** - 重置按钮
