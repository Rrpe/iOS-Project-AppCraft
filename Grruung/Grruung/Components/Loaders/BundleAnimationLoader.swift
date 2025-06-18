//
//  BundleAnimationLoader.swift
//  Grruung
//
//  Created by NoelMacMini on 5/29/25.
//

import SwiftUI

class BundleAnimationLoader: ObservableObject {
    
    // MARK: - 단일 이미지 로드 (첫 번째 프레임)
    static func loadFirstFrame(
        characterType: String,
        phase: CharacterPhase,
        animationType: String = "normal"
    ) -> UIImage? {
        
        // 파일 경로 구성 (예: "quokka_infant_normal_1")
        let fileName: String
        // 운석 단계는 캐릭터 구분 없이 공통 이미지 사용
        if phase == .egg {
            fileName = "egg_\(animationType)_1"
        } else {
            // 다른 단계는 캐릭터별로 구분
            let phaseString = phaseToString(phase)
            fileName = "\(characterType)_\(phaseString)_\(animationType)_1"
        }
        
        // Bundle에서 이미지 찾기 (png 우선, 없으면 jpg)
        if let image = UIImage(named: fileName) {
            print("이미지 로드 성공: \(fileName)")
            return image
        } else if let image = UIImage(named: "\(fileName).png") {
            print("이미지 로드 성공: \(fileName).png")
            return image
        } else if let image = UIImage(named: "\(fileName).jpg") {
            print("이미지 로드 성공: \(fileName).jpg")
            return image
        } else {
            print("이미지 로드 실패: \(fileName)")
            return nil
        }
    }
    
    // MARK: - 애니메이션 프레임들 로드 (나중에 사용)
    static func loadAnimationFrames(
        characterType: String,
        phase: CharacterPhase,
        animationType: String = "normal",
        maxFrames: Int = 300 // 최대 300프레임까지 찾기
    ) -> [UIImage] {
        
        var frames: [UIImage] = []
        var frameNumber = 1
        
        while frameNumber <= maxFrames {
            let fileName: String
            
            // 운석 단계는 캐릭터 구분 없이 공통 이미지 사용
            if phase == .egg {
                fileName = "egg_\(animationType)_\(frameNumber)"
            } else {
                // 다른 단계는 캐릭터별로 구분
                let phaseString = phaseToString(phase)
                fileName = "\(characterType)_\(phaseString)_\(animationType)_\(frameNumber)"
            }
            
            // 이미지 로드 시도
            if let image = UIImage(named: fileName) {
                frames.append(image)
                frameNumber += 1
            } else {
                // 이미지가 없으면 중단
                break
            }
        }
        
        print("총 \(frames.count)개 프레임 로드 완료")
        return frames
    }
    
    // MARK: - 캐릭터 타입을 문자열로 변환
    static func characterTypeToString(_ species: PetSpecies) -> String {
        switch species {
        case .quokka:
            return "quokka"
        case .CatLion:
            return "catlion"
        case .Undefined:
            return "egg" // 기본값
        }
    }
    
    // MARK: - 성장 단계를 문자열로 변환
    static func phaseToString(_ phase: CharacterPhase) -> String {
        switch phase {
        case .egg:
            return "egg"
        case .infant:
            return "infant"
        case .child:
            return "child"
        case .adolescent:
            return "adolescent"
        case .adult:
            return "adult"
        case .elder:
            return "elder"
        }
    }
}
