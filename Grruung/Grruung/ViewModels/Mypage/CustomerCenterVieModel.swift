//
//  CustomerCenterViewModel.swift
//  Grruung
//
//  Created by 천수빈 on 6/11/25.
//

import Foundation

// MARK: - FAQ 모델

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - FAQ 데이터 서비스

class FAQDataService {
    static let shared = FAQDataService()
    
    let faqItems: [FAQItem] = [
        .init(question: "앱 알림이 오지 않아요", answer: "설정 > 알림에서 알림 허용 여부를 확인해주세요. iOS 설정에서도 해당 앱의 알림 권한이 활성화되어 있는지 확인해보세요."),
        .init(question: "캐릭터가 사라졌어요", answer: "앱을 다시 실행하거나 로그인을 확인해주세요. 문제가 지속되면 앱을 완전히 종료한 후 재실행해보세요."),
        .init(question: "구매 내역은 어디서 확인하나요?", answer: "마이페이지 > 결제내역에서 확인하실 수 있어요. 구매 후 영수증은 이메일로도 발송됩니다."),
        .init(question: "환불은 어떻게 하나요?", answer: "환불관련된 문의는 문의하기에 남겨주시기 바랍니다."),
        .init(question: "앱을 탈퇴하고 싶어요", answer: "설정 > 계정 > 회원 탈퇴에서 진행하실 수 있습니다. 탈퇴 시 모든 데이터가 삭제되니 신중히 결정해주세요.")
    ]
}

// MARK: - 문의내역 모델

struct Inquiry: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let date: String
    let status: String
}

// MARK: - 문의 관리자

class InquiryManager: ObservableObject {
    static let shared = InquiryManager()
    
    @Published var inquiries: [Inquiry] = []
    
    private init() {}
    
    func addInquiry(title: String, content: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let currentDate = dateFormatter.string(from: Date())
        
        let newInquiry = Inquiry(
            title: title,
            content: content,
            date: currentDate,
            status: "미답변"
        )
        
        inquiries.insert(newInquiry, at: 0)
    }
}
