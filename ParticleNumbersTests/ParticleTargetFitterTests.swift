//
//  ParticleTargetFitterTests.swift
//  ParticleNumbersTests
//
//  Created by Stephano Portella on 02/09/26.
//

import Testing
import simd
@testable import ParticleNumbers

struct ParticleTargetFitterTests {

    private func line(_ n: Int) -> [SIMD2<Float>] {
        (0..<n).map { SIMD2(Float($0), 0) }
    }

    @Test("A count of zero yields no targets")
    func zeroCount() {
        #expect(ParticleTargetFitter.fit(line(10), to: 0).isEmpty)
    }

    @Test("An exact match is returned untouched")
    func exactMatch() {
        let points = line(5)
        #expect(ParticleTargetFitter.fit(points, to: 5) == points)
    }

    @Test("Empty input is filled entirely from the random source")
    func emptyInputPadsWithRandom() {
        let filler = SIMD2<Float>(9, 9)
        let result = ParticleTargetFitter.fit([], to: 4, randomPoint: { filler })
        #expect(result == Array(repeating: filler, count: 4))
    }

    @Test("Fewer points than particles keeps the originals and pads the rest")
    func fewerPointsPadTail() {
        let filler = SIMD2<Float>(-1, -1)
        let result = ParticleTargetFitter.fit(line(3), to: 6, randomPoint: { filler })

        #expect(result.count == 6)
        #expect(Array(result.prefix(3)) == line(3))
        #expect(Array(result.suffix(3)) == Array(repeating: filler, count: 3))
    }

    @Test("More points than particles are down-sampled across the whole range")
    func morePointsDownsample() {
        let result = ParticleTargetFitter.fit(line(100), to: 10)

        #expect(result.count == 10)
        // Every kept point comes from the input, in ascending order, spanning it.
        #expect(result.first == SIMD2<Float>(0, 0))
        #expect(result.last!.x >= 81)
        #expect(result.map(\.x) == result.map(\.x).sorted())
    }

    @Test("Padding never overruns the requested count")
    func noOverrun() {
        #expect(ParticleTargetFitter.fit(line(7), to: 7).count == 7)
        #expect(ParticleTargetFitter.fit(line(1), to: 2000).count == 2000)
    }
}
