class_name SolarMath
extends RefCounted
## Matemática de posición solar, reutilizable. La misma fórmula la usa
## Sol (para orientar la luz que se ve en pantalla) y cada Superficie
## de mapa (para calcular SU radiación real, con SU propia latitud).
## Una sola fórmula: si el día de mañana se corrige o se le agrega
## inclinación axial real, se corrige acá una sola vez, no en cada
## lugar que la usa.

static func calcular_elevacion_acimut(hour_of_day: float, latitude_degrees: float, declination_degrees: float) -> Dictionary:
	var hour_angle: float = deg_to_rad((hour_of_day - 12.0) * 15.0)
	var phi: float = deg_to_rad(latitude_degrees)
	var delta: float = deg_to_rad(declination_degrees)

	var sin_elevation: float = sin(phi) * sin(delta) + cos(phi) * cos(delta) * cos(hour_angle)
	sin_elevation = clamp(sin_elevation, -1.0, 1.0)
	var elevation: float = asin(sin_elevation)
	var cos_elevation: float = cos(elevation)

	var azimuth: float = 0.0
	if abs(cos_elevation) > 0.0001:
		var sin_azimuth: float = -sin(hour_angle) * cos(delta) / cos_elevation
		var cos_azimuth: float = (sin(delta) - sin(phi) * sin_elevation) / (cos(phi) * cos_elevation)
		azimuth = atan2(sin_azimuth, cos_azimuth)

	return {
		"elevation_degrees": rad_to_deg(elevation),
		"azimuth_degrees": rad_to_deg(azimuth),
		"sin_elevation": sin_elevation,
	}
