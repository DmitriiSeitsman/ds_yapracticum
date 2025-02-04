import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    private var newValue: Int = .zero
    private var averageAccuracy: Double = .zero
    private var answered: Bool = true
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFonts()
        imageView.image = UIImage.init(named: "movie-quiz-background")
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        activityIndicator.startAnimating()
        questionFactory?.loadData()
    }
    
    private func setFonts() {
        counterLabel.font = UIFont.ysDisplayMedium20
        questionLabel.font = UIFont.ysDisplayMedium20
        noButton.titleLabel?.font = UIFont.ysDisplayMedium20
        yesButton.titleLabel?.font = UIFont.ysDisplayMedium20
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadImage(with message: String) {
        showNetworkError(message: message)
    }
    
    private func presentAlert(with alertModel: AlertModel) {
        let alertPresenter = AlertPresenter()
        alertPresenter.presentAlert(model: alertModel)
        guard let alert = alertPresenter.alert else { return }
        present(alert, animated: true, completion: nil)
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let model = AlertModel(alertTitle: "Ошибка",
                               alertMessage: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        presentAlert(with: model)
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        buttonsAvailable(available: true)
        // идём в состояние "Результат квиза"
        if currentQuestionIndex == questionsAmount - 1 {
            
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
            presentAlert(with: alertModel)
        } else {
            // идём в состояние "Вопрос показан"
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
        }
    }
    
    //функция сброса параметров
    private func goToStart() {
        imageView.layer.borderWidth = 0
        currentQuestionIndex = 0
        correctAnswers = 0
        viewDidLoad()
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(data: model.imageName) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // метод изменения рамки
    private func layerChange() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
    
    //Доступность кнопок
    private func buttonsAvailable(available: Bool) {
        yesButton.isEnabled = available
        noButton.isEnabled = available
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        layerChange()
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        buttonsAvailable(available: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResults()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
