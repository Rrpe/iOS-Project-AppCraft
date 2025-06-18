//
//  NoticeView.swift
//  Grruung
//
//  Created by 천수빈 on 6/9/25.
//

import SwiftUI

// MARK: - 모델 정의

struct NoticeItem: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let content: String
}

// MARK: - 공지사항 뷰

struct NoticeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedNoticeID: UUID? = nil
    
    let notices: [NoticeItem] = [
        .init(title: "🙋‍♀️ 더 나은 구르릉을 위한 소중한 의견을 들려주세요", date: "2025.06.08", content: "설문조사 참여 시 보상이 주어집니다."),
        .init(title: "[중요] 앱 알림 수신을 위해 최신 버전으로 업데이트 해주세요", date: "2025.05.21", content: "알림 기능이 제대로 작동되지 않을 수 있습니다."),
        .init(title: "[중요] 앱 신규 기능 추가 안내", date: "2025.04.21", content: "4월 22일 오전 2시 ~ 4시까지 서버 점검이 예정되어 있습니다."),
        .init(title: "[공지] 영업양도에 따른 개인정보처리방침, 개인정보수집 및 이용, 서비스 이용약관 개정 안내", date: "2025.02.04", content: "자세한 내용은 홈페이지에서 확인해주세요."),
        .init(title: "[공지] 영업양도에 따른 이용약관 개정 안내 (KO/EN)", date: "2025.01.03", content: "변경된 약관은 2025년 2월 1일부터 적용됩니다."),
        .init(title: "[공지] 앱 업데이트 안내", date: "2025.01.02", content: "버그 수정 및 성능 개선을 위해 업데이트를 할 예정입니다."),
        .init(title: "[공지] 개인정보 처리방침, 개인정보 수집 및 이용 개정 사전 안내", date: "2024.12.18", content: "사전 안내 드리며, 자세한 변경사항은 링크를 확인해주세요.")
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(notices) { notice in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(notice.title)
                                .font(.body)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: expandedNoticeID == notice.id ? "chevron.up" : "chevron.down")
                                .foregroundStyle(.gray)
                        }
                        
                        Text(notice.date)
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        if expandedNoticeID == notice.id {
                            Text(notice.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation {
                            expandedNoticeID = (expandedNoticeID == notice.id) ? nil : notice.id
                        }
                    }
                    
                    Divider()
                        .padding(.leading)
                }
            }
        }
//        .navigationTitle("공지사항")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(GRColor.subColorOne) // 갈색으로 변경
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("공지사항")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
    }
}

//MARK: - Preview
#Preview {
    NoticeView()
}
