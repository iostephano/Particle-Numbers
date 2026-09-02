//
//  TextParticleMask.swift
//  ParticleNumbers
//
//  Created by Stephano Portella on 02/09/26.
//

import UIKit
import simd

/// Convierte un texto en una nube de puntos normalizados (`-1...1`, con Y hacia
/// arriba como en Metal) que cubren sus glifos.
///
/// El texto se rasteriza a una máscara en escala de grises y se recolecta cada
/// píxel encendido; esos puntos son los destinos a los que viajan las partículas.
enum TextParticleMask {

    /// - Parameters:
    ///   - text: Texto a rasterizar (aquí, un número de 0 a 99).
    ///   - fontSize: Tamaño de fuente para la máscara; más grande = más detalle.
    /// - Returns: Puntos en coordenadas normalizadas de Metal. Vacío si el texto
    ///   no produce una máscara con área.
    @MainActor
    static func points(for text: String, fontSize: CGFloat = 200) -> [SIMD2<Float>] {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attributed = NSAttributedString(
            string: text,
            attributes: [.font: font, .foregroundColor: UIColor.white]
        )
        let textSize = attributed.size()
        guard textSize.width >= 1, textSize.height >= 1 else { return [] }

        // Rasteriza el texto (blanco sobre negro) en un contexto de imagen.
        UIGraphicsBeginImageContextWithOptions(textSize, true, 1.0)
        guard let imageContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return []
        }
        imageContext.setFillColor(UIColor.black.cgColor)
        imageContext.fill(CGRect(origin: .zero, size: textSize))
        attributed.draw(at: .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return [] }

        // Redibuja en un contexto de 8 bits en gris para leer los píxeles.
        let width = cgImage.width
        let height = cgImage.height
        var mask = [UInt8](repeating: 0, count: width * height)
        guard let grayContext = CGContext(
            data: &mask,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return []
        }
        grayContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var points: [SIMD2<Float>] = []
        points.reserveCapacity(width * height / 8)
        for row in 0..<height {
            for col in 0..<width where mask[row * width + col] > 50 {
                let x = Float(col) / Float(width) * 2 - 1
                // CGContext dibuja de abajo hacia arriba, así que la fila 0 ya es
                // la base del texto; invertir Y la deja hacia arriba como Metal.
                let y = Float(height - row) / Float(height) * 2 - 1
                points.append(SIMD2(x, y))
            }
        }
        return points
    }
}
