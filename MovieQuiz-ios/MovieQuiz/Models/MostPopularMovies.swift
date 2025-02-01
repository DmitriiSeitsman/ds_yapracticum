//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 28.01.2025.
//
import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}
