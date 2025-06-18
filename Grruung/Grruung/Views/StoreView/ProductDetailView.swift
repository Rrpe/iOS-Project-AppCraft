//
//  ProductDetailView.swift
//  Grruung
//
//  Created by 심연아 on 5/12/25.
//

//
//  ProductDetailView.swift
//  Grruung
//
//  Created by 심연아 on 5/12/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: GRStoreItem
    @State private var quantity: Int = 1
    @State private var showAlert = false
    @State private var isRotating = false
    @State private var isBouncing = false
    @State private var isOutOfLimitedQuantity: Bool = false
    @Binding var refreshTrigger: Bool
    @EnvironmentObject var userInventoryViewModel: UserInventoryViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var shouldDismiss = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 제품명 + 가격
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.itemName)
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.black)
                        HStack(spacing: 8) {
                            if product.itemCurrencyType == .won {
                                Text("₩")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(.black)
                            } else {
                                if product.itemCurrencyType.rawValue == ItemCurrencyType.diamond.rawValue {
                                    Image(systemName: "diamond.fill")
                                        .resizable()
                                        .frame(width: 20, height: 25)
                                        .foregroundStyle(.cyan)
                                } else {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(.yellow)
                                }
                            }
                            
                            Text("\(product.itemPrice)")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.black)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 제품 이미지
                    ZStack {
                        // 바닥 그림자처럼 보이는 배경 타원형
                        Ellipse()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 140, height: 20)
                            .offset(y: 90)
                        
                        // 메인 이미지
                        Image(product.itemImage)
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(isRotating ? 3 : -3))
                            .offset(y: isBouncing ? -2 : 2)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                    isRotating = true
                                }
                                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                    isBouncing = true
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // 설명
                    Text(product.itemDescription)
                        .font(.body)
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            // 수량 선택
            if product.itemCurrencyType != .won {
                HStack {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus.circle")
                            .foregroundStyle(GRColor.buttonColor_1)
                            .font(.title2)
                    }
                    
                    Text("\(quantity)")
                    
                        .font(.title)
                        .padding(.horizontal, 16)
                    
                    Button {
                        if quantity < product.limitedQuantity {
                            quantity += 1
                        } else {
                            isOutOfLimitedQuantity = true
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(GRColor.buttonColor_2)
                            .font(.title2)
                    }
                    .alert("한정 수량 이상을 구매하실 수 없습니다.", isPresented: $isOutOfLimitedQuantity) {
                        Button("확인", role: .cancel) { }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // 하단 버튼
            HStack {
                Button(action: {
                    refreshTrigger.toggle()
                    dismiss()
                }, label: {
                    Text("취소하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .scrollContentBackground(.hidden) // 기본 배경을 숨기고
                        .background(
                            LinearGradient(colors: [Color.red.opacity(0.4), Color.red.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    
                })
                Spacer()
                Button(action: {
                    showAlert = true
                }) {
                    Text("구매하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .scrollContentBackground(.hidden) // 기본 배경을 숨기고
                        .background(
                            LinearGradient(colors: [GRColor.buttonColor_1, GRColor.buttonColor_2], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .scrollContentBackground(.hidden) // 기본 배경을 숨기고
        .background(
            LinearGradient(colors: [GRColor.mainColor2_1, GRColor.mainColor2_2], startPoint: .top, endPoint: .bottom)
        ) // 원하는 색상 지정
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ReturnToStoreView"))) { _ in
            // 알림을 받으면 뷰를 닫아 StoreView로 돌아가기
//            refreshTrigger.toggle()
            dismiss()
        }
        .sheet(isPresented: $showAlert) {
            AlertView(product: product, quantity: quantity, isPresented: $showAlert, refreshTrigger: $refreshTrigger)
                .environmentObject(userInventoryViewModel)
                .environmentObject(userViewModel)
                .environmentObject(authService)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EmptyView()
            }
        }
    }
}


//#Preview {
//    if let product = diamondProducts.first {
//        ProductDetailView(product: product)
//    } else {
//        Text("샘플 데이터 없음")
//    }
//}
