//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Evgeniy Kuzin on 26.05.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    var alertController: UIViewController? { get set }
    func show(alertModel: AlertModel)
}
