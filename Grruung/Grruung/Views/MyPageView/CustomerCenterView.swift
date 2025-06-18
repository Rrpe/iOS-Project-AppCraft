//
//  CustomerCenterView.swift
//  Grruung
//
import SwiftUI

// MARK: - FAQ 뷰

struct CustomerCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedFAQs: Set<UUID> = []
    @State private var searchText = ""
    
    private var filteredFAQs: [FAQItem] {
        if searchText.isEmpty {
            return FAQDataService.shared.faqItems
        } else {
            return FAQDataService.shared.faqItems.filter {
                $0.question.localizedCaseInsensitiveContains(searchText) ||
                $0.answer.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 헤더
                    VStack(alignment: .leading, spacing: 8) {
                        Text("자주 묻는 질문")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("궁금한 내용을 빠르게 찾아보세요")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.bottom, 8)
                    
                    // 검색 바
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.black)
                        
                        TextField("질문을 입력해주세요.", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                    .cornerRadius(12)
                    
                    // FAQ 목록 또는 검색 결과 없음
                    if filteredFAQs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundStyle(.gray)
                            
                            Text("검색 결과가 없습니다")
                                .font(.headline)
                            
                            Text("다른 키워드로 검색해보세요")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        .padding(.vertical, 40)
                        .frame(maxWidth: .infinity)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredFAQs) { faq in
                                FAQItemView(
                                    faq: faq,
                                    isExpanded: expandedFAQs.contains(faq.id),
                                    onTap: {
                                        withAnimation(
                                            .easeInOut(duration: 0.3)
                                        ) {
                                            if expandedFAQs.contains(faq.id) {
                                                expandedFAQs.remove(faq.id)
                                            } else {
                                                expandedFAQs.insert(faq.id)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                    
                    // 도움 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("도움이 필요하신가요?")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            NavigationLink(destination: InquiryView()) {
                                HStack(spacing: 12) {
                                    Image(systemName: "square.and.pencil")
                                        .foregroundStyle(.orange)
                                        .font(.title2)
                                    
                                    Text("문의하기")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: InquiryHistoryView()) {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .foregroundStyle(.orange)
                                        .font(.title2)
                                    
                                    Text("문의내역")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(GRColor.subColorOne)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("고객센터")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - FAQ 개별 항목 뷰

struct FAQItemView: View {
    let faq: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(faq.question)
                        .font(.body)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(
                        systemName: isExpanded ? "chevron.up" : "chevron.down"
                    )
                    .foregroundStyle(.gray)
                    .font(.system(size: 14, weight: .medium))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            
            if isExpanded {
                Text(faq.answer)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - 문의하기 뷰

struct InquiryView: View {
    @State private var inquiryTitle = ""
    @State private var inquiryText = ""
    @State private var showingAlert = false
    @ObservedObject private var inquiryManager = InquiryManager.shared
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !inquiryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !inquiryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // 헤더
                VStack(alignment: .leading, spacing: 8) {
                    Text("문의사항을 작성해주세요")
                        .font(.headline)
                    
                    Text("궁금한 점이나 문제가 있으시면 아래에 자세히 적어주세요.")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                
                // 제목 입력
                VStack(alignment: .leading, spacing: 8) {
                    Text("제목")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("문의 제목을 입력해주세요", text: $inquiryTitle)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // 내용 입력
                VStack(alignment: .leading, spacing: 8) {
                    Text("내용")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $inquiryText)
                            .frame(minHeight: 150)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                        
                        if inquiryText.isEmpty {
                            Text(
                                "문의내용을 입력해주세요.\n\n예시:\n- 앱 사용 중 발생한 문제\n- 기능 관련 질문\n- 개선사항 제안"
                            )
                            .foregroundStyle(.gray)
                            .font(.subheadline)
                            .padding(16)
                            .allowsHitTesting(false)
                        }
                    }
                }
                
                Spacer()
                
                // 제출 버튼
                Button(action: {
                    inquiryManager.addInquiry(
                        title: inquiryTitle
                            .trimmingCharacters(in: .whitespacesAndNewlines),
                        content: inquiryText
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    
                    showingAlert = true
                    inquiryTitle = ""
                    inquiryText = ""
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("문의하기")
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isFormValid ? Color.orange : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .animation(.easeInOut(duration: 0.2), value: isFormValid)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
                    Text("문의하기")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("문의 접수 완료", isPresented: $showingAlert) {
                Button("확인", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("문의사항이 접수되었습니다.\n빠른 시일 내에 답변 드리겠습니다.")
            }
        }
    }
}

// MARK: - 문의내역 뷰

struct InquiryHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var inquiryManager = InquiryManager.shared
    @State private var expandedInquiries: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            if inquiryManager.inquiries.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)
                    
                    Text("문의 내역이 없습니다")
                        .font(.headline)
                    
                    Text("궁금한 점이 있으시면 문의하기를 이용해주세요")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(inquiryManager.inquiries) { inquiry in
                            InquiryItemView(
                                inquiry: inquiry,
                                isExpanded: expandedInquiries
                                    .contains(inquiry.id),
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if expandedInquiries
                                            .contains(inquiry.id) {
                                            expandedInquiries.remove(inquiry.id)
                                        } else {
                                            expandedInquiries.insert(inquiry.id)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
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
                Text("문의내역")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 문의내역 상세 뷰

struct InquiryItemView: View {
    let inquiry: Inquiry
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(inquiry.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.leading)
                            .lineLimit(isExpanded ? nil : 1)
                        
                        if isExpanded {
                            Text(inquiry.content)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .lineSpacing(4)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            
                            Text(inquiry.date)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(inquiry.status)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                inquiry.status == "답변 완료" ? Color.orange
                                    .opacity(0.2) : Color.gray
                                    .opacity(0.2)
                            )
                            .foregroundStyle(
                                inquiry.status == "답변 완료" ? .orange : .gray
                            )
                            .cornerRadius(6)
                        
                        Image(
                            systemName: isExpanded ? "chevron.up" : "chevron.down"
                        )
                        .foregroundStyle(.gray)
                        .font(.system(size: 14, weight: .medium))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .accessibilityLabel(
                "\(inquiry.title). 접수일: \(inquiry.date). 상태: \(inquiry.status)"
            )
            .accessibilityHint(isExpanded ? "내용 숨기기" : "내용 보기")
        }
    }
}

// MARK: - 프리뷰

#Preview {
    CustomerCenterView()
}
