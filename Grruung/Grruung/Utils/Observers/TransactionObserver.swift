//
//  TransactionObserver.swift
//  Grruung
//
//  Created by mwpark on 5/30/25.
//
// 엡 실행시 결제 여부를 확인하는 클래스
import StoreKit

final class TransactionObserver: ObservableObject {
    init() {
        Task {
            await observeTransactionUpdates()
        }
    }

    func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                // ✅ 구매 완료 처리
                print("🔁 구매 업데이트 감지: \(transaction.productID)")
                // 예: 영수증 저장, UI 업데이트 등

                await transaction.finish()
            }
        }
    }
}
