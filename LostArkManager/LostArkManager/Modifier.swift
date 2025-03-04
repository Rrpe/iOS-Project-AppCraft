//
//  Modifier.swift
//  LostArkManager
//
//  Created by KimJunsoo on 2/11/25.
//

import SwiftUI

struct CroneTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(.white)
            .padding(.bottom, 8)
    }
}

extension View {
    func croneTextModifier() -> some View {
        modifier(CroneTextModifier())
    }
}
