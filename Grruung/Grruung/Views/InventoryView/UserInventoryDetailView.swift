//
//  UserInventoryDetailView.swift
//  Grruung
//
//  Created by mwpark on 5/14/25.
//

import SwiftUI

struct UserInventoryDetailView: View {
    @State var item: GRUserInventory
    @State var realUserId: String
    @Binding var isEdited: Bool
    
    @State private var useItemCount: Double = 1  // 기본값 1로 설정
    @State private var typeItemCount: String = "1"  // 기본값 1로 설정
    
    @State private var showAlert = false
    @State private var alertType: AlertType = .itemCount
    
    // 랜덤박스 관련 변수
    @State private var selectedItems: [GRStoreItem] = []
    @State private var currentIndex = 0
    @State private var showPopup = false
    @State private var showAnimation: Bool = false
    
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @StateObject private var userInventoryViewModel = UserInventoryViewModel()
    
    enum AlertType {
        case itemCount, useItem, deleteItem, reDeleteItem, noDeleteItem
    }
    
    var body: some View {
        basicDetailView
            .navigationTitle("")  // 타이틀 제거
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)  // 기본 Back 버튼 숨기기
            .navigationBarItems(leading: customBackButton)  // 커스텀 백 버튼 추가
            .background(GRColor.mainColor2_1)
            .alert(alertTitle, isPresented: $showAlert) {
                alertButtons
            } message: {
                alertMessage
            }
    }
    
    // 커스텀 백 버튼
    private var customBackButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color(hex: "8B4513"))  // 갈색으로 설정
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var basicDetailView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if showPopup, currentIndex < selectedItems.count {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    ItemPopupView(
                        item: selectedItems[currentIndex],
                        userId: realUserId,
                        isPresented: Binding(
                            get: { showPopup },
                            set: { newValue in
                                if !newValue {
                                    // 다음 아이템으로 넘어감
                                    if currentIndex + 1 < selectedItems.count {
                                        currentIndex += 1
                                        showAnimation = true
                                    } else {
                                        showPopup = false
                                        dismiss()
                                    }
                                }
                            }
                        ),
                        animate: $showAnimation)
                } else {
                    // 아이템 기본 정보
                    itemBasicInfoView
                    
                    // 아이템 효과 설명
                    //                itemEffectView
                    
                    // 아이템 타입에 따라 다른 UI
                    if item.userItemType == .consumable {
                        consumableItemView
                    } else {
                        permanentItemView
                    }
                }
            }
            .padding()
        }
    }
    
    // 아이템 기본 정보
    private var itemBasicInfoView: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(item.userItemName)
                .font(.title3)
                .bold()
                .foregroundStyle(.black)
            
            Text(item.userItemType.rawValue)
                .font(.caption)
                .foregroundStyle(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            
            Image(item.userItemImage)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .cornerRadius(10)
                .padding(.vertical, 5)
            
            Text(item.userItemDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.black)
            
            Text("보유: \(item.userItemQuantity)")
                .font(.subheadline)
                .padding(.top, 4)
                .foregroundStyle(.black)
        }
        .padding()
        .background(GRColor.mainColor2_2.opacity(0.3))
        .cornerRadius(15)
    }
    
    // 아이템 효과 설명
    private var itemEffectView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("사용 효과")
                .font(.headline)
                .foregroundStyle(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                // 효과 내용을 행별로 분리하여 표시
                // 예: "포만감 +100\n체력 +100\n활동량 +100"
                ForEach(item.userItemEffectDescription.split(separator: "\n"), id: \.self) { line in
                    Text(String(line))
                        .foregroundStyle(.black)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GRColor.mainColor2_2.opacity(0.4))
            .cornerRadius(10)
        }
        .padding()
        .background(GRColor.mainColor2_2.opacity(0.2))
        .cornerRadius(15)
    }
    
    // 소모품 아이템 뷰
    private var consumableItemView: some View {
        VStack(spacing: 15) {
            // 수량 선택 컨트롤
            VStack(spacing: 10) {
                Text("수량:")
                    .font(.headline)
                    .foregroundColor(.black)
                
                // 수량 입력 및 +/- 버튼
                HStack {
                    // 마이너스 버튼
                    Button(action: {
                        if useItemCount > 1 {
                            useItemCount -= 1
                            typeItemCount = "\(Int(useItemCount))"
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(useItemCount > 1 ? .gray : .gray.opacity(0.5))
                    }
                    .disabled(useItemCount <= 1)
                    
                    // 텍스트 필드
                    Text("\(Int(useItemCount))")
                        .frame(width: 60)
                        .padding(8)
                    //                        .background(Color.white)
                        .cornerRadius(8)
                    //                        .overlay(
                    //                            RoundedRectangle(cornerRadius: 8)
                    //                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    //                        )
                    
                    // 플러스 버튼
                    Button(action: {
                        if useItemCount < Double(item.userItemQuantity) {
                            useItemCount += 1
                            typeItemCount = "\(Int(useItemCount))"
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(useItemCount < Double(item.userItemQuantity) ? .gray : .gray.opacity(0.5))
                    }
                    .disabled(useItemCount >= Double(item.userItemQuantity))
                }
                
                // 슬라이더 - 버그 수정: 최소값과 최대값이 같을 때 슬라이더를 비활성화
                if item.userItemQuantity > 1 {
                    Slider(value: $useItemCount, in: 1...Double(item.userItemQuantity), step: 1)
                        .onChange(of: useItemCount) { _, newValue in
                            typeItemCount = "\(Int(newValue))"
                        }
                        .accentColor(GRColor.mainColor3_2)
                } else {
                    // 수량이 1 이하인 경우 슬라이더 대신 텍스트 표시
                    Text("수량이 1개 뿐입니다.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                }
            }
            .padding()
            .background(GRColor.mainColor2_2.opacity(0.2))
            .cornerRadius(15)
            
            // 버튼 (버리기, 사용하기 순서로 변경)
            HStack {
                // 버리기 버튼 (왼쪽)
                deleteButton
                
                // 사용하기 버튼 (오른쪽)
                useButton
            }
        }
    }
    
    // 영구 아이템 뷰
    private var permanentItemView: some View {
        VStack {
            Text("영구 아이템은 버리거나 사용할 수 없습니다.")
                .padding()
                .foregroundStyle(.black)
            
            Button("확인") {
                dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(GRColor.mainColor3_2)
            .foregroundStyle(.black)
            .cornerRadius(15)
        }
    }
    
    // 사용 버튼
    private var useButton: some View {
        Button {
            isFocused = false
            validateUseCount()
        } label: {
            Text("사용하기")
                .padding()
                .frame(maxWidth: .infinity)
                .background(GRColor.mainColor3_2)
                .foregroundStyle(.black)
                .cornerRadius(15)
        }
    }
    
    // 삭제 버튼
    private var deleteButton: some View {
        Button {
            isFocused = false
            alertType = .deleteItem
            showAlert = true
        } label: {
            Text("버리기")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.7))
                .foregroundStyle(.white)
                .cornerRadius(15)
        }
    }
    
    // 알림창 타이틀
    private var alertTitle: String {
        switch alertType {
        case .itemCount:
            return "올바른 수를 입력해주세요"
        case .useItem:
            return "아이템을 사용합니다"
        case .deleteItem:
            return "해당 아이템을 모두 버립니다."
        case .reDeleteItem:
            return "정말로 모든 수량을 버리시겠습니까?"
        case .noDeleteItem:
            return "영구 아이템은 버릴 수 없습니다"
        }
    }
    
    // 알림창 메시지
    private var alertMessage: Text? {
        switch alertType {
        case .useItem:
            return Text("\(item.userItemName) \(Int(useItemCount))개를 사용하시겠습니까?")
        default:
            return nil
        }
    }
    
    // 알림창 버튼
    @ViewBuilder
    private var alertButtons: some View {
        switch alertType {
        case .itemCount, .noDeleteItem:
            Button("확인", role: .cancel) {}
            
        case .useItem:
            Button("취소", role: .cancel) {}
            Button("확인") {
                useItem()
            }
            
        case .deleteItem:
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                if item.userItemType == .permanent {
                    alertType = .noDeleteItem
                    
                    showAlert = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showAlert = true
                    }
                } else {
                    deleteItem()
                }
            }
            
        case .reDeleteItem:
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                deleteItem()
            }
        }
    }
    
    // 수량 검증 메서드
    private func validateUseCount() {
        // 슬라이더로 갯수 선택된 경우
        if useItemCount > 0 {
            alertType = .useItem
            showAlert = true
        }
        // 직접 갯수 입력한 경우
        else if let count = Int(typeItemCount), count > 0 {
            if count <= item.userItemQuantity {
                useItemCount = Double(count)
                alertType = .useItem
                showAlert = true
            } else {
                alertType = .itemCount
                showAlert = true
            }
        } else {
            alertType = .itemCount
            showAlert = true
        }
    }
    
    // 아이템 사용 메서드
    private func useItem() {
        // ItemEffectApplier를 통해 아이템 효과 적용
        let effectResult = ItemEffectApplier.shared.applyItemEffect(item: item, quantity: Int(useItemCount))
        realUserId = authService.currentUserUID
        if effectResult.success {
            // 아이템 수량 감소
            item.userItemQuantity -= Int(useItemCount)
            isEdited = true
            
            // 랜덤박스선물 아이템일 경우 팝업 창 띄움
            if item.userItemName == "랜덤박스선물" {
                // 놀이 + 회복 아이템 합치고 랜덤 선택
                let allItems = playProducts + recoveryProducts
                let randomItems = (0..<Int(useItemCount)).compactMap { _ in allItems.randomElement() } // 예: 3개 사용
                selectedItems = randomItems
                currentIndex = 0
                showPopup = true
            }
            
            // 데이터베이스 업데이트
            Task {
                // 아이템 수량 업데이트 - 기존 파이어베이스 구조 유지
                UserInventoryViewModel().updateItemQuantity(
                    userId: realUserId,  // 전달받은 realUserId 사용
                    item: item,
                    newQuantity: item.userItemQuantity
                )
            }
            
            // 적용된 효과 메시지를 표시할 수 있는 알림창 추가 (선택사항)
            // 여기서는 콘솔에만 출력
            print("✅ 아이템 효과 적용: \(effectResult.message)")
        } else {
            print("❌ 아이템 효과 적용 실패: \(effectResult.message)")
        }
        
        if selectedItems.isEmpty {
            dismiss()
        }
    }
    
    // 아이템 삭제 메서드
    private func deleteItem() {
        // 아이템 삭제 로직 구현
        isEdited = true
        
        // 데이터베이스에서 아이템 삭제 - 기존 파이어베이스 구조 유지
        Task {
            // 아이템 완전히 삭제
            UserInventoryViewModel().deleteItem(
                userId: realUserId,  // 전달받은 realUserId 사용
                item: item
            )
            print("🗑️ 아이템 삭제 요청 완료: \(item.userItemName)")
        }
        
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        let sampleItem = GRUserInventory(
            userItemNumber: "1",
            userItemName: "쉐이크",
            userItemType: .consumable,
            userItemImage: "icecream",
            userIteamQuantity: 9,
            userItemDescription: "달콤한 쉐이크로\n스트레스를 잠시 잊어보세요!",
            userItemEffectDescription: "포만감\t + 100\n체력\t + 100\n활동량\t + 100",
            userItemCategory: .toy,
            purchasedAt: Date()
        )
        
        return UserInventoryDetailView(item: sampleItem, realUserId: "test", isEdited: .constant(false))
            .environmentObject(AuthService())
    }
}
