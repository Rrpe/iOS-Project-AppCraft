//
//  PurchaseHistoryView.swift
//  Grruung
//
//  Created by KimJunsoo on 6/12/25.
//

import SwiftUI
import FirebaseFirestore

// MARK: - 결제 기록 모델
struct PurchaseRecord: Identifiable {
    let id: String
    let itemName: String
    let itemImage: String
    let quantity: Int
    let price: Int
    let currencyType: ItemCurrencyType
    let purchaseDate: Date
    let isRealMoney: Bool
    
    init(id: String = UUID().uuidString,
         itemName: String,
         itemImage: String,
         quantity: Int,
         price: Int,
         currencyType: ItemCurrencyType,
         purchaseDate: Date,
         isRealMoney: Bool = true) {
        self.id = id
        self.itemName = itemName
        self.itemImage = itemImage
        self.quantity = quantity
        self.price = price
        self.currencyType = currencyType
        self.purchaseDate = purchaseDate
        self.isRealMoney = isRealMoney
    }
    
    // Firestore 데이터로부터 생성
    static func fromFirestore(id: String, data: [String: Any]) -> PurchaseRecord? {
        guard
            let itemName = data["itemName"] as? String,
            let itemImage = data["itemImage"] as? String,
            let quantity = data["quantity"] as? Int,
            let price = data["price"] as? Int,
            let currencyTypeRaw = data["currencyType"] as? String,
            let currencyType = ItemCurrencyType(rawValue: currencyTypeRaw),
            let timestamp = data["purchaseDate"] as? Timestamp,
            let isRealMoney = data["isRealMoney"] as? Bool
        else {
            return nil
        }
        
        return PurchaseRecord(
            id: id,
            itemName: itemName,
            itemImage: itemImage,
            quantity: quantity,
            price: price,
            currencyType: currencyType,
            purchaseDate: timestamp.dateValue(),
            isRealMoney: isRealMoney
        )
    }
}

