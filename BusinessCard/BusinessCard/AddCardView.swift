//
//  AddCardView.swift
//  BusinessCard
//
//  Created by KimJunsoo on 1/23/25.
//

import SwiftUI
import SwiftData

struct AddCardView: View {
    let maxText = "ILLUSTRATOR".prefix(13)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white // 카드 배경색
                    .cornerRadius(15)
                    .shadow(radius: 5)
                
                // 좌측 상단: ILLUSTRATOR (세로)
                HStack(alignment: .top) {
                    VStack {
                        Text(String(maxText))  // Change TextField
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(90)) // 세로로 회전
                            .background(
                                Rectangle()
                                    .frame(height: 2)
                                    .rotationEffect(.degrees(90)) // 세로로 회전
                                    .offset(x: -11)
                            )
                            .lineLimit(1)
                            .frame(height: 200)
                            .frame(width: 100)
                            .padding(.leading, -15) // 좌측으로 이동되도록 간격 조정
                            .padding(.top, -20) // 상단으로 이동되도록 간격 조정
                        Spacer()
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(20)
                    }
                }
                
                // 중앙 이미지와 텍스트 정보
                VStack {
                    Spacer()
                    
                    // 중앙 프로필 이미지
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // 하단 텍스트 정보
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Karita") // Change TextField
                                .font(.title2)
                                .fontWeight(.bold)
                                .background(
                                    Rectangle()
                                        .frame(height: 2)
                                        .offset(y: 15)
                                )
                            
                            Text("MAIL | karita.n775@gmail.com") // Change TextField
                                .font(.footnote)
                                .foregroundColor(.black)
                            
                            Text("Git | @gesooo_4") // Change TextField
                                .font(.footnote)
                                .foregroundColor(.black)
                            
                            Text("PHONE | 010-1234-5678") // Change TextField
                                .font(.footnote)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .center) // 텍스트 중앙 정렬
                        .padding(.leading, -50)
                        .padding(.bottom, 20)
                    }
                }
            }
            .padding()
            .frame(width: 320, height: 520) // 명함 크기
            .background(Color(UIColor.systemGray5))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveCard()
                    }) {
                        Text("저장")
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
    
    func saveCard() {
        print("카드 저장 버튼 클릭됨")
        insert
    }
}

#Preview {
    AddCardView()
}
