//
//  UserInventoryViewModel.swift
//  Grruung
//
//  Created by mwpark on 5/19/25.
//

import Foundation
import FirebaseFirestore

class UserInventoryViewModel: ObservableObject {
    @Published var inventories: [GRUserInventory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let collectionName = "userInventories"
    
    // MARK: - 아이템 저장
    @MainActor
    func saveInventory(userId: String, inventory: GRUserInventory) async {
        do {
            let data: [String: Any] = [
            "userItemNumber": inventory.userItemNumber,
            "userItemName": inventory.userItemName,
            "userItemType": inventory.userItemType.rawValue,
            "userItemImage": inventory.userItemImage,
            "userItemQuantity": inventory.userItemQuantity,
            "userItemDescription": inventory.userItemDescription,
            "userItemEffectDescription": inventory.userItemEffectDescription,
            "userItemCategory": inventory.userItemCategory.rawValue,
            "purchasedAt": Timestamp(date: inventory.purchasedAt)
        ]
        
        try await db.collection(collectionName)
            .document(userId)
            .collection("items")
            .document(inventory.userItemName)
            .setData(data)
        
            // 성공 시 로컬 배열에 추가
            if !inventories.contains(where: { $0.userItemNumber == inventory.userItemNumber }) {
                inventories.append(inventory)
            }
            print("저장 성공: \(inventory.userItemName)")
        
        } catch {
            errorMessage = error.localizedDescription
            print("저장 실패: \(error.localizedDescription)")
        }
            
    }
    
    // MARK: - 아이템들 불러오기
    func fetchInventories(userId: String) async throws {
        print("[조회시작] 사용자 인벤토리 조회 시작 - userId: \(userId)")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let snapshot = try await db.collection(collectionName)
                .document(userId)
                .collection("items")
                .getDocuments()
            
            guard !snapshot.documents.isEmpty else {
                print("[조회결과] 문서 없음")
                await MainActor.run {
                    inventories = []
                    isLoading = false
                }
                
                return
            }
            
            print("[조회결과] 발견된 문서 수: \(snapshot.documents.count)")
            
            let fetchedInventories = snapshot.documents.compactMap { doc -> GRUserInventory? in
                let data = doc.data()
                
                guard
                    let itemNumber = data["userItemNumber"] as? String,
                    let itemName = data["userItemName"] as? String,
                    let itemTypeRaw = data["userItemType"] as? String,
                    let itemType = ItemType(rawValue: itemTypeRaw),
                    let itemImage = data["userItemImage"] as? String,
                    let itemQuantity = data["userItemQuantity"] as? Int,
                    let itemDescription = data["userItemDescription"] as? String,
                    let itemEffectDescription = data["userItemEffectDescription"] as? String,
                    let itemCategoryRaw = data["userItemCategory"] as? String,
                    let itemCategory = ItemCategory(rawValue: itemCategoryRaw),
                    let timestamp = data["purchasedAt"] as? Timestamp
                else {
                    print("❌ 파싱 실패 for document \(doc.documentID)")
                    return nil
                }
                
                print("[파싱성공] 아이템: \(itemName), 수량: \(itemQuantity)")
                
                return GRUserInventory(
                    userItemNumber: itemNumber,
                    userItemName: itemName,
                    userItemType: itemType,
                    userItemImage: itemImage,
                    userIteamQuantity: itemQuantity,
                    userItemDescription: itemDescription,
                    userItemEffectDescription: itemEffectDescription,
                    userItemCategory: itemCategory,
                    purchasedAt: timestamp.dateValue()
                )
            }
            
            await MainActor.run {
                // 나중에 구매한게 맨 위로 오게
                self.inventories = fetchedInventories.sorted { $0.purchasedAt > $1.purchasedAt }
            }
            print("[조회완료] 총 \(fetchedInventories.count)개 아이템 로드 완료")
        } catch {
            print("❌ [조회실패] Firebase 조회 실패: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    // MARK: - 아이템 수량 업데이트
    func updateItemQuantity(userId: String, item: GRUserInventory, newQuantity: Int) {
        let itemRef = db.collection(collectionName)
            .document(userId)
            .collection("items")
            .document(item.userItemName)

        itemRef.updateData(["userItemQuantity": newQuantity]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("❌ 수량 업데이트 실패: \(error.localizedDescription)")
                } else {
                    if newQuantity == 0 {
                        // ✅ 수량이 0이면 아이템 삭제
                        print("⚠️ 수량 0, 아이템 삭제 처리 중: \(item.userItemName)")
                        self.deleteItem(userId: userId, item: item)
                    } else {
                        // ✅ 로컬 배열 업데이트
                        if let index = self.inventories.firstIndex(where: { $0.userItemNumber == item.userItemNumber }) {
                            self.inventories[index].userItemQuantity = newQuantity
                        }
                        print("✅ 수량 업데이트 성공")
                    }
                }
            }
        }
    }
    
    // MARK: - 아이템 삭제
    func deleteItem(userId: String, item: GRUserInventory) {
        let itemRef = db.collection(collectionName)
            .document(userId)
            .collection("items")
            .document(item.userItemName)

        itemRef.delete { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("❌ 아이템 삭제 실패: \(error.localizedDescription)")
                } else {
                    // 로컬 배열에서 삭제
                    self.inventories.removeAll { $0.userItemNumber == item.userItemNumber }
                    print("🗑️ 아이템 삭제 성공")
                }
            }
        }
    }
}
