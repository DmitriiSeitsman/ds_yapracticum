//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 11.01.2025.
//
import Foundation

struct GameResult {
    
    let correct: Int
    let total: Int
    let date: Date
    
    func bestResult(_ compare: GameResult) -> Bool {
        correct > compare.correct
    }
}
