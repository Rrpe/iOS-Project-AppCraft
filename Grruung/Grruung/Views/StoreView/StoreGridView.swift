//
//  StoreGridView.swift
//  Grruung
//
//  Created by 심연아 on 5/12/25.
//

import SwiftUI

struct StoreGridView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @Binding var refreshTrigger: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(products) { product in
                        NavigationLink(destination: ProductDetailView(product: product, refreshTrigger: $refreshTrigger)) {
                            ProductItemView(product: product)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}

struct ProductItemView: View {
    let product: GRStoreItem
    @State private var isLimitedItemVisible = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Image(product.itemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.black)
                
                if product.itemTag == ItemTag.limited {
                    Text("한정")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .opacity(isLimitedItemVisible ? 1 : 0)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                isLimitedItemVisible.toggle()
                            }
                        }
                }
            }
            
            Text(product.itemName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
            
            HStack(spacing: 8) {
                if product.itemCurrencyType == .won {
                    Text("₩")
                        .foregroundStyle(.black)
                } else {
                    Image(systemName: product.itemCurrencyType.rawValue == ItemCurrencyType.diamond.rawValue ? "diamond.fill" : "circle.fill")
                        .foregroundStyle(product.itemCurrencyType.rawValue == ItemCurrencyType.diamond.rawValue ? .cyan : .yellow)
                }
                
                Text("\(product.itemPrice)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(8)
    }
}

//#Preview {
//    StoreGridView()
//}
