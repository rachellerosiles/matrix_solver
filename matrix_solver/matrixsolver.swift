//
//  matrixsolver.swift
//  matrix_solver
//
//  Created by Rachelle Rosiles on 3/12/24.
//

import Foundation

typealias ComplexValue = (realPart: Double, imaginaryPart: Double)

class MatrixSolver: NSObject, ObservableObject {
    
    @Published var realResults: [[Double]] = []
    @Published var imaginaryResults: [[Double]] = []
    @Published var potentialArray: [Double] = []
    @Published var eigenEnergyLevels: [Double] = []
    
    func solveQuantumEquation(potentialWidth: Double, numSteps: Int, potentialType: PotentialType, potentialAmplitude: Double, numStates: Int) {
        let potentialData = evaluatePotential(minimum: 0.0, maximum: potentialWidth, steps: numSteps, type: potentialType, amplitude: potentialAmplitude)
        let hamiltonianMatrix = generateHamiltonian(width: potentialWidth, steps: numSteps, potentialData: potentialData, states: numStates)
        
        displayPotentialPlot(potential: potentialData)
        
        let eigenResults = computeEigenvaluesAndVectors(matrix: hamiltonianMatrix)
        eigenEnergyLevels.append(contentsOf: eigenResults.eigenvalues)
        storeSolutions(xCoordinates: potentialData.xValues, functions: eigenResults.eigenvectors)
    }
    
    func evaluatePotential(minimum: Double, maximum: Double, steps: Int, type: PotentialType, amplitude: Double) -> PotentialList {
        return getPotential(xMin: minimum, xMax: maximum, steps: steps, choice: type, amplitude: amplitude)
    }
    
    func generateHamiltonian(width: Double, steps: Int, potentialData: PotentialList, states: Int) -> [[Double]] {
        var hamiltonian: [[Double]] = Array(repeating: Array(repeating: 0.0, count: states), count: states)
        
        for row in 0..<states {
            for col in 0..<states {
                hamiltonian[row][col] = calculateMatrixElement(row: row, col: col, potential: potentialData, width: width, states: states)
            }
        }
        
        return hamiltonian
    }
    
    func calculateMatrixElement(row: Int, col: Int, potential: PotentialList, width: Double, states: Int) -> Double {
        let basisFuncRow = potential.Vs[row]
        let basisFuncCol = potential.Vs[col]
        let totalPotential = potential.Vs.reduce(0.0, +)
        
        return width * basisFuncRow * basisFuncCol + (row == col ? -totalPotential : 0)
    }
    
    func computeEigenvaluesAndVectors(matrix: [[Double]]) -> (eigenvalues: [Double], eigenvectors: [[Double]]) {
        return ([], [])
    }
    
    func displayPotentialPlot(potential: PotentialList) {
        potentialArray = potential.Vs
    }
    
    func storeSolutions(xCoordinates: [Double], functions: [[Double]]) {
        realResults = functions
    }
}
