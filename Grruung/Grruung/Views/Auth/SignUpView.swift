//
//  SignUpView.swift
//  Grruung
//
//  Created by NoelMacMini on 4/30/25.
//

import SwiftUI

struct SignUpView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService
    
    @State private var email = ""          // 이메일
    @State private var userName = ""        // 사용자이름
    @State private var password = ""       // 비밀번호
    @State private var passwordCheck = ""  // 비밀번호 확인
    
    // 로딩 및 에러 상태
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    
    // 포커스 열거형 정의
    enum SignUpField {
        case email, userName, password, passwordCheck
    }

    // 포커스 상태 추가
    @FocusState private var focusedField: SignUpField?
    
    // 입력 유효성 검사 로직 추가
    private var isValidEmail: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    private var isValidPassword: Bool {
        password.count >= 6  // 최소 6자 이상
    }
    
    private var isValidUserName: Bool {
        userName.count >= 2  // 최소 2자 이상
    }
    
    
    // 전체 입력 유효성 검사
    private var isValidInput: Bool {
        !email.isEmpty &&
        !userName.isEmpty &&
        !password.isEmpty &&
        isValidEmail &&
        isValidPassword &&
        isValidUserName &&
        password == passwordCheck
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack(spacing: 20) {
                        // MARK: - 이메일 주소
                        Text("이메일 주소")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        // 이메일 입력 필드
                        VStack {
                            TextField("", text: $email, prompt: Text("ex) grruung＠test.com").foregroundStyle(.gray.opacity(0.3)))
                                .padding(.bottom, 8)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundStyle(
                                            focusedField == .email
                                                ? (email.isEmpty ? GRColor.mainColor4_1 : (isValidEmail ? GRColor.mainColor4_1 : Color.red))
                                                : Color.gray.opacity(0.3)
                                        ), alignment: .bottom
                                )
                                .padding(.bottom, 8)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)  // 키보드에 "다음" 버튼
                                .onSubmit {
                                    focusedField = .userName
                                }
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .disabled(isLoading)
                            
                            if !isValidEmail && !email.isEmpty {
                                Text("유효한 이메일 주소를 입력해주세요")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            } else {
                                // 빈 텍스트로 높이 유지
                                Text(" ")
                                    .font(.caption)
                            }
                        }
                        .frame(height: 60)
                        
                        // MARK: - 사용자 이름
                        Text("사용자 이름")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        VStack {
                            // 유저네임 입력 필드
                            TextField("", text: $userName)
                                .padding(.bottom, 8)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundStyle(
                                            focusedField == .userName
                                                ? (userName.isEmpty ? GRColor.mainColor4_1 : (isValidUserName ? GRColor.mainColor4_1 : Color.red))
                                                : Color.gray.opacity(0.3)
                                        ), alignment: .bottom
                                )
                                .padding(.bottom, 8)
                                .focused($focusedField, equals: .userName)
                                .submitLabel(.next)  // 키보드에 "다음" 버튼
                                .onSubmit {
                                    focusedField = .password
                                }
                                .textInputAutocapitalization(.never)
                                .disabled(isLoading)
                            if !isValidUserName && !userName.isEmpty {
                                Text("이름은 최소 2자 이상이어야 합니다")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            } else {
                                // 빈 텍스트로 높이 유지
                                Text(" ")
                                    .font(.caption)
                            }
                        }
                        .frame(height: 60)
                        
                        // MARK: - 비밀번호
                        Text("비밀번호")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        VStack {
                            // 비밀번호 입력 필드
                            SecureField("", text: $password)
                                .textContentType(.newPassword)
                                .padding(.bottom, 8)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundStyle(
                                            focusedField == .password
                                                ? (password.isEmpty ? GRColor.mainColor4_1 : (isValidPassword ? GRColor.mainColor4_1 : Color.red))
                                                : Color.gray.opacity(0.3)
                                        ), alignment: .bottom
                                )
                                .padding(.bottom, 8)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.next)  // 키보드에 "다음" 버튼
                                .onSubmit {
                                    focusedField = .passwordCheck
                                }
                                .disabled(isLoading)
                            if !isValidPassword && !password.isEmpty {
                                Text("비밀번호는 최소 6자 이상이어야 합니다")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            } else {
                                // 빈 텍스트로 높이 유지
                                Text(" ")
                                    .font(.caption)
                            }
                        }
                        .frame(height: 60)
                        
                        // MARK: - 비밀번호 확인
                        Text("비밀번호 확인")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack {
                            // 비밀번호 확인 입력 필드
                            SecureField("", text: $passwordCheck)
                                .textContentType(.newPassword)
                                .padding(.bottom, 8)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundStyle(
                                            focusedField == .passwordCheck
                                                ? (passwordCheck.isEmpty ? GRColor.mainColor4_1 : (password == passwordCheck ? GRColor.mainColor4_1 : Color.red))
                                                : Color.gray.opacity(0.3)
                                        ), alignment: .bottom
                                )
                                .padding(.bottom, 8)
                                .focused($focusedField, equals: .passwordCheck)
                                .submitLabel(.done)  
                                .disabled(isLoading)
                            if password != passwordCheck && !passwordCheck.isEmpty {
                                Text("비밀번호가 일치하지 않습니다")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            } else {
                                // 빈 텍스트로 높이 유지
                                Text(" ")
                                    .font(.caption)
                            }
                        }
                        .frame(height: 60)
                        
                        // 회원가입 버튼
                        Button(action: {
                            Task {
                                await signUp()
                            }
                        }) {
                            Text("회원가입")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .scrollContentBackground(.hidden) // 기본 배경을 숨기고
                                .background(
                                    Group {
                                        if isValidInput {
                                            LinearGradient(
                                                colors: [GRColor.buttonColor_1, GRColor.buttonColor_2],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        } else {
                                            Color.gray
                                        }
                                    }
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(!isValidInput || isLoading)
                    }
                    .padding()
                    
                    // 로딩 오버레이
                    if isLoading {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                }
                .navigationTitle("회원가입")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("취소") {
                            dismiss()
                        }
                        .disabled(isLoading)
                    }
                    
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("완료") {
                            hideKeyboard()
                        }
                    }
                }
                .alert("회원가입 오류", isPresented: $showError) {
                    Button("확인", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Methods
    private func signUp() async {
        isLoading = true
        do {
            try await authService.signUp(userEmail: email, userName: userName, password: password)
            print("회원가입 성공: \(email)")
            // dismiss() // 성공 시 이전 화면(로그인 화면)으로 돌아감 (취소하고 바로 로그인으로 바꿈)
            try await authService.signIn(userEmail: email, password: password)
            print("로그인 성공: \(email)")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    SignUpView()
}
