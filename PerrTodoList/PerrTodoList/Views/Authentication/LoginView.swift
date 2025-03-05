//
//  LoginView.swift
//  RrpeTodoList
//
//  Created by KimJunsoo on 3/4/25.
//

import SwiftUI

struct LoginView: View {
    @State var email: String
    @State var password: String
    @State private var isPasswordVisible = false
    
    var body: some View {
            NavigationView {
            VStack(spacing: 0) {
                
                Text("로그인 페이지")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color("TextColor"))
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                
                // 이메일 & 비밀번호 텍스트필드
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .modifier(CustomSignTextFieldModifier())
                    
                    HStack(spacing: 0) {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(Color("PlaceholderColor"))
                                .padding(.trailing)
                        }
                    }
                    .modifier(CustomSignTextFieldModifier())
                    
                    HStack {
                        Button(action: {
                            // 비밀번호 찾기 이벤트
                        }) {
                            Text("비밀번호를 잊으셨나요?")
                                .font(.system(size: btnFontSize))
                                .foregroundStyle(Color("PlaceholderColor"))
                                .underline()
                        }
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                
                // 로그인 & 회원가입 버튼
                VStack(spacing: 12) {
                    Button(action: {
                        // 로그인 이벤트
                    }) {
                        Text("로그인")
                            .font(.system(size: btnFontSize, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity)
                            .frame(height: btnHeight)
                            .background(Color("PrimaryButtonColor"))
                            .cornerRadius(btnCornerRadius)
                    }
                    Button(action: {
                        // 회원가입 이벤트
                    }) {
                        Text("회원가입")
                            .font(.system(size: btnFontSize, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity)
                            .frame(height: btnHeight)
                            .background(Color("SecondaryButtonColor"))
                            .cornerRadius(btnCornerRadius)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                // 소셜 로그인 버튼
                VStack(spacing: 12) {
                    SocialLoginButton(title: "네이버")
                    SocialLoginButton(title: "카카오")
                    SocialLoginButton(title: "구글")
                    SocialLoginButton(title: "애플")
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                Spacer()
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("로그인 페이지 시스템")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color("TextColor"))
                }
                ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            // 뒤로가기 이벤트
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(Color("TextColor"))
                        }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: {
                        // 버튼 누르면 키보드 내려가는 이벤트 처리
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundStyle(Color("PlaceholderColor"))
                    }
                }
            }
        }
    } // body
}

struct SocialLoginButton: View {
    let title: String
    
    var body: some View {
        Button(action: {
            // 각 소셜 로그인 버튼 이벤트
        }) {
            Text(title)
                .font(.system(size: btnFontSize, weight: .bold))
                .foregroundColor(Color("TextColor"))
                .frame(maxWidth: .infinity)
                .frame(height: btnHeight)
                .background(Color("SecondaryButtonColor"))
                .cornerRadius(btnCornerRadius)
        }
    }
}

#Preview {
    LoginView(email: "", password: "")
}
