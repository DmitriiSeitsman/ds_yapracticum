//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 05.01.2025.
//
import Foundation
import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadImage(with: "Не удалось загрузить постер")
                    return
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let questionForUser = ["higher", "lower"]
            let chooseQuestion = questionForUser.randomElement()
            let text: String
            var correctAnswer: Bool = false
            
            let roundedHigh = Int(rating.rounded(.up))
            let roundedLow = Int(rating.rounded(.down))
            
            let arrayOfRandoms: [Int] = [roundedHigh, roundedLow]
            let selectionOfRandom: Int = arrayOfRandoms.randomElement() ?? 0
            
            if chooseQuestion == "higher" {
                text = "Рейтинг этого фильма больше чем \(selectionOfRandom)?"
                if selectionOfRandom == roundedLow {
                    correctAnswer = roundedHigh > roundedLow} else {
                        correctAnswer = roundedHigh <= roundedLow
                    }
            } else {
                text = "Рейтинг этого фильма меньше чем \(selectionOfRandom)?"
                if selectionOfRandom == roundedHigh {
                    correctAnswer = roundedLow < roundedHigh} else {
                        correctAnswer = roundedLow >= roundedHigh
                    }
            }
            
            let question = QuizQuestion(imageName: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
