//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Evgeniy Kuzin on 31.05.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get } // средняя точность правильных ответов за все игры в процентах
    var gamesCount: Int { get } // количество завершённых игр
    var bestGame: GameResult { get } // информация о лучшей попытке
    
    func store(correct count: Int, total amount: Int)
}
