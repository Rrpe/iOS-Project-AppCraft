//
//  ActionProgressView.swift
//  Grruung
//
//  Created by NoelMacMini on 6/14/25.
//

import SwiftUI

// ✨1 액션 진행률을 표시할 새로운 뷰
struct ActionProgressView: View {
    let progress: CGFloat
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            // 양 옆의 공간을 차지할 투명한 플레이스홀더
            Color.clear.frame(width: 75, height: 75)

            VStack {
                Text(text)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "07a5ed")))
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
            }
            .padding(.horizontal)

            Color.clear.frame(width: 75, height: 75)
        }
        .frame(height: 75) // actionButtonsGrid와 동일한 높이 유지
    }
}


//#Preview {
//    ActionProgressView(progress: <#CGFloat#>, text: <#String#>)
//}
