//
//  GRShopItem.swift
//  Grruung
//
//  Created by 심연아 on 5/12/25.
//  Edited by mwpark on 5/23/25.
//

import SwiftUI

struct GRStoreItem: Identifiable {
    let id = UUID()
    let itemNumber: String
    var itemName: String
    var itemTarget: PetSpecies
    var itemType: ItemType
    var itemImage: String
    var itemQuantity: Int
    var limitedQuantity: Int
    var purchasedQuantity: Int
    var itemPrice: Int
    var itemCurrencyType: ItemCurrencyType
    var itemDescription: String
    var itemEffectDescription: String
    var itemTag: ItemTag
    var itemCategory: ItemCategory
    var isItemOwned: Bool
    let bgColor: Color
    
    init(itemName: String,
         itemTarget: PetSpecies = .Undefined,
         itemType: ItemType,
         itemImage: String,
         itemQuantity: Int,
         limitedQuantity: Int,
         purchasedQuantity: Int,
         itemPrice: Int,
         itemCurrencyType: ItemCurrencyType = .gold,
         itemDescription: String,
         itemEffectDescription: String,
         itemTag: ItemTag,
         itemCategory: ItemCategory,
         isItemOwned: Bool = false,
         bgColor: Color
    ) {
        self.itemNumber = id.uuidString
        self.itemName = itemName
        self.itemTarget = itemTarget
        self.itemType = itemType
        self.itemImage = itemImage
        self.itemQuantity = itemQuantity
        self.limitedQuantity = limitedQuantity
        self.purchasedQuantity = purchasedQuantity
        self.itemPrice = itemPrice
        self.itemCurrencyType = itemCurrencyType
        self.itemDescription = itemDescription
        self.itemEffectDescription = itemEffectDescription
        self.itemTag = itemTag
        self.itemCategory = itemCategory
        self.isItemOwned = isItemOwned
        self.bgColor = bgColor
    }
}

enum ItemType: String, CaseIterable {
    case consumable = "소모품"
    case permanent = "영구"
}

enum ItemCategory: String, CaseIterable {
    case food = "음식"
    case drug = "약품"
    case toy = "장난감"
    case etc = "기타"
    /// 나중에~
    // case avatar = "의류"
}

enum ItemTag: String, CaseIterable {
    case limited = "기간+한정상품"
    case normal = "일반상품"
}

enum ItemCurrencyType: String, CaseIterable {
    case gold = "골드"
    case diamond = "다이아"
    case won = "원"
}

// 일반 품목
let products = [
    GRStoreItem(itemName: "다이아 → 골드",
               itemType: .consumable,
               itemImage: "diamondToGold",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 10,
               itemCurrencyType: .diamond,
               itemDescription: "10 다이아를 1000 골드로 교환할 수 있는 아이템입니다.",
               itemEffectDescription: "사용 시 1000 골드를 획득합니다.",
               itemTag: .normal,
               itemCategory: .etc, // 새 범주 추가 가능
               bgColor: .yellow.opacity(0.4)),
    GRStoreItem(itemName: "주사 치료",
               itemType: .consumable,
               itemImage: "Injection",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 199,
               itemDescription: "빠르고 정확한 주사 치료로 활력을 되찾아요.",
               itemEffectDescription: "건강\t + 10\n청결도\t + 5",
               itemTag: .normal,
               itemCategory: .drug,
               bgColor: .blue.opacity(0.4)),
    
    GRStoreItem(itemName: "진단 치료",
               itemType: .consumable,
               itemImage: "stethoscope",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 159,
               itemDescription: "의사에게 정확한 진단으로 더 빨리 나아요!",
               itemEffectDescription: "건강\t + 10\n청결도\t + 5",
               itemTag: .normal,
               itemCategory: .drug,
               bgColor: .yellow.opacity(0.4)),
    
    GRStoreItem(itemName: "약물 치료",
               itemType: .consumable,
               itemImage: "medicineBottles",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 89,
               itemDescription: "복용이 쉬운 알약으로 내부부터 회복.",
               itemEffectDescription: "건강\t + 10\n청결도\t + 5",
               itemTag: .normal,
               itemCategory: .drug,
               bgColor: .pink.opacity(0.4)),
    
    GRStoreItem(itemName: "랜덤박스선물",
               itemType: .consumable,
               itemImage: "randomBoxGift",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 209,
               itemDescription: "무엇이 들어있을까? 기대를 담은 깜짝 선물!",
               itemEffectDescription: "무작위 아이템을 획득합니다.",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .orange.opacity(0.4)),
]

