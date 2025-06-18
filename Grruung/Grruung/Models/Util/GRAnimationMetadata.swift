//
//  GRAnimationMetadata.swift
//  Grruung
//
//  Created by NoelMacMini on 5/12/25.
//

import Foundation
import SwiftData

@Model
class GRAnimationMetadata {
    // MARK: - 식별 정보
    var characterType: String       // 예: "quokka", "catlion"
    var phase: String              // 예: "infant", "child" (영어로 저장)
    var animationType: String       // 예: "normal", "sleeping", "eating"
    var frameIndex: Int             // 예: 1, 2, 3... (프레임 번호)
    
    // MARK: - 파일 정보
    var filePath: String            // 저장된 파일 경로 (Documents 폴더 기준 상대 경로)
    var fileSize: Int               // 파일 크기 (바이트)
    
    // MARK: - 상태 정보
    var downloadDate: Date          // 다운로드 날짜
    var lastAccessed: Date          // 마지막 접근 시간
    var isDownloaded: Bool          // 다운로드 완료 여부
    
    // MARK: - 추가 정보 (ImageTestModel에는 없었던 것들)
    var species: String             // 캐릭터 종족 (quokka, catlion 등) - characterType과 동일하지만 명확성을 위해
    var totalFramesInAnimation: Int // 해당 애니메이션의 총 프레임 수 (완료 여부 확인용)
    
    // MARK: - 초기화
    init(characterType: String,
         phase: CharacterPhase,
         animationType: String,
         frameIndex: Int,
         filePath: String,
         fileSize: Int = 0,
         isDownloaded: Bool = true,
         totalFramesInAnimation: Int = 0) {
        
        self.characterType = characterType
        self.phase = phase.toEnglishString() // CharacterPhase를 영어로 변환
        self.animationType = animationType
        self.frameIndex = frameIndex
        self.filePath = filePath
        self.fileSize = fileSize
        self.downloadDate = Date()
        self.lastAccessed = Date()
        self.isDownloaded = isDownloaded
        self.species = characterType
        self.totalFramesInAnimation = totalFramesInAnimation
    }
}

// MARK: - CharacterPhase 확장 (영어 변환)
extension CharacterPhase {
    func toEnglishString() -> String {
        switch self {
        case .egg: return "egg"
        case .infant: return "infant"
        case .child: return "child"
        case .adolescent: return "adolescent"
        case .adult: return "adult"
        case .elder: return "elder"
        }
    }
}
