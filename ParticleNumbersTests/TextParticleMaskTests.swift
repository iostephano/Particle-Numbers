//
//  TextParticleMaskTests.swift
//  ParticleNumbersTests
//
//  Created by Stephano Portella on 02/09/26.
//

import Testing
import simd
@testable import ParticleNumbers

@MainActor
struct TextParticleMaskTests {

    @Test("An empty string produces no points")
    func emptyString() {
        #expect(TextParticleMask.points(for: "").isEmpty)
    }

    @Test("A digit produces points, all inside the normalized square")
    func pointsAreNormalized() {
        let points = TextParticleMask.points(for: "8")

        #expect(!points.isEmpty)
        for p in points {
            #expect(p.x >= -1 && p.x <= 1)
            #expect(p.y >= -1 && p.y <= 1)
        }
    }

    @Test("A denser glyph yields more points than a sparse one")
    func inkDensityMatters() {
        let eight = TextParticleMask.points(for: "8").count
        let one = TextParticleMask.points(for: "1").count
        #expect(eight > one)
    }

    @Test("A tall digit spans most of the vertical range")
    func verticalSpread() {
        let ys = TextParticleMask.points(for: "0").map(\.y)
        let spread = (ys.max() ?? 0) - (ys.min() ?? 0)
        #expect(spread > 1.0)
    }

    @Test("Two digits are wider than one")
    func widthGrowsWithDigits() {
        let oneWidth = span(of: TextParticleMask.points(for: "7").map(\.x))
        let twoWidth = span(of: TextParticleMask.points(for: "77").map(\.x))
        #expect(twoWidth > oneWidth)
    }

    private func span(of values: [Float]) -> Float {
        guard let lo = values.min(), let hi = values.max() else { return 0 }
        return hi - lo
    }
}