// 놀이
let playProducts = [
    GRStoreItem(itemName: "캐치볼 놀이",
               itemType: .consumable,
               itemImage: "volleyball",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 189,
               itemDescription: "몸도 마음도 튕겨내는 재미! 건강한 유대감 형성.",
               itemEffectDescription: "체력\t + 10\n활동량\t + 5\n경험치\t + 5",
               itemTag: .normal,
               itemCategory: .toy,
               bgColor: .green.opacity(0.4)),
    
    GRStoreItem(itemName: "힐링하기",
               itemType: .consumable,
               itemImage: "healing",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 229,
               itemDescription: "조용히 자연을 느끼며 회복하는 시간.",
               itemEffectDescription: "포만감\t + 5\n체력\t + 5\n활동량\t + 5\n건강\t + 5\n청결도\t + 5\n경험치\t + 2",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .purple.opacity(0.4)),
    
    GRStoreItem(itemName: "산책하기",
               itemType: .consumable,
               itemImage: "walking",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 129,
               itemDescription: "자연 속에서의 산책으로 기분 전환!",
               itemEffectDescription: "포만감\t + 5\n체력\t + 5\n활동량\t + 5\n건강\t + 5\n청결도\t + 5\n경험치\t + 2",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .mint.opacity(0.4))
]

// 회복
let recoveryProducts: [GRStoreItem] = [
    GRStoreItem(itemName: "아이스크림",
               itemType: .consumable,
               itemImage: "icecream",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 229,
               itemDescription: "달콤한 아이스크림 한 입으로 기분 전환!",
               itemEffectDescription: "체력\t + 10\n건강\t + 15",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .purple.opacity(0.4)),
    
    GRStoreItem(itemName: "햄버거",
               itemType: .consumable,
               itemImage: "burger",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 129,
               itemDescription: "든든한 햄버거 한 입으로 에너지 충전!",
               itemEffectDescription: "포만감\t + 20\n건강\t + 5",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .mint.opacity(0.4)),
    
    GRStoreItem(itemName: "팬케이크",
               itemType: .consumable,
               itemImage: "pancake",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 229,
               itemDescription: "폭신한 팬케이크로 달콤한 휴식을 즐겨요!",
               itemEffectDescription: "체력\t + 10\n활동량\t + 15",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .purple.opacity(0.4)),
    
    GRStoreItem(itemName: "복숭아 먹기",
               itemType: .consumable,
               itemImage: "peach",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 129,
               itemDescription: "달콤한 복숭아로 기분 좋은 회복을!",
               itemEffectDescription: "체력\t + 20\n청결도\t + 7",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .mint.opacity(0.4)),
    
    GRStoreItem(itemName: "배 먹기",
               itemType: .consumable,
               itemImage: "pear",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 229,
               itemDescription: "시원한 배로 수분과 기분을 동시에 채워요!",
               itemEffectDescription: "포만감\t + 12\n건강\t + 13",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .purple.opacity(0.4)),

    GRStoreItem(itemName: "수박 먹기",
               itemType: .consumable,
               itemImage: "watermelon",
               itemQuantity: 1,
               limitedQuantity: 0,
               purchasedQuantity: 0,
               itemPrice: 129,
               itemDescription: "더운 날엔 역시 수박이죠!",
               itemEffectDescription: "포만감\t + 10\n체력\t + 15\n청결도\t + 5",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .mint.opacity(0.4)),
    
    GRStoreItem(itemName: "쉐이크",
               itemType: .consumable,
               itemImage: "shake",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 129,
               itemDescription: "달콤한 쉐이크로 스트레스를 잠시 잊어보세요.",
               itemEffectDescription: "포만감\t + 100\n체력\t + 100\n활동량\t + 100",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .mint.opacity(0.4)),
    
    GRStoreItem(itemName: "초밥 먹기",
               itemType: .consumable,
               itemImage: "sushi",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 229,
               itemDescription: "신선한 초밥으로 여유로운 힐링 타임!",
               itemEffectDescription: "포만감\t + 10\n활동량\t + 10\n건강\t + 8",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .purple.opacity(0.4)),
    
    GRStoreItem(itemName: "와플 먹기",
               itemType: .consumable,
               itemImage: "waffle",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 129,
               itemDescription: "바삭한 와플로 달콤한 에너지를 충전해요!",
               itemEffectDescription: "경험치\t + 100",
               itemTag: .normal,
               itemCategory: .food,
               bgColor: .mint.opacity(0.4))
]

