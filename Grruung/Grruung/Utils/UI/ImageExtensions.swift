//
//  ImageExtensions.swift
//  Grruung
//
//  Created by KimJunsoo on 5/8/25.
//

import Foundation
import SwiftUI

// MARK: - 이미지 확장

extension Image {
    /// 캐릭터 이미지를 로드합니다.
    static func characterImage(_ imagePath: String) -> Image {
        if let uiImage = ImageManager.shared.loadCharacterImage(imagePath: imagePath) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "pawprint.fill")
        }
    }
    
    /// 테스트용 캐릭터 이미지를 생성합니다.
    static func testCharacterImage(for species: PetSpecies, phase: CharacterPhase) -> Image {
        let uiImage = ImageManager.shared.generateDummyImage(for: species, phase: phase)
        return Image(uiImage: uiImage)
    }
}
