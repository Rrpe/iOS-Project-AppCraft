//
//  GRCharacter.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//  Created by mwpark on 5/1/25.
//

import Foundation
import SwiftUICore

// 캐릭터 정보를 담는 구조체
struct GRCharacter: Identifiable {
    
    let id: String // characterUUID
    var species: PetSpecies
    var name: String
    var imageName: String // 이미지 파일 이름 (SF Symbol 또는 Asset 이름)
    var birthDate: Date // 캐릭터 상태 정보
    var createdAt: Date
    var status: GRCharacterStatus
    
    
    init(id: String = UUID().uuidString,
         species: PetSpecies,
         name: String,
         imageName: String,
         birthDate: Date,
         createdAt: Date = Date(),
         status: GRCharacterStatus = GRCharacterStatus()) {
        self.id = id
        self.species = species
        self.name = name
        self.imageName = imageName
        self.birthDate = birthDate
        self.createdAt = createdAt
        self.status = status
    }
    
    // 경험치 추가 메서드
    mutating func addExp(_ amount: Int) {
        status.exp += amount
        
        if status.exp >= status.expToNextLevel {
            status.levelUp()
        }
    }
    
    // 상태 업데이트 메서드
    mutating func updateStatus(satiety: Int? = nil, stamina: Int? = nil, activity: Int? = nil,
                              affection: Int? = nil, healthy: Int? = nil, clean: Int? = nil) {
        if let satiety = satiety {
            status.satiety = max(0, min(100, status.satiety + satiety))
        }
        
        if let stamina = stamina {
            status.stamina = max(0, min(100, status.stamina + stamina))
        }
        
        if let activity = activity {
            status.activity = max(0, min(100, status.activity + activity))
        }
        
        if let affection = affection {
            status.affection = max(0, min(100, status.affection + affection))
        }
        
        if let healthy = healthy {
            status.healthy = max(0, min(100, status.healthy + healthy))
        }
        
        if let clean = clean {
            status.clean = max(0, min(100, status.clean + clean))
        }
    }
    
    // 캐릭터가 현재 상태에 맞는 메시지를 반환하는 메서드
    func getStatusMessage() -> String {
        let statusDescription = status.getStatusDescription()
        
        switch species {
        case .Undefined:
            return "캐릭터가 없습니다"
        case .CatLion:
            switch status.phase {
            case .egg:
                return "알 속에서 꿈틀거리고 있어요."
            case .infant:
                if statusDescription.contains("배고픔") {
                    return "냥... 배고파요!"
                } else if statusDescription.contains("피곤함") {
                    return "어흥... 졸려요..."
                } else {
                    return "냥냥! 반가워요!"
                }
            case .child:
                if statusDescription.contains("배고픔") {
                    return "배고파요 냥! 뭐 먹을 거 없어요?"
                } else if statusDescription.contains("피곤함") {
                    return "좀 쉬고 싶어요 어흥..."
                } else {
                    return "안녕하세요 냥! 오늘 뭐 할까요?"
                }
            case .adolescent, .adult, .elder:
                return "그르릉... \(statusDescription) 상태예요."
            }
            
        case .quokka:
            switch status.phase {
            case .egg:
                return "알 속에서 꿈틀거리고 있어요."
            case .infant:
                if statusDescription.contains("배고픔") {
                    return "꾸잉... 배고파요!"
                } else if statusDescription.contains("피곤함") {
                    return "깍깍... 졸려요..."
                } else {
                    return "꾸잉! 반가워요!"
                }
            case .child:
                if statusDescription.contains("배고픔") {
                    return "배고파요 꾸잉! 뭐 먹을 거 없어요?"
                } else if statusDescription.contains("피곤함") {
                    return "좀 쉬고 싶어요 깍깍..."
                } else {
                    return "안녕하세요 꾸잉! 오늘 뭐 할까요?"
                }
            case .adolescent, .adult, .elder:
                return "꾸잉... \(statusDescription) 상태예요."
            }

        }
    }
}

enum PetSpecies: String, Codable, CaseIterable {
    case Undefined = "미정"
    case CatLion = "고양이사자"
    case quokka = "쿼카"
    
    var defaultName: String {
        switch self {
        case .Undefined:
            return "캐릭터 미정"
        case .CatLion:
            return "냥냥이"
        case .quokka:
            return "꾸꾸"
        }
    }
}
