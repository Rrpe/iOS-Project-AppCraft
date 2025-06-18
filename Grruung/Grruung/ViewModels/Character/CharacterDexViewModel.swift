//
//  CharacterDexViewModel.swift
//  Grruung
//
//  Created by mwpark on 5/31/25.
//
// 동산 뷰 관련 설정 데이터 뷰 모델입니다.
import Foundation
import FirebaseFirestore

class CharacterDexViewModel: ObservableObject {
    @Published var unlockCount: Int = 2
    @Published var unlockTicketCount: Int = 0
    @Published var selectedLockedIndex: Int = -1
    @Published var isLoading = false
    @Published var noData: Bool = false
    private let db = Firestore.firestore()
    private let collectionName = "charDex"
    
    // MARK: - 앱 실행시 초기 메서드
    func initialize(userId: String) async {
        do {
            let doc = try await db.collection(collectionName).document(userId).getDocument()
            if doc.exists {
                try await fetchCharDex(userId: userId)
            } else {
                await saveCharDex(userId: userId)
            }
        } catch {
            print("❌ 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 동산관련 초기 데이터 저장
    func saveCharDex(userId: String) async {
        do {
            let data: [String: Any] = [
                "unlockCount": unlockCount,
                "unlockTicketCount": unlockTicketCount,
                "selectedLockedIndex": selectedLockedIndex
            ]
            
            try await db.collection(collectionName)
                .document(userId)
                .setData(data, merge: true)
            
            print("✅ 동산뷰 초기 데이터 저장 성공: \(userId)")
        } catch {
            print("❌ 동산뷰 초기 데이터 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 동산 데이터 가져오기
    func fetchCharDex(userId: String) async throws {
        print("[조회시작] 동산 정보 조회 시작 - userId: \(userId)")
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let doc = try await db.collection(collectionName)
                .document(userId)
                .getDocument()
            
            guard let data = doc.data() else {
                print("❌ 문서 없음")
                await MainActor.run {
                    self.isLoading = false
                    self.noData = true
                }
                return
            }
            
            guard
                let fetchUnlockCount = data["unlockCount"] as? Int,
                let fetchUnlockTicketCount = data["unlockTicketCount"] as? Int,
                let fetchSelectedLockedIndex = data["selectedLockedIndex"] as? Int
            else {
                throw NSError(domain: "ParsingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "❌ 동산 데이터 파싱 실패"])
            }
            
            await MainActor.run {
                self.unlockCount = fetchUnlockCount
                self.unlockTicketCount = fetchUnlockTicketCount
                self.selectedLockedIndex = fetchSelectedLockedIndex
                print("✅ 동산 데이터 로드 성공: \(userId)")
            }
            
        } catch {
            print("❌ 사용자 조회 실패: \(error.localizedDescription)")
            throw error
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    // MARK: - 동산 데이터 업데이트
    func updateCharDex(
        userId: String,
        unlockCount: Int,
        unlockTicketCount: Int,
        selectedLockedIndex: Int
    ) {
        let data: [String: Any] = [
            "unlockCount": unlockCount,
            "unlockTicketCount": unlockTicketCount,
            "selectedLockedIndex": selectedLockedIndex
        ]
        
        db.collection(collectionName)
            .document(userId)
            .setData(data, merge: true) { error in
                if let error = error {
                    print("❌ 동산 데이터 업데이트 실패: \(error.localizedDescription)")
                } else {
                    print("✅ 동산 데이터 업데이트 성공")
                }
            }
    }
}
