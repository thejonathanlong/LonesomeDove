//
//  SeededNumberGenerator.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/25/21.
//

import GameplayKit

class SeededNumberGenerator: RandomNumberGenerator {
    let seed: UInt64
    private let generator: GKMersenneTwisterRandomSource
    convenience init() {
        self.init(seed: 0)
    }

    init(seed: UInt64) {
        self.seed = seed
        generator = GKMersenneTwisterRandomSource(seed: seed)
    }

    func next() -> UInt64 {
        return UInt64(abs(generator.nextInt()))
    }
//    func next<T>(upperBound: T) -> T where T : FixedWidthInteger, T : UnsignedInteger {
//        return T(abs(generator.nextInt(upperBound: Int(upperBound))))
//    }
//
//    func next<T>() -> T where T : FixedWidthInteger, T : UnsignedInteger {

//    }
}
