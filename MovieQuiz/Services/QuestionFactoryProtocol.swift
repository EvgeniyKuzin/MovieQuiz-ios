//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Evgeniy Kuzin on 26.05.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
