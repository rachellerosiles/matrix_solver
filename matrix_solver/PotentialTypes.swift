//
//  PotentialTypes.swift
//  matrix_solver
//
//  Created by Rachelle Rosiles on 3/12/24.
//

import Foundation

let MXVAL = 10000000.00 // global maximum value

typealias CoordTuple = (x: Double, y: Double)
typealias PotentialList = (xs: [Double], Vs: [Double])

enum PotentialType {
    case square
    case linear
    case quadratic
    case centeredQuadratic
    case squareBarrier
    case triangleBarrier
    case squarePlusLinear
    case coupledQuadratic
    case coupledSquarePlusField
    case kronigPenney
    
    func toString() -> String {
        switch self {
        case .square: return "Square Well"
        case .linear: return "Linear Well"
        case .quadratic: return "Quadratic Well"
        case .centeredQuadratic: return "Centered Quadratic Well"
        case .squareBarrier: return "Square Barrier"
        case .coupledSquarePlusField: return "Coupled Square+Field"
        case .kronigPenney: return "Kronig Penney"
        case .triangleBarrier: return "Triangle Barrier"
        case .coupledQuadratic: return "Coupled Quadratic"
        case .squarePlusLinear: return "Square+Linear"
        }
    }
}

func getPotential(xMin: Double, xMax: Double, steps: Int, type: PotentialType, amplitude: Double) -> PotentialList {
    switch type {
    case .square:
        return squareWell(xMin: xMin, xMax: xMax, steps: steps, height: amplitude)
    case .linear:
        return linearWell(xMin: xMin, xMax: xMax, steps: steps, slope: amplitude)
    case .quadratic:
        return quadraticWell(xMin: xMin, xMax: xMax, steps: steps, amplitude: amplitude)
    case .centeredQuadratic:
        return centeredQuadraticWell(xMin: xMin, xMax: xMax, steps: steps, amplitude: amplitude)
    case .squareBarrier:
        return squareBarrier(xMin: xMin, xMax: xMax, steps: steps, amplitude: amplitude)
    case .triangleBarrier:
        return triangleBarrier(xMin: xMin, xMax: xMax, steps: steps, amplitude: amplitude)
     case .squarePlusLinear:
        return squarePlusLinear(xMin: xMin, xMax: xMax, steps: steps, amplitude: amplitude)
    case .coupledSquarePlusField:
        return coupledSquarePlusField(xMin: xMin, xMax: xMax, steps: steps, amplitude: amplitude)
    case .kronigPenney:
        return kronigPenney(xMin: xMin, xMax: xMax, steps: steps, amplitude: amplitude)
    case .coupledQuadratic:
        return coupledQuadratic((xMin: xMin, xMax: xMax, steps: steps, amplitude: amplitude))
    }
}

func generalWell(xMin: Double, xMax: Double, steps: Int, potentialFunc: (Double) -> Double) -> PotentialList {
    var xs = [xMin]
    var Vs = [MXVAL]
    let stepSize = (xMax - xMin) / Double(steps)
    
    for i in 1...steps {
        let xVal = xMin + Double(i) * stepSize
        xs.append(xVal)
        Vs.append(potentialFunc(xVal))
    }
    
    xs.append(xMax)
    Vs.append(MXVAL)
    return (xs, Vs)
}

func squareWell(xMin: Double, xMax: Double, steps: Int, height: Double) -> PotentialList {
    
    return generalWell(xMin: xMin, xMax: xMax, steps: steps, potentialFunc: { _ in height })
}

func linearWell(xMin: Double, xMax: Double, steps: Int, slope: Double) -> PotentialList {
    return generalWell(xMin: xMin, xMax: xMax, steps: steps, potentialFunc: { slope * $0 })
}

func quadraticWell(xMin: Double, xMax: Double, steps: Int, amplitude: Double) -> PotentialList {
    return generalWell(xMin: xMin, xMax: xMax, steps: steps, potentialFunc: { amplitude * $0 * $0 })
}

func centeredQuadraticWell(xMin: Double, xMax: Double, steps: Int, amplitude: Double) -> PotentialList {
    return generalWell(xMin: xMin, xMax: xMax, steps: steps) { x in
        let mid = (xMin + xMax) / 2
        return (x > 0.5 * mid && x < 1.5 * mid) ? amplitude * (x - mid) * (x - mid) : 0
    }
}

func coupledSquarePlusField(xMin: Double, xMax: Double, steps: Int, amplitude: Double) -> PotentialList {
    var positions: [Double] = []
    var potentials: [Double] = [MXVAL]  // Start with a very high value

    let increment = (xMax - xMin) / Double(steps)

    // Add initial position
    positions.append(xMin)

    // First segment: zero potential
    for value in stride(from: xMin + increment, to: xMin + (xMax - xMin) * 0.4, by: increment) {
        positions.append(value)
        potentials.append(0.0)
    }

    // Second segment: constant potential
    for value in stride(from: xMin + (xMax - xMin) * 0.4, to: xMin + (xMax - xMin) * 0.6, by: increment) {
        positions.append(value)
        potentials.append(amplitude)
    }

    // Third segment: zero potential again
    for value in stride(from: xMin + (xMax - xMin) * 0.6, to: xMax, by: increment) {
        positions.append(value)
        potentials.append(0.0)
    }

    // Final position
    positions.append(xMax)
    potentials.append(MXVAL)

    return (xs: positions, Vs: potentials)
}

