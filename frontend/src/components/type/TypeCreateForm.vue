<template>
  <form @submit="onSubmit" class="space-y-4">
    <FormField v-slot="{ componentField }" name="type_name">
      <FormItem>
        <FormLabel>类型名称</FormLabel>
        <FormControl>
          <Input type="text" placeholder="输入类型名称" v-bind="componentField" />
        </FormControl>
        <FormMessage />
      </FormItem>
    </FormField>

    <FormField v-slot="{ componentField }" name="default_danger_zone_m">
      <FormItem>
        <FormLabel>默认安全距离（米）</FormLabel>
        <FormControl>
          <Input type="number" step="0.1" placeholder="可选" v-bind="componentField" />
        </FormControl>
        <FormMessage />
      </FormItem>
    </FormField>

    <Button type="submit" :disabled="isSubmitting">创建</Button>
  </form>
</template>

<script setup lang="ts">
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import * as z from "zod";
import { FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { toast } from "vue-sonner";
import { createMarkType } from "@/api/mark/type";

const validationSchema = toTypedSchema(
  z.object({
    type_name: z.string().min(1, "类型名称不能为空").max(255),
    default_danger_zone_m: z.preprocess((val) => {
      const num = Number(val);
      return isNaN(num) ? undefined : num;
    }, z.number().nonnegative().optional()),
  }),
);

const { handleSubmit, isSubmitting } = useForm({
  validationSchema,
});

const onSubmit = handleSubmit(async (values) => {
  console.log("提交数据:", values);
  try {
    await createMarkType(values); // 对象就是 JSON，自动进 body
    toast.success("创建成功", {
      description: values.type_name,
    });
  } catch (e: any) {}
});
</script>
