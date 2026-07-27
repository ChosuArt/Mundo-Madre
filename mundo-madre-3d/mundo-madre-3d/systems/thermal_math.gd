class_name ThermalMath
extends RefCounted
## Fórmula de intercambio térmico compartida. La usa tanto Superficie
## (terreno real, con malla y posición propias) como cualquier vecino
## nominal del sistema de viento (un bioma fijo que NO existe como
## escena, solo como dato) — mismo cálculo causal en ambos casos.

static func calcular_radiacion(day_factor: float, max_radiacion: float, bioma: PerfilBioma, altitude_meters: float = 0.0) -> float:
	var atenuacion_altitud: float = clamp(1.0 - altitude_meters / 20000.0, 0.0, 1.0)
	return max_radiacion * day_factor * (1.0 - bioma.albedo) * atenuacion_altitud


static func calcular_delta_temperatura(temperatura_actual: float, radiacion_recibida: float, bioma: PerfilBioma, delta_sim_seconds: float) -> float:
	var perdida: float = (temperatura_actual - bioma.temperatura_referencia) * 0.08
	var delta_temp: float = (radiacion_recibida * 0.01 - perdida) / bioma.resistencia_termica
	return delta_temp * (delta_sim_seconds / 3600.0)
