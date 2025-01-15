//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 11.01.2025.
//
import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    var totalCorrect: Int { get }
    func store(result: GameResult)
}
