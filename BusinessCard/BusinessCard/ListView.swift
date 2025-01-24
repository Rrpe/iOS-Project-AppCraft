//
//  ListView.swift
//  BusinessCard
//
//  Created by KimJunsoo on 1/23/25.
//

import SwiftUI
import SwiftData

struct ListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var cards: [CardData]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(cards, id: \.self) { card in
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(card.name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(card.job)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                HStack {
                                    Text("Phone: \(card.phone)")
                                        .font(.footnote)
                                    Spacer()
                                    Text("Email: \(card.mail)")
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                        }
                        .frame(height: 100)
                    }
                }
                .padding()
            }
            .navigationTitle("명함 리스트")
            .background(Color(UIColor.systemGray5))
        }
        .onAppear { // 디폴트값 추가
            if cards.isEmpty {
                let defaultCards = [
                    CardData(job: "ILLUSTRATOR", image: nil, qrCode: nil, name: "Karita", mail: "karita_n370@gmail.com", github: "github.com/Karita-n37", phone: "010-1234-5678"),
                    CardData(job: "DEVELOPER", image: nil, qrCode: nil, name: "Winter", mail: "winter_21@gmail.com", github: "github.com/winter_21", phone: "010-5678-1234")
                ]
                for card in defaultCards {
                    modelContext.insert(card) // SwiftData 컨텍스트에 데이터 삽입
                }
            }
        }
    }
}

#Preview {
    ListView()
        .modelContainer(for: CardData.self, inMemory: true)

}
