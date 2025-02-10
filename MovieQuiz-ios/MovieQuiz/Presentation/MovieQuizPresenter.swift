//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 09.02.2025.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func setFonts()
    func changeImageLayer()
    func presentAlert(with alertModel: AlertModel)
    func buttonsAvailable(available: Bool)
    func viewDidLoad()
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestionIndex: Int = 0
    private var averageAccuracy: Double = 0
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didFailToLoadImage(with message: String) {
        viewController?.showNetworkError(message: message)
    }
    
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func makeResultsMessage() {
        let statisticService = StatisticService()
        let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
        statisticService.store(result: gameResult)
        
        let gamesCount = statisticService.gamesCount
        let bestGameCorrect = statisticService.bestGame.correct
        let bestGameTotal = statisticService.bestGame.total
        let date = statisticService.bestGame.date.dateTimeString
        let totalCorrect = statisticService.totalCorrect
        
        if gamesCount != 0 {
            averageAccuracy = Double(100 * totalCorrect / (10 * gamesCount))
        } else {
            averageAccuracy = 0
        }
        
        let alertModel = AlertModel(alertTitle: "Вы закончили квиз", alertMessage:
        """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGameCorrect)/\(bestGameTotal) (\(date))
        Средняя точность: \(averageAccuracy) %"
        """,
                                    buttonText: "Сыграть еще раз", completion: goToStart)
        viewController?.presentAlert(with: alertModel)
    }
    
    private func proceedToNextQuestionOrResults() {
        viewController?.buttonsAvailable(available: true )
        // идём в состояние "Результат квиза"
        if isLastQuestion() {
            makeResultsMessage()
        } else {
            // идём в состояние "Вопрос показан"
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.changeImageLayer()
        }
    }
    
    //функция сброса параметров
    private  func goToStart() {
        viewController?.changeImageLayer()
        restartGame()
        viewController?.viewDidLoad()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
        self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswers += 1 }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(data: model.imageName) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
