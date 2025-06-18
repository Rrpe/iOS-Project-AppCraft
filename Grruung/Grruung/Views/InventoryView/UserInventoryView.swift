//
//  UserInventoryView.swift
//  Grruung
//
//  Created by mwpark on 5/14/25.
//

import SwiftUI

struct UserInventoryView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var userInventoryViewModel = UserInventoryViewModel()
    @State var realUserId = ""
    @State private var isEdited: Bool = false
    
    // 오버레이 뷰를 위한 바인딩 프로퍼티
    @Binding var isPresented: Bool
    
    // 미리보기용 이니셜라이저 추가
    init() {
        self._isPresented = .constant(true)
    }
    
    // 실제 사용할 이니셜라이저
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    private let inventoryEmptyText: [String] = [
        "텅...",
        "가방이 조용하네요.",
        "아직 담긴 게 없어요. 조금만 더 기다려줘요.",
        "이곳은 아직 비어 있어요.",
        "아이템 하나쯤은… 곧 생기겠죠?",
        "장난감 하나만 넣어줘요!",
        "비어 있음은, 곧 채워질 준비가 된 상태예요.",
        "아무것도 없을 땐, 무한한 가능성이 있어요.",
        "빈 가방, 새로운 이야기를 기다리는 중…",
        "고요한 시작, 이곳에 추억이 담길 거예요.",
        "이럴수가! 아무것도 없어요!",
        "주인님… 가방 너무 가벼워요…",
    ]
    
    private let columns = [
        GridItem(.flexible())
    ]
    
    @State private var sortItemCategory: SortItemCategory = .food
    @State private var sortItemType: SortItemType = .all
    
    enum SortItemCategory: String, CaseIterable {
        case food = "음식"
        case drug = "약품"
        case toy = "장난감"
        case etc = "기타"
    }
    
    enum SortItemType: String {
        case all = "전체"
        case consumable = "소모품"
        case permanent = "영구"
    }
    
    var sortedItems: [GRUserInventory] {
        let itemsToSort = userInventoryViewModel.inventories
        
        switch sortItemCategory {
        case .food:
            return itemsToSort.filter { $0.userItemCategory == .food}
        case .drug:
            return itemsToSort.filter { $0.userItemCategory == .drug }
        case .toy:
            return itemsToSort.filter { $0.userItemCategory == .toy }
        case .etc:
            return itemsToSort.filter { $0.userItemCategory == .etc}
        }
    }
    
    fileprivate func itemCellView(_ item: GRUserInventory) -> some View {
        HStack {
            Image(item.userItemImage)
                .resizable()
                .frame(width: 60, height: 60)
                .aspectRatio(contentMode: .fit)
                .background(GRColor.mainColor3_1.opacity(0.3))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(GRColor.mainColor3_2.opacity(0.5), lineWidth: 1)
                )
                .padding(.trailing, 8)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(item.userItemName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(GRColor.fontMainColor)
                    Spacer()
                    Text(item.userItemType.rawValue)
                        .font(.footnote)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.userItemType == .consumable ?
                                   GRColor.grColorRed.opacity(0.7) :
                                   GRColor.mainColor3_2.opacity(0.5))
                        .foregroundStyle(item.userItemType == .consumable ? .white : GRColor.fontMainColor)
                        .cornerRadius(8)
                }
                Text(item.userItemDescription)
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundStyle(GRColor.fontSubColor)
                Text("보유: \(item.userItemQuantity)")
                    .font(.caption)
                    .foregroundStyle(GRColor.fontMainColor)
            }
        }
    }
    
    var body: some View {
        // 반투명 배경 오버레이와 함께 ZStack 사용
        ZStack {
            // 반투명 배경 오버레이
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // 뷰 밖 영역 터치 시 닫기
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // 메인 컨텐츠
            NavigationStack {
                VStack(spacing: 15) {
                    // 헤더
                    HStack {
                        Text("가방")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(GRColor.mainColor6_2)
                                .font(.system(size: 22))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 카테고리 선택
                    categoryPicker
                    
                    // 아이템 목록
                    itemsList
                }
                .background(GRColor.mainColor2_1)
                .navigationBarHidden(true) // 기본 네비게이션 바 숨기기
            }
            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.7)
            .background(GRColor.mainColor2_1)
            .cornerRadius(20)
            .shadow(color: GRColor.mainColor8_2.opacity(0.3), radius: 15, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(GRColor.mainColor3_2.opacity(0.5), lineWidth: 1)
            )
        }
        .transition(.opacity)
        .onAppear {
            Task {
                if authService.currentUserUID == "" {
                    realUserId = "23456"
                } else {
                    realUserId = authService.currentUserUID
                }
                try await userInventoryViewModel.fetchInventories(userId: realUserId)
            }
        }
    }
    
    // MARK: - Subviews
    
    // 카테고리 선택 피커
    private var categoryPicker: some View {
        Picker("Choose a category", selection: $sortItemCategory) {
            ForEach(SortItemCategory.allCases, id: \.self) { category in
                Text(category.rawValue)
                    .foregroundStyle(GRColor.fontMainColor)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(GRColor.mainColor3_2.opacity(0.7))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    // 아이템 목록
    private var itemsList: some View {
        ScrollView {
            if userInventoryViewModel.isLoading {
                ProgressView("불러오는 중...")
                    .foregroundStyle(GRColor.fontMainColor)
                    .padding()
            } else if userInventoryViewModel.inventories.isEmpty {
                VStack {
                    Image(systemName: "backpack")
                        .font(.system(size: 50))
                        .foregroundStyle(GRColor.fontSubColor.opacity(0.7))
                        .padding(.bottom, 10)
                        .padding(.top, 40)
                    
                    Text(inventoryEmptyText.randomElement() ?? "텅...")
                        .lineLimit(1)
                        .font(.title2)
                        .foregroundStyle(GRColor.fontSubColor)
                        .padding()
                }
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(sortedItems, id: \.userItemNumber) { item in
                        // NavigationLink로 변경
                        NavigationLink(destination: UserInventoryDetailView(
                            item: item,
                            realUserId: realUserId,
                            isEdited: $isEdited
                        ).onDisappear {
                            // 화면 사라질 때 데이터 갱신 (필요한 경우)
                            if isEdited {
                                isEdited = false
                                Task {
                                    try? await userInventoryViewModel.fetchInventories(userId: realUserId)
                                }
                            }
                        }) {
                            itemCellView(item)
                                .padding(16)
                                .background(GRColor.mainColor2_2.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(GRColor.mainColor3_2.opacity(0.5), lineWidth: 1.5)
                                )
                                .cornerRadius(15)
                                .shadow(color: GRColor.mainColor8_2.opacity(0.2), radius: 3, x: 0, y: 2)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.top, 10)
            }
            
            // 에러 메시지 표시
            if let errorMessage = userInventoryViewModel.errorMessage {
                Text("오류: \(errorMessage)")
                    .foregroundStyle(GRColor.grColorRed)
                    .padding()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    UserInventoryView()
        .environmentObject(AuthService())
}
