//
//  alertView.swift
//  Grruung
//
//  Created by 심연아 on 5/7/25.
//

import SwiftUI
import Foundation
import StoreKit
import FirebaseFirestore

struct AlertView: View {
    @EnvironmentObject private var userInventoryViewModel: UserInventoryViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var authService: AuthService
    @StateObject private var fetcher = StoreItemFetcher()
    @State private var isProcessing = false
    @State var realUserId = ""
    @State private var updatedGold: Int = 0
    @State private var updatedDiamond: Int = 0
    @State private var notEnoughCurrencyAmount: Int = 0
    @State private var purchaseStatus: String = ""
    // 파이어베이스에 저장할지 여부
    @State private var isStored: Bool = true
    let product: GRStoreItem
    var quantity: Int
    private let diamondToGold: Int = 1000
    @State private var showNotEnoughMoneyAlert = false
    @State private var showPurchaseSuccessAlert = false
    @State private var showPurchaseCancelAlert = false
    @Binding var isPresented: Bool // 팝업 제어용
    @Binding var refreshTrigger: Bool

    private let db = Firestore.firestore() // // FIXME: - Start 결제 내여

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 아이콘
                Circle()
                    .fill(GRColor.buttonColor_1)
                    .frame(width: 75, height: 75)
                    .overlay(
                        Image(product.itemImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                    )
                
                // 제목
                HStack(spacing: 8) {
                    Text("가격: ")
                        .font(.headline)
                        .foregroundStyle(.black)
                    if product.itemCurrencyType == .won {
                        Text("₩")
                    } else {
                        Image(systemName: product.itemCurrencyType.rawValue == ItemCurrencyType.diamond.rawValue ? "diamond.fill" : "circle.fill")
                            .foregroundStyle(product.itemCurrencyType.rawValue == ItemCurrencyType.diamond.rawValue ? .cyan : .yellow)
                    }
                    
                    Text("\(product.itemPrice * quantity)")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
                
                // 설명
                if product.itemName == "다이아 → 골드" {
                    Text("\(product.itemPrice * quantity) 다이아로 \(quantity * diamondToGold) 골드를 구매합니다.")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("\(product.itemName)")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text("\(quantity)개를 구매합니다.")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    if !isProcessing {
                        Text(purchaseStatus)
                            .font(.caption)
                    }
                }
                
                // 처리 중 표시
                if isProcessing {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("구매 처리 중...")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .padding()
                }
                
                // 버튼들
                HStack(spacing: 12) {
                    // NO 버튼
                    AnimatedCancelButton {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    
                    // YES 버튼
                    AnimatedConfirmButton {
                        Task {
                            if authService.currentUserUID == "" {
                                realUserId = "23456"
                            } else {
                                realUserId = authService.currentUserUID
                            }
                            await handlePurchase()
                        }
                    }
                }
                .frame(height: 50)
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 30)
            .frame(maxWidth: 300)
        }
        .alert("\(notEnoughCurrencyAmount) \(product.itemCurrencyType.rawValue)가 부족합니다", isPresented: $showNotEnoughMoneyAlert) {
            Button("확인", role: .cancel) {
                isPresented = false
            }
        }
        .alert("구매 완료", isPresented: $showPurchaseSuccessAlert) {
            Button("확인", role: .cancel) {
                isPresented = false
                refreshTrigger.toggle()
                NotificationCenter.default.post(name: Notification.Name("ReturnToStoreView"), object: nil)
            }
        } message: {
            Text("아이템이 성공적으로 구매되었습니다.")
        }
        .alert("구매 취소", isPresented: $showPurchaseCancelAlert) {
            Button("확인", role: .cancel) {
                isPresented = false
            }
        } message: {
            Text("결제가 취소되었습니다.")
        }
    }
    
