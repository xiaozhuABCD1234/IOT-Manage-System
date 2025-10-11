<!-- StationCreateForm.vue -->
<script setup lang="ts">
import { reactive } from "vue";
import { required, helpers } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { toast } from "vue-sonner";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  NumberField,
  NumberFieldContent,
  NumberFieldDecrement,
  NumberFieldIncrement,
  NumberFieldInput,
} from "@/components/ui/number-field";

// import { StationApi } from "@/api/station";

/* -------------------------------------------------- */
/* 类型定义                                           */
/* -------------------------------------------------- */
interface FormState {
  station_name: string;
  location_x: number | null;
  location_y: number | null;
}

/* -------------------------------------------------- */
/* 表单状态 & 校验                                    */
/* -------------------------------------------------- */
const initial: FormState = {
  station_name: "",
  location_x: null,
  location_y: null,
};

const state = reactive<FormState>({ ...initial });

const rules = {
  station_name: { required: helpers.withMessage("请输入基站名称", required) },
  location_x: { required: helpers.withMessage("请输入X坐标", required) },
  location_y: { required: helpers.withMessage("请输入Y坐标", required) },
};

const v$ = useVuelidate(rules, state);

/* -------------------------------------------------- */
/* 提交                                               */
/* -------------------------------------------------- */
const emit = defineEmits<{
  created: [];
}>();

async function handleSubmit() {
  const valid = await v$.value.$validate();
  if (!valid) return;

  try {
    // await StationApi.create({
    //   station_name: state.station_name,
    //   location_x: state.location_x!,
    //   location_y: state.location_y!,
    // });
    // toast({ title: "创建成功", variant: "default" });
    // emit("created"); // 通知父组件刷新
    // Object.assign(state, initial); // 重置
    // v$.value.$reset();
  } catch (e: any) {
    toast({ title: "创建失败", description: e.message, variant: "destructive" });
  }
}
</script>

<template>
  <Card class="w-full max-w-xl">
    <CardHeader>
      <CardTitle>新建基站</CardTitle>
      <CardDescription>填写基站信息并提交</CardDescription>
    </CardHeader>

    <form @submit.prevent="handleSubmit">
      <CardContent class="space-y-4">
        <!-- 基站名称 -->
        <div class="flex flex-col gap-2">
          <Label for="stationName">基站名称</Label>
          <Input
            id="stationName"
            v-model="state.station_name"
            placeholder="例如：东区-01"
            :class="{ 'border-destructive': v$.station_name.$error }"
          />
          <span v-if="v$.station_name.$error" class="text-destructive text-sm">
            {{ v$.station_name.$errors[0].$message }}
          </span>
        </div>

        <!-- X 坐标 -->
        <div class="flex flex-col gap-2">
          <Label for="locX">X 坐标</Label>
          <NumberField
            id="locX"
            :model-value="state.location_x"
            :min="-180"
            :max="180"
            @update:model-value="(val) => (state.location_x = val)"
          >
            <NumberFieldContent>
              <NumberFieldDecrement />
              <NumberFieldInput placeholder="0" />
              <NumberFieldIncrement />
            </NumberFieldContent>
          </NumberField>
          <span v-if="v$.location_x.$error" class="text-destructive text-sm">
            {{ v$.location_x.$errors[0].$message }}
          </span>
        </div>

        <!-- Y 坐标 -->
        <div class="flex flex-col gap-2">
          <Label for="locY">Y 坐标</Label>
          <NumberField
            id="locY"
            :model-value="state.location_y"
            :min="-90"
            :max="90"
            @update:model-value="(val) => (state.location_y = val)"
          >
            <NumberFieldContent>
              <NumberFieldDecrement />
              <NumberFieldInput placeholder="0" />
              <NumberFieldIncrement />
            </NumberFieldContent>
          </NumberField>
          <span v-if="v$.location_y.$error" class="text-destructive text-sm">
            {{ v$.location_y.$errors[0].$message }}
          </span>
        </div>
      </CardContent>

      <CardFooter class="flex justify-end">
        <Button type="submit">创建</Button>
      </CardFooter>
    </form>
  </Card>
</template>
