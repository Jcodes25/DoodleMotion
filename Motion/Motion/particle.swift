//
//  particle.swift
//  Motion
//
//  Created by Jordan Barconey on 10/6/22.
//

import Foundation

struct Particle: Hashable {
    let x: Double
    let y: Double
    let creationDate = Date.now.timeIntervalSinceReferenceDate
    let hue: Double
}
