//
//  ParticleTargetFitter.swift
//  ParticleNumbers
//
//  Created by Stephano Portella on 02/09/26.
//

import simd

/// Ajusta un conjunto de puntos objetivo a una cantidad exacta de partículas.
///
/// El número de píxeles que forman un dígito casi nunca coincide con la cantidad
/// de partículas, así que hay que muestrear (si sobran) o rellenar con puntos
/// aleatorios (si faltan) para que cada partícula tenga exactamente un destino.
enum ParticleTargetFitter {

    /// - Parameters:
    ///   - points: Puntos objetivo en crudo (por ejemplo los píxeles de un dígito).
    ///   - count: Cantidad de partículas a llenar.
    ///   - randomPoint: Fuente de puntos de relleno; inyectable para tests.
    /// - Returns: Un arreglo de exactamente `count` puntos (vacío si `count <= 0`).
    static func fit(
        _ points: [SIMD2<Float>],
        to count: Int,
        randomPoint: () -> SIMD2<Float> = { SIMD2(Float.random(in: -1...1), Float.random(in: -1...1)) }
    ) -> [SIMD2<Float>] {
        guard count > 0 else { return [] }

        if points.isEmpty {
            return (0..<count).map { _ in randomPoint() }
        }
        if points.count == count {
            return points
        }
        if points.count > count {
            // Muestreo uniforme: recorre la lista original a pasos fraccionarios.
            let step = Float(points.count) / Float(count)
            return (0..<count).map { i in
                points[min(points.count - 1, Int(Float(i) * step))]
            }
        }

        var result = points
        while result.count < count {
            result.append(randomPoint())
        }
        return result
    }
}
