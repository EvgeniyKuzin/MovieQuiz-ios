//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Evgeniy Kuzin on 26.05.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: () -> Void{
        
    }
}