// MARK: - 구매 내역 화면
struct PurchaseHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userInventoryViewModel: UserInventoryViewModel
    @EnvironmentObject private var authService: AuthService
    @State private var isLoading = false
    @State private var purchaseRecords: [PurchaseRecord] = []
    @State private var selectedTab: PurchaseTab = .all
    
    enum PurchaseTab: String, CaseIterable {
        case all = "전체"
        case diamond = "다이아 구매"
        case petUnlock = "펫 해금"
    }
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 선택 부분
            HStack(spacing: 10) {
                ForEach(PurchaseTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.rawValue,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            Divider()
                .padding(.vertical, 5)
            
            // 로딩 및 내용 표시
            if isLoading {
                ProgressView("데이터를 불러오는 중...")
                    .padding()
                    .frame(maxHeight: .infinity)
            } else if filteredRecords.isEmpty {
                VStack {
                    Spacer()
                    Text("구매 내역이 없습니다")
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredRecords) { record in
                        PurchaseHistoryItem(record: record)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(GRColor.subColorOne) // 갈색으로 변경
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("결제 내역")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
        .toolbarRole(.browser) // 간격을 더 줄이는 역할

        .background(
            LinearGradient(
                colors: [GRColor.mainColor3_1, GRColor.mainColor3_2],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            loadData()
        }
        .refreshable {
            loadData()
        }
    }
    
    // MARK: - 내부 메서드
    
    // 필터링된 아이템
    private var filteredRecords: [PurchaseRecord] {
        switch selectedTab {
        case .all:
            return purchaseRecords
        case .diamond:
            return purchaseRecords.filter { $0.itemName.contains("다이아") }
        case .petUnlock:
            return purchaseRecords.filter { $0.itemName.contains("동산 잠금해제") }
        }
    }
    
    // 데이터 로드
    private func loadData() {
        isLoading = true
        purchaseRecords = []
        
        // 실제 유저 ID 또는 테스트 ID
        let userId = authService.currentUserUID.isEmpty ? "23456" : authService.currentUserUID
        
        // 결제 기록 컬렉션 참조
        let purchaseRecordsRef = db.collection("users").document(userId).collection("purchaseRecords")
        
        // Firestore에서 구매 기록 가져오기
        purchaseRecordsRef.order(by: "purchaseDate", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("결제 기록 불러오기 실패: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            var records: [PurchaseRecord] = []
            
            // Firestore에서 직접 결제 기록 가져오기
            if let documents = snapshot?.documents, !documents.isEmpty {
                for document in documents {
                    if let record = PurchaseRecord.fromFirestore(id: document.documentID, data: document.data()) {
                        records.append(record)
                    }
                }
            }
            
            // 기록이 없거나 적을 경우, 인벤토리에서 보완
            if records.isEmpty || records.count < 2 {
                // UserInventory에서 데이터 가져오기
                Task {
                    do {
                        try await userInventoryViewModel.fetchInventories(userId: userId)
                        
                        let inventoryRecords = userInventoryViewModel.inventories
                            .filter {
                                ($0.userItemName.contains("다이아") ||
                                $0.userItemName.contains("동산 잠금해제"))
                            }
                            .map { inventory -> PurchaseRecord in
                                let isRealMoney = inventory.userItemImage.contains("diamond_") ||
                                                 inventory.userItemImage.contains("charDex_unlock_ticket")
                                
                                return PurchaseRecord(
                                    id: inventory.id,
                                    itemName: inventory.userItemName,
                                    itemImage: inventory.userItemImage,
                                    quantity: inventory.userItemQuantity,
                                    price: 0, // 가격 정보는 없음
                                    currencyType: .won,
                                    purchaseDate: inventory.purchasedAt,
                                    isRealMoney: isRealMoney
                                )
                            }
                        
                        // 중복 제거를 위한 ID 집합
                        let existingIds = Set(records.map { $0.id })
                        let uniqueInventoryRecords = inventoryRecords.filter { !existingIds.contains($0.id) }
                        
                        await MainActor.run {
                            self.purchaseRecords = (records + uniqueInventoryRecords).sorted(by: { $0.purchaseDate > $1.purchaseDate })
                            self.isLoading = false
                        }
                    } catch {
                        print("인벤토리 로드 실패: \(error.localizedDescription)")
                        await MainActor.run {
                            self.purchaseRecords = records
                            self.isLoading = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.purchaseRecords = records
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - 보조 뷰

// 탭 버튼
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 6)
                .padding(.horizontal, 15)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(
                    Capsule()
                        .fill(isSelected ? GRColor.buttonColor_2 : Color.white.opacity(0.6))
                )
                .shadow(color: isSelected ? Color.black.opacity(0.2) : Color.clear, radius: 2, x: 0, y: 1)
        }
    }
}

// 구매 내역 항목
struct PurchaseHistoryItem: View {
    let record: PurchaseRecord
    
    var body: some View {
        HStack(spacing: 15) {
            // 아이템 이미지
            if record.itemImage.contains("diamond_") {
                Image(systemName: "diamond.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.cyan)
                    .padding(8)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
            } else if record.itemImage.contains("charDex_unlock_ticket") {
                Image(systemName: "ticket.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.purple)
                    .padding(8)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
            } else {
                Image(systemName: "cart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.blue)
                    .padding(8)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
            }
            
            // 아이템 정보
            VStack(alignment: .leading, spacing: 5) {
                Text(record.itemName)
                    .fontWeight(.medium)
                
                HStack {
                    // 아이템 수량
                    Text("\(record.quantity)개")
                        .font(.footnote)
                        .foregroundStyle(.black)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 8)
                        .cornerRadius(5)
                    
                    Spacer()
                    
                    // 구매 날짜 (오른쪽 패딩 추가)
                    Text(formattedDate(record.purchaseDate))
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.trailing, 10) // 날짜 오른쪽 패딩 추가
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
    
    // 날짜 포매팅
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
