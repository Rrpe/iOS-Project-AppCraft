//
//  UIDevice+ModelName.swift
//  Grruung
//
//  Created by NO SEONGGYEONG on 5/13/25.
//

import UIKit
import Foundation

extension UIDevice {
    static func modelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // 디버깅용 디바이스 식별자 출력
        print("디바이스 식별자: \(identifier)")
        
        // 모델 식별자를 인간이 읽을 수 있는 모델명으로 매핑
        switch identifier {
            case "iPhone11,8": return "아이폰 XR"
            case "iPhone11,2": return "아이폰 XS"
            case "iPhone11,4", "iPhone11,6": return "아이폰 XS Max"
            case "iPhone12,1": return "아이폰 11"
            case "iPhone12,3": return "아이폰 11 Pro"
            case "iPhone12,5": return "아이폰 11 Pro Max"
            case "iPhone12,8": return "아이폰 SE (2세대)"
            case "iPhone13,1": return "아이폰 12 mini"
            case "iPhone13,2": return "아이폰 12"
            case "iPhone13,3": return "아이폰 12 Pro"
            case "iPhone13,4": return "아이폰 12 Pro Max"
            case "iPhone14,4": return "아이폰 13 mini"
            case "iPhone14,5": return "아이폰 13"
            case "iPhone14,2": return "아이폰 13 Pro"
            case "iPhone14,3": return "아이폰 13 Pro Max"
            case "iPhone14,7": return "아이폰 14"
            case "iPhone14,8": return "아이폰 14 Plus"
            case "iPhone15,2": return "아이폰 14 Pro"
            case "iPhone15,3": return "아이폰 14 Pro Max"
            case "iPhone14,6": return "아이폰 SE (3세대)"
            case "iPhone15,4": return "아이폰 15"
            case "iPhone15,5": return "아이폰 15 Plus"
            case "iPhone16,1": return "아이폰 15 Pro"
            case "iPhone16,2": return "아이폰 15 Pro Max"
            case "iPhone17,3": return "아이폰 16"
            case "iPhone17,4": return "아이폰 16 Plus"
            case "iPhone17,1": return "아이폰 16 Pro"
            case "iPhone17,2": return "아이폰 16 Pro Max"
            case "iPhone17,5": return "아이폰 16e" // 추정
            
            // iPad 모델
            case "iPad7,11", "iPad7,12": return "아이패드 (7세대)"
            case "iPad7,5", "iPad7,6": return "아이패드 (8세대)"
            case "iPad7,3", "iPad7,4": return "아이패드 (9세대)"
            case "iPad13,1", "iPad13,2": return "아이패드 (10세대)"
            case "iPad11,6", "iPad11,7": return "아이패드 에어 (3세대)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "아이패드 에어 (4세대)"
            case "iPad13,8", "iPad13,9": return "아이패드 에어 (5세대)"
            case "iPad14,4", "iPad14,5", "iPad14,6": return "아이패드 에어 M2"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "아이패드 프로 11인치 (1세대)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "아이패드 프로 12.9인치 (3세대)"
            case "iPad8,9", "iPad8,10": return "아이패드 프로 11인치 (2세대)"
            case "iPad8,11", "iPad8,12": return "아이패드 프로 12.9인치 (4세대)"
            case "iPad13,16", "iPad13,17": return "아이패드 프로 11인치 (3세대)"
            case "iPad13,18", "iPad13,19": return "아이패드 프로 12.9인치 (5세대)"
            case "iPad14,3": return "아이패드 프로 11인치 (4세대)"
            case "iPad14,8", "iPad14,9": return "아이패드 프로 12.9인치 (6세대)"
            case "iPad16,1", "iPad16,2": return "아이패드 프로 M4"
            case "iPad11,3", "iPad11,4": return "아이패드 미니 (5세대)"
            case "iPad14,1", "iPad14,2": return "아이패드 미니 (6세대)"
            case "iPad14,10", "iPad14,11": return "아이패드 미니 (7세대)"
        
            default: return "기기"
        }
    }
}
