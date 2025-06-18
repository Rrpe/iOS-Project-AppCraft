//
//  LoginView.swift
//  Grruung
//
//  Created by NoelMacMini on 4/30/25.
//

import SwiftUI

struct LoginView: View {
    // MARK: - Properties
    @State private var email = ""    // 이메일 입력값
    @State private var password = "" // 비밀번호 입력값
    @EnvironmentObject private var authService: AuthService
    
    // 로딩 상태와 에러 처리를 위한 상태 추가
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var isSecure: Bool = true
    
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    
    // 입력 유효성 검사
    private var isValidPassword: Bool {
        password.count >= 6 // 최소 6자 이상
    }
    
    // 전체 입력 유효성 검사
    private var isValidInput: Bool {
        isValidPassword
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    // 로고나 앱 이름
                    Text("구르릉")
                        .padding(.bottom, 16)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("이메일 주소")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // 이메일 입력 필드
                    TextField("", text: $email, prompt: Text("ex) grruung＠test.com").foregroundStyle(.gray.opacity(0.3)))
                        .padding(.bottom, 8)
                        .focused($emailFieldIsFocused)
                        .submitLabel(.next)  // 키보드에 "다음" 버튼
                        .onSubmit {
                            emailFieldIsFocused = false
                            passwordFieldIsFocused = true
                        }
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundStyle(emailFieldIsFocused ? GRColor.mainColor4_2 : .gray.opacity(0.3))
                                .animation(.easeInOut(duration: 0.3), value: emailFieldIsFocused),
                            alignment: .bottom
                        )
                        .padding(.bottom, 8)
                        .textInputAutocapitalization(.never) // 자동 대문자 비활성화
                        .keyboardType(.emailAddress)              // 이메일 키보드
                        .disabled(isLoading)
                    
                    Text("비밀번호")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        ZStack(alignment: .trailing) {
                            // 비밀번호 입력 필드
                            Group {
                                if isSecure {
                                    SecureField("", text: $password)
                                } else {
                                    TextField("", text: $password)
                                }
                            }
                            .padding(.trailing, 40)
                            .padding(.bottom, 8)
                            .frame(height: 30)
                            .submitLabel(.done)
                            .disabled(isLoading)
                            .focused($passwordFieldIsFocused)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundStyle(passwordFieldIsFocused ? GRColor.mainColor4_2 : .gray.opacity(0.3))
                                    .animation(.easeInOut(duration: 0.6), value: passwordFieldIsFocused),
                                alignment: .bottom
                            )
                            
                            // 눈 아이콘 버튼
                            Button(action: {
                                isSecure.toggle()
                                
                                // 포커스 재설정 지연
                                DispatchQueue.main.async {
                                    passwordFieldIsFocused = true
                                }
                            }) {
                                Image(systemName: isSecure ? "eye.slash" : "eye")
                                    .foregroundStyle(.gray)
                            }
                            .padding(.trailing, 8)
                            
                            
                        }
                        if !isValidPassword && !password.isEmpty {
                            Text("비밀번호는 최소 6자 이상이어야 합니다")
                                .padding(.top, 4)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                    .frame(height: 60)
                    
                    // 로그인 버튼
                    Button(action: {
                        Task {
                            await login()
                        }
                    }) {
                        Text("로그인")
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
                    
                    AppleLoginView()
                    
                    // 회원가입 링크
                    NavigationLink(destination: {
                        SignUpView()
                            .navigationBarBackButtonHidden(true) // ← 뒤로가기 버튼 숨기기
                    }, label: {
                        Text("계정이 없으신가요? 회원가입")
                            .foregroundStyle(GRColor.mainColor4_2)
                            .bold()
                    })
                    .padding(.top)
                    .disabled(isLoading)
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
            .alert("로그인 오류", isPresented: $showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Methods
    private func login() async {
        isLoading = true
        do {
            try await authService.signIn(userEmail: email, password: password)
            // 로그인 성공 시 처리 (예. 메인 화면으로 이동)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}


// MARK: - Preview
#Preview {
    LoginView()
}
