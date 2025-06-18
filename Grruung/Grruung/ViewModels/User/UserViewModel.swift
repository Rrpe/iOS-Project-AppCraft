//
//  UserViewModel.swift
//  Grruung
//
//  Created by mwpark on 5/27/25.
//

import Foundation
import FirebaseFirestore
import Combine

class UserViewModel: ObservableObject, Equatable {
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        return lhs.user?.gold == rhs.user?.gold && lhs.user?.diamond == rhs.user?.diamond
    }
    
    @Published var user: GRUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let collectionName = "users"

    // MARK: - 사용자 저장
    // 로그인 시 저장하므로 사용할 필요x
    @MainActor
    func saveUser(_ user: GRUser) async {
        do {
            let data: [String: Any] = [
                "userEmail": user.userEmail,
                "userName": user.userName,
                "registeredAt": Timestamp(date: user.registeredAt),
                "lastUpdatedAt": Timestamp(date: user.lastUpdatedAt),
                "gold": user.gold,
                "diamond": user.diamond,
                "chosenCharacterUUID": user.chosenCharacterUUID
            ]

            try await db.collection(collectionName)
                .document(user.id)
                .setData(data, merge: true)

            self.user = user
            print("✅ 사용자 저장 성공: \(user.userName)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ 사용자 저장 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 사용자 정보 불러오기
    func fetchUser(userId: String) async throws {
        print("[조회시작] 사용자 정보 조회 시작 - userId: \(userId)")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let doc = try await db.collection(collectionName)
                .document(userId)
                .getDocument()

            guard let data = doc.data() else {
                print("❌ 문서 없음")
                await MainActor.run {
                    self.user = nil
                    self.isLoading = false
                }
                return
            }

            guard
                let userEmail = data["userEmail"] as? String,
                let userName = data["userName"] as? String,
                let registeredAt = (data["registeredAt"] as? Timestamp)?.dateValue(),
                let lastUpdatedAt = (data["lastUpdatedAt"] as? Timestamp)?.dateValue(),
                let gold = data["gold"] as? Int,
                let diamond = data["diamond"] as? Int,
                let chosenCharacterUUID = data["chosenCharacterUUID"] as? String
            else {
                throw NSError(domain: "ParsingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 파싱 실패"])
            }

            let fetchedUser = GRUser(
                id: doc.documentID,
                userEmail: userEmail,
                userName: userName,
                registeredAt: registeredAt,
                lastUpdatedAt: lastUpdatedAt,
                gold: gold,
                diamond: diamond,
                chosenCharacterUUID: chosenCharacterUUID
            )

            await MainActor.run {
                self.user = fetchedUser
                print("✅ 사용자 로드 성공: \(userName)")
            }

        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            print("❌ 사용자 조회 실패: \(error.localizedDescription)")
            throw error
        }

        await MainActor.run {
            isLoading = false
        }
    }

    // MARK: - 사용자 재화 업데이트
    func updateCurrency(userId: String, gold: Int? = nil, diamond: Int? = nil) {
        var updates: [String: Any] = [:]
        if let gold = gold { updates["gold"] = gold }
        if let diamond = diamond { updates["diamond"] = diamond }
        updates["lastUpdatedAt"] = Timestamp(date: Date())

        db.collection(collectionName)
            .document(userId)
            .updateData(updates) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        print("❌ 재화 업데이트 실패: \(error.localizedDescription)")
                    } else {
                        if var currentUser = self.user {
                            if let gold = gold { currentUser.gold = gold }
                            if let diamond = diamond { currentUser.diamond = diamond }
                            currentUser.lastUpdatedAt = Date()
                            self.user = currentUser
                        }
                        print("✅ 재화 업데이트 성공")
                    }
                }
            }
    }
}
