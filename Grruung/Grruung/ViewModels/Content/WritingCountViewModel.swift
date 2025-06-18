import Foundation
import FirebaseFirestore

@MainActor
class WritingCountViewModel: ObservableObject {
    @Published var userWritingCount: WritingCount?
    private var db = Firestore.firestore()
    
    init() {
    }
    
    // authService를 받아서 초기화하는 메서드
    func initialize(with authService: AuthService) {
        guard let userID = authService.user?.uid else { return }
        self.userWritingCount = WritingCount(id: userID)
        loadWritingCount(userID: userID)
    }
    
    func loadWritingCount(userID: String) {
        db.collection("WritingCounts").document(userID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let data = snapshot?.data() {
                let writingCount = WritingCount(
                    id: userID,
                    dailyRewardCount: data["dailyRewardCount"] as? Int ?? 0,
                    lastResetDate: (data["lastResetDate"] as? Timestamp)?.dateValue() ?? Date()
                )
                
                Task { @MainActor in
                    self.userWritingCount = writingCount
                    self.userWritingCount?.checkAndResetDaily()
                    self.updateWritingCountInFirestore()
                }
            } else {
                Task { @MainActor in
                    self.updateWritingCountInFirestore()
                }
            }
        }
    }
    
    // 글쓰기 시도 후 결과 반환 (성공 여부, 경험치/골드 획득 여부)
    func tryToWrite() -> (success: Bool, expReward: Bool) {
        guard var writingCount = userWritingCount else { return (false, false) }
        let result = writingCount.tryWrite()
        self.userWritingCount = writingCount
        updateWritingCountInFirestore()
        return result
    }
    
    private func updateWritingCountInFirestore() {
        guard let writingCount = userWritingCount else { return }
        db.collection("WritingCounts").document(writingCount.id).setData(
            writingCount.toFirestoreData(),
            merge: true
        ) { error in
            if let error = error {
                print("글쓰기 카운트 업데이트 실패: \(error)")
            }
        }
    }
    
    // 남은 보상 횟수 반환
    func remainingRewards() -> Int {
        return userWritingCount?.remainingRewards ?? 0
    }
}
