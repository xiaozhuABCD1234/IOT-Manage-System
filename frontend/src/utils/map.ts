import type { Ref } from "vue";
import type { Device } from "./mqtt";

const COLORS = ["#1890ff", "#52c41a", "#fadb14", "#ff4d4f", "#722ed1"];

export const createDevice = (map: AMap.Map, id: string, lng: number, lat: number): Device => {
  const idx = id.split("").reduce((sum, c) => sum + c.charCodeAt(0), 0) % COLORS.length;
  const color = COLORS[idx];

  const polyline = new AMap.Polyline({
    path: [[lng, lat]],
    strokeColor: color,
    strokeWeight: 3,
    lineJoin: "round",
  });

  const marker = new AMap.Marker({
    position: [lng, lat],
    content: `
      <div class="
        w-6 h-6 rounded-full flex items-center justify-center text-xs text-white
        shadow-md cursor-pointer
      " style="background:${color}">${id}</div>`,
    offset: new AMap.Pixel(-12, -12),
  });

  map.add([polyline, marker]);

  return { id, path: [[lng, lat]], polyline, marker };
};

export const updateDevicePosition = (
  map: AMap.Map,
  devices: Ref<Device[]>,
  id: string,
  lng: number,
  lat: number,
) => {
  let device = devices.value.find((d) => d.id === id);
  if (!device) {
    device = createDevice(map, id, lng, lat);
    devices.value.push(device);
  } else {
    const newPath = [...device.path, [lng, lat] as [number, number]];
    device.path = newPath;
    device.polyline.setPath(newPath);
    device.marker.setPosition([lng, lat]);
  }
};