    private func savePurchaseRecord(userId: String, item: GRStoreItem, quantity: Int, price: Int) {
        print("💰 결제 기록 저장 시작: \(item.itemName), 가격: \(price)")
        
        // 결제 기록 컬렉션 참조
        let purchasesRef = db.collection("users").document(userId).collection("purchaseRecords")
        
        // 결제 기록 데이터 생성
        let purchaseRecord: [String: Any] = [
            "itemName": item.itemName,
            "itemImage": item.itemImage,
            "quantity": quantity,
            "price": price,
            "currencyType": item.itemCurrencyType.rawValue,
            "purchaseDate": Timestamp(date: Date()),
            "isRealMoney": true
        ]
        
        // 현재 시간을 포함한 고유 ID 생성
        let timestamp = Int(Date().timeIntervalSince1970 * 1000) // 밀리초 단위
        let recordId = "\(item.itemName)_\(timestamp)"
        
        // Firestore에 저장
        purchasesRef.document(recordId).setData(purchaseRecord) { error in
            if let error = error {
                print("❌ 결제 기록 저장 실패: \(error.localizedDescription)")
            } else {
                print("✅ 결제 기록 저장 성공: \(item.itemName), ID: \(recordId)")
            }
        }
    }
    
    // MARK: - 구매 처리 메서드
    private func handlePurchase() async {
        // 중복 처리 방지
        guard !isProcessing else {
            print("[중복방지] 이미 처리 중입니다")
            return
        }
        
        isProcessing = true
        print("[구매시작] 아이템 구매 처리 시작")
        print("[구매정보] 아이템명: \(product.itemName), 수량: \(quantity)")
        
        // 유저정보가 있는지 확인
        guard let user = userViewModel.user else {
            print("❌ 유저 정보 없음")
            isProcessing = false
            return
        }
        
        let totalPrice = product.itemPrice * quantity
        updatedGold = user.gold
        updatedDiamond = user.diamond
        
        // 상품이 골드인지 다이아인지 또는 원화인지 확인
        let hasEnoughCurrency: Bool
        switch product.itemCurrencyType {
        case .gold:
            hasEnoughCurrency = user.gold >= totalPrice
        case .diamond:
            hasEnoughCurrency = user.diamond >= totalPrice
        case .won:
            hasEnoughCurrency = true
        }
        
        // 재화 부족 시 알림
        guard hasEnoughCurrency else {
            notEnoughCurrencyAmount = abs((product.itemCurrencyType.rawValue == ItemCurrencyType.diamond.rawValue ? user.diamond : user.gold) - totalPrice)
            print("❌ 잔액 부족: 구매 금액 \(totalPrice), 보유 금액 \(product.itemCurrencyType == .gold ? user.gold : user.diamond)")
            
            await MainActor.run {
                showNotEnoughMoneyAlert = true
            }
            
            isProcessing = false
            return
        }
        
        if product.itemImage.contains("diamond_") || product.itemName == "다이아 → 골드" {
            print("파이어베이스에 저장되지 않는 아이템입니다.")
            isStored = false
        }
        
        // 골드/다이아인 경우에는 내부 처리만 진행
        if product.itemCurrencyType != .won {
            updatedGold = product.itemCurrencyType == .gold ? user.gold - totalPrice : user.gold
            updatedDiamond = product.itemCurrencyType == .diamond ? user.diamond - totalPrice : user.diamond
            
            // 내부 가상 재화 처리 분리
            await completePurchaseWithoutStoreKit(user: user, totalPrice: totalPrice, isStored: isStored)
            return
        }
        // 아이템 불러오기
        guard let storeProducts = fetcher.products else {
            purchaseStatus = "❌ 불러올 아이템이 없음"
            print(purchaseStatus)
            isProcessing = false
            return
        }
        
        guard let storeProduct = storeProducts.first(where: {$0.id == "com.smallearedcat.grruung.\(product.itemImage)"}) else {
            purchaseStatus = "❌ 상품 정보 없음"
            print(purchaseStatus)
            isProcessing = false
            return
        }
        
        let success = await purchase(product: storeProduct)
        guard success else {
            purchaseStatus = "❌ 구매 실패 또는 취소됨."
            print(purchaseStatus)
            await MainActor.run {
                showPurchaseCancelAlert = true
            }
            return
        }

        // 성공 시 결제 기록 저장 (원화 결제만)
        if product.itemCurrencyType == .won &&
           (product.itemName.contains("다이아") || product.itemName.contains("동산 잠금해제")) {
            print("💰 원화 결제 기록 저장: \(product.itemName), 가격: \(totalPrice)")
            savePurchaseRecord(userId: realUserId, item: product, quantity: quantity, price: totalPrice)
        }

        print("✅ StoreKit 결제 완료. 아이템 저장 시작.")
        await completePurchaseWithoutStoreKit(user: user, totalPrice: totalPrice, isStored: isStored)
    }
    