func squareBarrier(xMin: Double, xMax: Double, steps: Int, amplitude: Double) -> PotentialList {
    var coordinates: [Double] = []
    var potentialValues: [Double] = []
    let deltaX = (xMax - xMin) / Double(steps)

    // Initialize with the starting and ending boundary conditions
    coordinates.append(xMin)
    potentialValues.append(MXVAL)

    for index in 1...steps {
        let currentCoordinate = xMin + Double(index) * deltaX
        
        // Check if current coordinate is within the barrier range
        if (currentCoordinate >= (xMin + (xMax - xMin) * 0.4) &&
            currentCoordinate <= (xMin + (xMax - xMin) * 0.6)) {
            potentialValues.append(amplitude)  // Inside the barrier
        } else {
            potentialValues.append(0.0)  // Outside the barrier
        }
        
        coordinates.append(currentCoordinate)
    }

    // Add the endpoint values
    coordinates.append(xMax)
    potentialValues.append(MXVAL)

    return (coordinates, potentialValues)
}

func squarePlusLinear(xMin: Double, xMax: Double, steps: Int, amplitude: Double) -> PotentialList {
    var positions: [Double] = [xMin]
    var potentials: [Double] = [MXVAL] // Start with a very high value

    let deltaX = (xMax - xMin) / Double(steps)

    // Zero potential region
    for index in 1..<steps / 2 {
        let currentX = xMin + deltaX * Double(index)
        positions.append(currentX)
        potentials.append(0.0)
    }

    // Linear potential region
    for index in (steps / 2)..<steps {
        let currentX = xMin + deltaX * Double(index)
        positions.append(currentX)
        potentials.append((currentX - (xMin + xMax) / 2.0) * amplitude)
    }

    // Append the maximum x value
    positions.append(xMax)
    potentials.append(MXVAL)

    return (xs: positions, Vs: potentials)
}

func kronigPenney(xMin: Double, xMax: Double, steps: Int, amplitude: Double) -> PotentialList {
    var positions: [Double] = [xMin]
    var potentials: [Double] = [MXVAL]

    let totalSteps = Double(steps)
    let stepSize = (xMax - xMin) / totalSteps
    let barrierCount = 2.0
    let barrierHeight = amplitude
    let spacingBetweenBarriers = xMax / barrierCount
    let widthOfBarrier = (1.0 / 6.0) * spacingBetweenBarriers

    for step in 1...steps {
        let currentX = xMin + Double(step) * stepSize
        let barrierCenter = -spacingBetweenBarriers / 2.0 + (Double(step - 1) * spacingBetweenBarriers)

        //are within the barrier?
        if abs(currentX - barrierCenter) < (widthOfBarrier / 2.0) {
            positions.append(currentX)
            potentials.append(barrierHeight)
        } else {
            positions.append(currentX)
            potentials.append(0.0)
        }
    }
    positions.append(xMax)
    potentials.append(MXVAL)
    return (xs: positions, Vs: potentials)
}

func triangleBarrier(xMin: Double, xMax: Double, steps: Int, amplitude: Double) -> PotentialList {
   
    return generalWell(xMin: xMin, xMax: xMax, steps: steps) { x in
        if x > 0.4 * xMax && x < 0.5 * xMax {
            return amplitude * (x - 0.4 * xMax)
        } else if x >= 0.5 * xMax && x <= 0.6 * xMax {
            return -amplitude * (x - 0.6 * xMax)
        }
        return 0.0
    }
    
func coupledQuadratic(xMin: Double, xMax: Double, steps: Int, amplitude: Double) -> PotentialList {
        var positions: [Double] = [xMin]
        var potentials: [Double] = [MXVAL]
        let deltaX = (xMax - xMin) / Double(steps)
        let midpoint = (xMin + xMax) / 2.0

        for i in 0..<steps {
            let currentX = xMin + deltaX * Double(i + 1)
            if currentX < midpoint {
                positions.append(currentX)
                let adjustedPotential = amplitude * pow((currentX - (xMin + (xMax - xMin) / 4.0)), 2.0)
                potentials.append(adjustedPotential)
            }
        }
        for i in 0..<steps {
            let currentX = midpoint + deltaX * Double(i)
            if currentX <= xMax {
                positions.append(currentX)
                let adjustedPotential = amplitude * pow((currentX - (xMax - (xMax - xMin) / 4.0)), 2.0)
                potentials.append(adjustedPotential)
            }
        }
        positions.append(xMax)
        potentials.append(MXVAL)

        return (xs: positions, Vs: potentials)
    }
}
