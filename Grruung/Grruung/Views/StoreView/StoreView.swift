//
//  StoreView.swift
//  Grruung
//
//  Created by 심연아 on 5/1/25.
//

import SwiftUI

struct StoreView: View {
    let tabs = ["전체", "놀이", "음식", "다이아", "티켓"]
    @State private var selectedTab = 0
    @State private var gold = 0
    @State private var diamond = 0
    @State private var refreshTrigger: Bool = false
    
    @StateObject var userInventoryViewModel = UserInventoryViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.colorScheme) var colorScheme
    
    @State var realUserId = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
//                Text("")
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .font(.largeTitle)
//                    .foregroundStyle(.black)
//                    .bold()
//                Spacer()
                Spacer()
                
                HStack {
                    // 다이아
                    HStack(spacing: 8) {
                        Image(systemName: "diamond.fill")
                            .resizable()
                            .frame(width: 20, height: 25)
                            .foregroundStyle(.cyan)
                        Text("\(diamond)")
                            .lineLimit(1)
                            .font(.title3)
                            .foregroundStyle(.black)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // 골드
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.yellow)
                        Text("\(gold)")
                            .lineLimit(1)
                            .font(.title3)
                            .foregroundStyle(.black)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                .padding(.leading, 50)
                .padding(.trailing, 50)
                // 상단 탭
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(tabs.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    selectedTab = index
                                }
                            }) {
                                VStack {
                                    Text(tabs[index])
                                        .font(.headline)
                                        .foregroundStyle(selectedTab == index ? .black : .gray)
                                    Capsule()
                                        .fill(selectedTab == index ? GRColor.buttonColor_2 : Color.clear)
                                        .frame(height: 3)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 15)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // ScrollViewReader로 섹션 이동
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 45) {
                            // 각 섹션은 ID로 scrollTo 대상
                            SectionView(title: "전체", id: "전체", products: allProducts, proxy: proxy, refreshTrigger: $refreshTrigger)
                                .environmentObject(userInventoryViewModel)
                                .environmentObject(userInventoryViewModel)
                            SectionView(title: "놀이", id: "놀이", products: playProducts, proxy: proxy, refreshTrigger: $refreshTrigger)
                                .environmentObject(userInventoryViewModel)
                            SectionView(title: "음식", id: "음식", products: recoveryProducts, proxy: proxy, refreshTrigger: $refreshTrigger)
                                .environmentObject(userInventoryViewModel)
                            SectionView(title: "다이아", id: "다이아", products: diamondProducts, proxy: proxy, refreshTrigger: $refreshTrigger)
                                .environmentObject(userInventoryViewModel)
                            SectionView(title: "티켓", id: "티켓", products: ticketProducts, proxy: proxy, refreshTrigger: $refreshTrigger)
                                .environmentObject(userInventoryViewModel)
                        }
                        .padding()
                    }
                    .onChange(of: selectedTab) { _, newIndex in
                        withAnimation {
                            proxy.scrollTo(tabs[newIndex], anchor: .top)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline) // 기본 타이틀 공간 최소화
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView() // 기본 타이틀 제거
                }
            }
            .background(
                LinearGradient(colors: [GRColor.mainColor2_1, GRColor.mainColor2_2], startPoint: .top, endPoint: .bottom)
            ) // 원하는 색상 지정
        } //
        .onAppear {
            // 상점 진입 시 사용자 인벤토리 미리 로드
            Task {
                realUserId = authService.currentUserUID.isEmpty ? "23456" : authService.currentUserUID
                
                do {
                    try await userViewModel.fetchUser(userId: realUserId)
                    print("[유저로드] \(realUserId) user 로드 완료")
                    
                    gold = userViewModel.user?.gold ?? 0
                    diamond = userViewModel.user?.diamond ?? 0
                } catch {
                    print("[유저로드] 유저 로드 실패: \(error.localizedDescription)")
                }
                
                do {
                    try await userInventoryViewModel.fetchInventories(userId: realUserId)
                    print("[상점진입] 인벤토리 미리 로드 완료")
                } catch {
                    print("[상점진입] 인벤토리 로드 실패: \(error.localizedDescription)")
                }
            }
        }
        .id(refreshTrigger)
        .environmentObject(userInventoryViewModel)
    }
}

// 제품 리스트 보여주는 섹션 뷰
struct SectionView: View {
    let title: String
    let id: String
    let products: [GRStoreItem]
    let proxy: ScrollViewProxy
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @Binding var refreshTrigger: Bool
    @EnvironmentObject var userInventoryViewModel: UserInventoryViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    proxy.scrollTo(id, anchor: .top)
                }
            }) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.black)
            }
            .id(id)
            .padding(.horizontal)
            
            Divider()
                .frame(height: 1)
                .background(Color.black.opacity(0.7 ))
                .padding(.vertical, 8)
            
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetailView(product: product, refreshTrigger: $refreshTrigger))
                    {
                        ProductItemView(product: product)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    StoreView()
        .environmentObject(AuthService())
        .environmentObject(UserViewModel())
}
