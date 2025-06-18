//
//  StoreTestFetcher.swift
//  Grruung
//
//  Created by mwpark on 5/30/25.
//

import StoreKit

class StoreItemFetcher: ObservableObject {
    @Published var products: [Product]?

    let productIDs = [
        "com.smallearedcat.grruung.charDex_unlock_ticket",
        "com.smallearedcat.grruung.diamond_5",
        "com.smallearedcat.grruung.diamond_12",
        "com.smallearedcat.grruung.diamond_30",
        "com.smallearedcat.grruung.diamond_65",
        "com.smallearedcat.grruung.diamond_140",
        "com.smallearedcat.grruung.diamond_300",
    ]

    init() {
        Task {
            await loadProducts()
        }
    }

    func loadProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            await MainActor.run {
                self.products = fetchedProducts
            }
        } catch {
            print("상품 로딩 실패: \(error)")
        }
    }
}
