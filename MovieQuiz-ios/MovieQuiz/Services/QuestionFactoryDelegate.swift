//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 07.01.2025.
//
import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
    func didFailToLoadImage(with message: String) 
}