// 티켓
let ticketProducts = [
    GRStoreItem(itemName: "채팅 티켓",
               itemType: .consumable,
               itemImage: "circleCrown",  // 이미지 이름 변경 필요
               itemQuantity: 1,
               limitedQuantity: 50,
               purchasedQuantity: 0,
               itemPrice: 1000,
               itemCurrencyType: .gold,
               itemDescription: "펫과 한 번의 대화를 할 수 있는 티켓입니다. 1회 사용 가능합니다.",
               itemEffectDescription: "챗펫 기능 1회 이용",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .blue.opacity(0.5)),
    
    GRStoreItem(itemName: "채팅 티켓",
               itemType: .consumable,
               itemImage: "circleCrown",  // 이미지 이름 변경 필요
               itemQuantity: 1,
               limitedQuantity: 50,
               purchasedQuantity: 0,
               itemPrice: 10,
               itemCurrencyType: .diamond,
               itemDescription: "펫과 한 번의 대화를 할 수 있는 프리미엄 티켓입니다. 1회 사용 가능합니다.",
               itemEffectDescription: "챗펫 기능 1회 이용",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .purple.opacity(0.5)),
    
    GRStoreItem(itemName: "동산 잠금해제x1",
               itemType: .permanent,
               itemImage: "charDex_unlock_ticket",
               itemQuantity: 1,
               limitedQuantity: 10,
               purchasedQuantity: 0,
               itemPrice: 9900,
               itemCurrencyType: .won,
               itemDescription: "캐릭터 동산의 슬롯 1개를 잠금해제 할 수 있습니다.",
               itemEffectDescription: "캐릭터 동산의 슬롯 1개를 잠금해제 할 수 있습니다.",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .cyan.opacity(0.4))
]

// 다이아 구매 아이템(유료)
let diamondProducts: [GRStoreItem] = [
    GRStoreItem(itemName: "5 다이아",
               itemType: .consumable,
               itemImage: "diamond_5",
               itemQuantity: 1,
               limitedQuantity: 1,
               purchasedQuantity: 0,
               itemPrice: 1200,
                itemCurrencyType: .won,
               itemDescription: "입문자를 위한 소형 다이아 팩입니다.",
               itemEffectDescription: "구매 시 5 다이아를 획득합니다.",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .yellow.opacity(0.4)),
    GRStoreItem(itemName: "12 다이아",
               itemType: .consumable,
               itemImage: "diamond_12",
               itemQuantity: 1,
               limitedQuantity: 1,
               purchasedQuantity: 0,
               itemPrice: 2500,
                itemCurrencyType: .won,
               itemDescription: "가성비 좋은 소형 팩! 조금 더 여유 있게 사용해보세요.",
               itemEffectDescription: "구매 시 12 다이아를 획득합니다.",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .yellow.opacity(0.4)),
    GRStoreItem(itemName: "30 다이아",
               itemType: .consumable,
               itemImage: "diamond_30",
               itemQuantity: 1,
               limitedQuantity: 1,
               purchasedQuantity: 0,
               itemPrice: 5900,
                itemCurrencyType: .won,
               itemDescription: "일상적으로 사용하기 좋은 다이아 팩입니다.",
               itemEffectDescription: "구매 시 30 다이아를 획득합니다.",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .yellow.opacity(0.4)),
    GRStoreItem(itemName: "65 다이아",
               itemType: .consumable,
               itemImage: "diamond_65",
               itemQuantity: 1,
               limitedQuantity: 1,
               purchasedQuantity: 0,
               itemPrice: 12000,
                itemCurrencyType: .won,
               itemDescription: "다양한 프리미엄 아이템 구매에 적합한 중형 팩입니다.",
               itemEffectDescription: "구매 시 65 다이아를 획득합니다.",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .yellow.opacity(0.4)),
    GRStoreItem(itemName: "140 다이아",
               itemType: .consumable,
               itemImage: "diamond_140",
               itemQuantity: 1,
               limitedQuantity: 1,
               purchasedQuantity: 0,
               itemPrice: 25000,
                itemCurrencyType: .won,
               itemDescription: "게임을 더 깊이 즐기고 싶은 유저를 위한 대형 팩입니다.",
               itemEffectDescription: "구매 시 140 다이아를 획득합니다.",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .yellow.opacity(0.4)),
    GRStoreItem(itemName: "300 다이아",
               itemType: .consumable,
               itemImage: "diamond_300",
               itemQuantity: 1,
               limitedQuantity: 1,
               purchasedQuantity: 0,
               itemPrice: 49000,
                itemCurrencyType: .won,
               itemDescription: "가장 많은 혜택을 제공하는 초대형 팩!",
               itemEffectDescription: "구매 시 300 다이아를 획득합니다.",
               itemTag: .normal,
               itemCategory: .etc,
               bgColor: .yellow.opacity(0.4)),
]

// 전체
let allProducts: [GRStoreItem] =
products + playProducts + recoveryProducts + diamondProducts + ticketProducts

