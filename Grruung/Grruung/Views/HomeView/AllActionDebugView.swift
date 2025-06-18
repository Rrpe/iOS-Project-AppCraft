//
//  AllActionDebugView.swift
//  Grruung
//
//  Created by KimJunsoo on 6/15/25.
//

import SwiftUI

struct AllActionsDebugView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 액션 매니저 참조
    private let actionManager = ActionManager.shared
    
    // 모든 액션 목록
    @State private var allActions: [PetAction] = []
    
    // 그리드 레이아웃 설정
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 15)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(allActions) { action in
                        VStack(spacing: 8) {
                            Image(action.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            Text(action.name)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 80, height: 100)
                        .padding(8)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("활동 액션 아이콘")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .background(Color.black.opacity(0.05).edgesIgnoringSafeArea(.all))
            .onAppear {
                // 모든 액션 로드
                allActions = actionManager.allActions
            }
        }
    }
}
