//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitrii Seitsman on 07.01.2025.
//
import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
