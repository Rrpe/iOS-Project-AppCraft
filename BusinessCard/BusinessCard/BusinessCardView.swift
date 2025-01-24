//
//  BusinessCardView.swift
//  BusinessCard
//
//  Created by KimJunsoo on 1/22/25.
//

import SwiftUI
import SwiftData

// !!! 작업 시작하면 border 다 지우기
struct BusinessCardView: View {
    let maxText = "ILLUSTRATOR".prefix(13)
    
    var body: some View {
        ZStack {
            Color.white // 배경색
                .cornerRadius(15)
                .shadow(radius: 5)
            
            // 좌측 상단: ILLUSTRATOR (세로)
            HStack(alignment: .top) {
                VStack {
                    Text(String(maxText))
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
                    //                        .frame(minHeight: 200, maxHeight: .infinity)
                        .frame(width: 100)
                        .padding(.leading, -15) // 좌측으로 이동되도록 간격 조정
                        .padding(.top, -20) // 상단으로 이동되도록 간격 조정
                    //                        .padding(.bottom, 300)
                        .border(Color.red, width: 1)
                    Spacer()
                }
                Spacer()
                VStack {
                    Image(systemName: "qrcode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(20)
                        .border(Color.red, width: 1)
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
                    .border(Color.blue, width: 1)
                
                Spacer()
                
                // 하단 텍스트 정보
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Karita")
                            .font(.title2)
                            .fontWeight(.bold)
                            .background(
                                Rectangle()
                                    .frame(height: 2)
                                    .offset(y: 15)
                            )
                        
                        Text("MAIL | karita.n775@gmail.com")
                            .font(.footnote)
                            .foregroundColor(.black)
                        
                        Text("Git | @gesooo_4")
                            .font(.footnote)
                            .foregroundColor(.black)
                        
                        Text("PHONE | 010-1234-5678")
                            .font(.footnote)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // 텍스트 중앙 정렬
                    .padding(.leading, -50)
                    .padding(.bottom, 20)
                    .border(Color.blue, width: 1)
                }
            }
        }
        .padding()
        .frame(width: 320, height: 520) // 명함 크기
        .background(Color(UIColor.systemGray5))
    }
}

#Preview {
    BusinessCardView()
}
