//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Evgeniy Kuzin on 20.06.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewController?
    
    var questionFactory: QuestionFactoryProtocol?
    var correctAnswers = 0
    let questionsAmount = 10

    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private var alertDelegate: MovieQuizViewControllerDelelegate?
    private var statisticService: StatisticService?
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButttonClicked() {
        didAnswer(isYes: false)
    }
    
    func restartGame() {
        correctAnswers = 0
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        correctAnswers += 1
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
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let bestGame = statisticService?.bestGame
            viewController?.imageView.layer.borderColor = CGColor(gray: 0.0, alpha: 0)
            let text = """
Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
Рекорд: \(bestGame?.correct ?? 0)/\(self.questionsAmount) (\(String(describing: bestGame?.date.dateTimeString ?? "")))
Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? ""))%
Ваш результат: \(correctAnswers)/\(self.questionsAmount)
"""
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз",
                completion: {
                    self.restartGame()
                    self.resetQuestionIndex()
                    self.questionFactory?.requestNextQuestion()
                })
            alertDelegate?.show(alertModel: alertModel)
            correctAnswers = 0
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
