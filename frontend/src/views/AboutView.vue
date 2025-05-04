<template>
  <div>
    <div v-for="(point, index) in points" :key="index" class="point">
      点 {{ index + 1 }}：({{ point.lng }}, {{ point.lat }})
      <div v-for="(otherPoint, otherIndex) in points" :key="otherIndex">
        到点 {{ otherIndex + 1 }} 的距离：{{ getDistance(point, otherPoint) }} km
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

interface GeoPoint {
  lng: number;
  lat: number;
}

const points = ref<GeoPoint[]>([
  { lng: 116.404, lat: 39.915 },
  { lng: 116.405, lat: 39.920 },
  { lng: 116.406, lat: 39.925 },
  { lng: 116.407, lat: 39.930 }
]);

const getDistance = (point1: GeoPoint, point2: GeoPoint): string => {
  const R = 6371; // 地球半径，单位为千米
  const dLat = (point2.lat - point1.lat) * Math.PI / 180;
  const dLon = (point2.lng - point1.lng) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(point1.lat * Math.PI / 180) *
      Math.cos(point2.lat * Math.PI / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;
  return distance.toFixed(2);
};
</script>

<style>
.point {
  margin-bottom: 10px;
  padding: 10px;
  background-color: #f5f5f5;
  border-radius: 4px;
}
</style>
