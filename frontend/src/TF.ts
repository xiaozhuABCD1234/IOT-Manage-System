"use strict";

class Point {
    constructor(public readonly lat: number, public readonly lng: number) {}
}

const earthR = 6378137.0;

function outOfChina(lat: number, lng: number): boolean {
    if (lng < 72.004 || lng > 137.8347) {
        return true;
    }
    if (lat < 0.8293 || lat > 55.8271) {
        return true;
    }
    return false;
}

function transform(x: number, y: number): Point {
    const xy = x * y;
    const absX = Math.sqrt(Math.abs(x));
    const xPi = x * Math.PI;
    const yPi = y * Math.PI;
    let d = 20.0 * Math.sin(6.0 * xPi) + 20.0 * Math.sin(2.0 * xPi);

    let lat = d;
    let lng = d;

    lat += 20.0 * Math.sin(yPi) + 40.0 * Math.sin(yPi / 3.0);
    lng += 20.0 * Math.sin(xPi) + 40.0 * Math.sin(xPi / 3.0);

    lat += 160.0 * Math.sin(yPi / 12.0) + 320 * Math.sin(yPi / 30.0);
    lng += 150.0 * Math.sin(xPi / 12.0) + 300.0 * Math.sin(xPi / 30.0);

    lat *= 2.0 / 3.0;
    lng *= 2.0 / 3.0;

    lat += -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * xy + 0.2 * absX;
    lng += 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * xy + 0.1 * absX;

    return new Point(lat, lng);
}

function delta(lat: number, lng: number): Point {
    const ee = 0.00669342162296594323;
    const d = transform(lng - 105.0, lat - 35.0);
    const radLat = lat / 180.0 * Math.PI;
    const magic = Math.sin(radLat);
    const sqrtMagic = Math.sqrt(1 - ee * magic * magic);
    const latDelta = (d.lat * 180.0) / ((earthR * (1 - ee)) / (magic * sqrtMagic) * Math.PI);
    const lngDelta = (d.lng * 180.0) / (earthR / sqrtMagic * Math.cos(radLat) * Math.PI);
    return new Point(latDelta, lngDelta);
}

// WGS to GCJ
export function wgs2gcj(wgsLat: number, wgsLng: number): Point {
    if (outOfChina(wgsLat, wgsLng)) {
        return new Point(wgsLat, wgsLng);
    }
    const d = delta(wgsLat, wgsLng);
    return new Point(wgsLat + d.lat, wgsLng + d.lng);
}

// GCJ to WGS
export function gcj2wgs(gcjLat: number, gcjLng: number): Point {
    if (outOfChina(gcjLat, gcjLng)) {
        return new Point(gcjLat, gcjLng);
    }
    const d = delta(gcjLat, gcjLng);
    return new Point(gcjLat - d.lat, gcjLng - d.lng);
}

// GCJ to WGS (exact)
export function gcj2wgs_exact(gcjLat: number, gcjLng: number): Point {
    let newLat = gcjLat;
    let newLng = gcjLng;
    let oldLat = newLat;
    let oldLng = newLng;
    const threshold = 1e-6;

    for (let i = 0; i < 30; i++) {
        oldLat = newLat;
        oldLng = newLng;
        const d = delta(newLat, newLng);
        newLat = gcjLat - d.lat;
        newLng = gcjLng - d.lng;
        if (Math.max(Math.abs(oldLat - newLat), Math.abs(oldLng - newLng)) < threshold) {
            break;
        }
    }
    return new Point(newLat, newLng);
}
