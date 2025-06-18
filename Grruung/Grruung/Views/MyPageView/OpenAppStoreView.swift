//
//  OpenAppStoreView.swift
//  Grruung
//
//  Created by 천수빈 on 6/12/25.
//

import SwiftUI

struct OpenAppStoreView: View {
    var body: some View {
        Button("App Store 열기") {
            if let url = URL(string: "https://apps.apple.com/app/id1234567890") {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    OpenAppStoreView()
}
