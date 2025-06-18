//
//  TermsPolicyView.swift
//  Grruung
//
//  Created by 천수빈 on 6/13/25.
//

import SwiftUI

struct TermsPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 서비스 이용약관
                NavigationLink(destination: ServiceTermsView()) {
                    HStack {
                        Text("서비스 이용약관")
                            .font(.system(size: 16))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                // 구분선
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 0.5)
                
                // 개인정보 처리 방침
                NavigationLink(destination: PrivacyPolicyView()) {
                    HStack {
                        Text("개인정보 처리 방침")
                            .font(.system(size: 16))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
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
                Text("이용약관 및 운영정책")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
    }
}

// MARK: - 서비스 이용약관

struct ServiceTermsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("서비스 이용약관")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 16) {
                    termsSection(
                        title: "제1조 (목적)",
                        content: "본 약관은 회사가 제공하는 모든 서비스의 이용조건 및 절차, 회사와 회원간의 권리·의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다."
                    )
                    
                    termsSection(
                        title: "제2조 (정의)",
                        content: "1. \"서비스\"라 함은 회사가 제공하는 모든 서비스를 의미합니다.\n2. \"회원\"이라 함은 회사의 서비스에 접속하여 본 약관에 따라 회사와 이용계약을 체결하고 회사가 제공하는 서비스를 이용하는 고객을 말합니다."
                    )
                    
                    termsSection(
                        title: "제3조 (약관의 효력 및 변경)",
                        content: "1. 본 약관은 서비스를 이용하고자 하는 모든 회원에 대하여 그 효력을 발생합니다.\n2. 회사는 필요하다고 인정되는 경우 본 약관을 변경할 수 있으며, 변경된 약관은 서비스 내 공지사항을 통해 공지됩니다."
                    )
                    
                    termsSection(
                        title: "제4조 (서비스의 제공 및 변경)",
                        content: "1. 회사는 다음과 같은 업무를 수행합니다.\n2. 회사는 운영상, 기술상의 필요에 따라 제공하고 있는 전부 또는 일부 서비스를 변경할 수 있습니다."
                    )
                }
                
                Spacer(minLength: 50)
            }
            .padding()
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
                Text("서비스 이용약관")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - 개인정보 처리 방침

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("개인정보 처리 방침")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 16) {
                    privacySection(
                        title: "1. 개인정보의 처리목적",
                        content: "회사는 다음의 목적을 위하여 개인정보를 처리합니다.\n- 서비스 제공에 관한 계약 이행 및 서비스 제공에 따른 요금정산\n- 회원 관리\n- 마케팅 및 광고에의 활용"
                    )
                    
                    privacySection(
                        title: "2. 개인정보의 처리 및 보유기간",
                        content: "회사는 정보주체로부터 개인정보를 수집할 때 동의받은 개인정보 보유·이용기간 또는 법령에 따른 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다."
                    )
                    
                    privacySection(
                        title: "3. 개인정보의 제3자 제공",
                        content: "회사는 정보주체의 개인정보를 개인정보의 처리목적에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 개인정보 보호법 제17조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다."
                    )
                    
                    privacySection(
                        title: "4. 정보주체의 권리·의무 및 행사방법",
                        content: "정보주체는 회사에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다.\n- 개인정보 처리정지 요구\n- 개인정보 열람요구\n- 개인정보 정정·삭제요구\n- 개인정보 처리정지 요구"
                    )
                }
                
                Spacer(minLength: 50)
            }
            .padding()
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
                Text("개인정보 처리 방침")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - Preview
#Preview {
    TermsPolicyView()
}
