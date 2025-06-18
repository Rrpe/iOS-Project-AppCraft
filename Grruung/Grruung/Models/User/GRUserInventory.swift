//
//  GRUserInventory.swift
//  Grruung
//
//  Created by mwpark on 5/13/25.
//

import Foundation

/// 유저의 인벤토리 모델
/// - 상점에서 구매한 물품의 정보를 담는 구조체
struct GRUserInventory: Identifiable {
    var id: String
    
    var userItemNumber: String
    var userItemName: String
    var userItemType: ItemType
    var userItemImage: String
    var userItemQuantity: Int
    // 아이템 설명 (예: 달달한 감기약이에요~)
    var userItemDescription: String
    // 아이템 효과 설명 (예: 공격력 + 100)
    var userItemEffectDescription: String
    var userItemCategory: ItemCategory
    var purchasedAt: Date
    
    init(id: String = UUID().uuidString, userItemNumber: String, userItemName: String, userItemType: ItemType, userItemImage: String, userIteamQuantity: Int, userItemDescription: String, userItemEffectDescription: String ,userItemCategory: ItemCategory, purchasedAt: Date = Date()) {
        self.id = id
        self.userItemNumber = userItemNumber
        self.userItemName = userItemName
        self.userItemType = userItemType
        self.userItemImage = userItemImage
        self.userItemQuantity = userIteamQuantity
        self.userItemDescription = userItemDescription
        self.userItemEffectDescription = userItemEffectDescription
        self.userItemCategory = userItemCategory
        self.purchasedAt = purchasedAt
    }
    
    
}