    private func completePurchaseWithoutStoreKit(user: GRUser, totalPrice: Int, isStored: Bool) async {
        // 재빌드시 아이템 넘버가 바뀌면서(UUID) 이전 구매 아이템과 아이템 넘버가 달라서 계속 새로 구매되는 오류 발생!
        // 반드시 아이템의 이름들이 고유해야함! -> 같으면 또 다시 에러남...
        let beforeItemNumber = userInventoryViewModel.inventories.first(where: { $0.userItemName == product.itemName })?.userItemNumber ?? product.itemNumber
        
        do {
            let buyItem = GRUserInventory(
                userItemNumber: beforeItemNumber,
                userItemName: product.itemName,
                userItemType: product.itemType,
                userItemImage: product.itemImage,
                userIteamQuantity: quantity,
                userItemDescription: product.itemDescription,
                userItemEffectDescription: product.itemEffectDescription,
                userItemCategory: product.itemCategory
            )
            
            // 예) 다이아에서 골드로 바꾸는 경우에는 파이어베이스에 저장하지 않고 재화만 업데이트함.
            if isStored {
                // 이미 로드된 인벤토리에서 기존 아이템 확인 (즉시 확인)
                if let existingItem = userInventoryViewModel.inventories.first(where: {
                    $0.userItemNumber == buyItem.userItemNumber
                }) {
                    print("[기존아이템] 발견 - 현재수량: \(existingItem.userItemQuantity)")
                    let newQuantity = existingItem.userItemQuantity + quantity
                    print("[수량업데이트] 새로운 수량: \(newQuantity)")
                    
                    // 수량 업데이트
                    userInventoryViewModel.updateItemQuantity(
                        userId: realUserId,
                        item: existingItem,
                        newQuantity: newQuantity
                    )
                } else {
                    print("[신규아이템] 새로운 아이템 추가")
                    
                    // 새 아이템 저장 (await로 즉시 처리)
                    await userInventoryViewModel.saveInventory(
                        userId: realUserId,
                        inventory: buyItem
                    )
                }
            } else {
                if buyItem.userItemName == "다이아 → 골드" {
                    updatedGold += totalPrice * (diamondToGold / 10)
                } else {
                    // 다이아 구매 아이템 부분을 구분
                    let pattern = #"^(\d+)\s*다이아$"#
                    let regex = try! NSRegularExpression(pattern: pattern)
                    
                    let text = buyItem.userItemName
                    let range = NSRange(text.startIndex..<text.endIndex, in: text)
                    
                    if let match = regex.firstMatch(in: text, options: [], range: range),
                       let numberRange = Range(match.range(at: 1), in: text) {
                        let numberString = String(text[numberRange])
                        if let number = Int(numberString) {
                            updatedDiamond += number
                        }
                    }
                }
            }
            
            // 유저 재화 업데이트
            userViewModel.updateCurrency(userId: realUserId, gold: updatedGold, diamond: updatedDiamond)
            print("🛒 [구매완료] 처리 완료!")
            
            // 상품 구매시 구매 중 progressView를 보여주기 위해서
            // 일부러 delay 1초를 줌.
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                showPurchaseSuccessAlert = true
            }
        } catch {
            print("❌ 구매 처리 중 오류: \(error)")
        }
        
        isProcessing = false
    }
    
    func purchase(product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    purchaseStatus = "✅ 구매 성공"
                    print("✅ 구매 성공: \(transaction.productID)")
                    await transaction.finish()
                    return true
                case .unverified:
                    purchaseStatus = "❌ 영수증 검증 실패"
                    print(purchaseStatus)
                    return false
                }
            case .userCancelled:
                purchaseStatus = "🛑 유저가 구매 취소"
                print(purchaseStatus)
                return false
            case .pending:
                purchaseStatus = "⏳ 승인 대기 중"
                print(purchaseStatus)
                return false
            @unknown default:
                purchaseStatus = "❓알 수 없는 오류"
                print(purchaseStatus)
                return false
            }
        } catch {
            print("❌ 구매 중 오류: \(error)")
            return false
        }
    }
}

//
//#Preview {
//    AlertView()
//}
