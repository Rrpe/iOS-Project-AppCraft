//
//  ImageManager.swift
//  Grruung
//
//  Created by KimJunsoo on 5/8/25.
//

import Foundation
import UIKit
import SwiftUI

/// 이미지 관련 유틸리티 클래스
class ImageManager {
    // MARK: - 0. 싱글톤
    static let shared = ImageManager()
    
    private init() {}
    
    // MARK: - 1. 캐릭터 이미지 로딩
    
    /// 캐릭터 이미지를 로드합니다. (로컬 또는 URL)
    func loadCharacterImage(imagePath: String) -> UIImage? {
        // URL인 경우 (Firebase Storage 등)
        if imagePath.starts(with: "http") {
            // TODO: 이미지 다운로드 로직 구현
            return UIImage(systemName: "photo")
        }
        
        // 로컬 이미지인 경우
        return UIImage(named: imagePath) ?? UIImage(systemName: "pawprint.fill")
    }
    
    // MARK: - 2. 더미 이미지 생성
    
    /// 테스트용 더미 이미지를 생성합니다.
    func generateDummyImage(for species: PetSpecies, phase: CharacterPhase) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // 배경
            UIColor.systemBackground.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 테두리
            UIColor.systemGray.setStroke()
            context.stroke(CGRect(origin: .zero, size: size))
            
            // 텍스트
            let speciesText = species.rawValue
            let phaseText = phase.rawValue
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let speciesAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]
            
            let phaseAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: paragraphStyle
            ]
            
            // 동물 아이콘
            let symbolName: String
            switch species {
            case .CatLion:
                symbolName = "cat.fill"
            case .quokka:
                symbolName = "hare.fill"
            case .Undefined:
                symbolName = "questionmark"
            }
            
            if let image = UIImage(systemName: symbolName) {
                let imageSize = CGSize(width: 80, height: 80)
                let imageRect = CGRect(
                    x: (size.width - imageSize.width) / 2,
                    y: 40,
                    width: imageSize.width,
                    height: imageSize.height
                )
                image.draw(in: imageRect)
            }
            
            // 텍스트 그리기
            let speciesRect = CGRect(x: 0, y: 130, width: size.width, height: 30)
            speciesText.draw(in: speciesRect, withAttributes: speciesAttributes)
            
            let phaseRect = CGRect(x: 0, y: 160, width: size.width, height: 30)
            phaseText.draw(in: phaseRect, withAttributes: phaseAttributes)
        }
    }
}


