//
//  BusinessCardData.swift
//  BusinessCard
//
//  Created by KimJunsoo on 1/22/25.
//

import Foundation
import SwiftData

@Model
final class CardData {
    var id: String = UUID().uuidString
    var job: String
    var image: Data?
    var qrCode: Data?
    var name: String
    var mail: String
    var github: String
    var phone: String
    
    init(job: String,
         image: Data? = nil,
         qrCode: Data? = nil,
         name: String,
         mail: String,
         github: String,
         phone: String) {
        self.job = job
        self.image = image
        self.qrCode = qrCode
        self.name = name
        self.mail = mail
        self.github = github
        self.phone = phone
    }
}
