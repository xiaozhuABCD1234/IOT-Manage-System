package utils

import (
	"math"

	"IOT-Manage-System/warning-service/model"
)

const earthRadius float64 = 6371393

func toRadians(degree float64) float64 {
	return degree * math.Pi / 180.0
}

func CalculateRTK(l1, l2 model.RTKLoc) float64 {
	dLat := toRadians(l1.Lat - l2.Lat)
	dLon := toRadians(l1.Lon - l2.Lon)

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(toRadians(l1.Lat))*math.Cos(toRadians(l2.Lat))*
			math.Sin(dLon/2)*math.Sin(dLon/2)

	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return earthRadius * c
}

func CalculateUWB(l1, l2 model.UWBLoc) float64 {
	dx := (l1.X - l2.X) / 100.0
	dy := (l1.Y - l2.Y) / 100.0
	return math.Sqrt(dx*dx + dy*dy)
}


