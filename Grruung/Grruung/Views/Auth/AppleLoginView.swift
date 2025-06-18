//
//  AppleLoginView.swift
//  Grruung
//
//  Created by mwpark on 6/9/25.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

struct AppleLoginView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.colorScheme) var colorScheme
    
    // Apple 로그인 시 nonce 값을 저장 (보안 목적)
    @State private var currentNonce: String?

    var body: some View {
        // Apple 로그인 버튼 생성
        SignInWithAppleButton(
            .signIn,
            onRequest: configureRequest,   // 로그인 요청 구성
            onCompletion: handleAuthorization // 로그인 완료 후 처리
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(maxWidth: .infinity, maxHeight: 50)
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .id(colorScheme)
    }

    // Apple 로그인 요청을 구성하는 함수
    func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()  // 무작위 nonce 생성
        currentNonce = nonce             // 뷰 상태에 저장 (로그인 완료 시 비교를 위해)
        
        request.requestedScopes = [.fullName, .email] // 사용자 이름, 이메일 요청
        request.nonce = sha256(nonce)                 // nonce를 SHA256 해시로 암호화 후 요청에 포함
    }

    // Apple 로그인 응답 처리 함수
    func handleAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            // 로그인 성공 시, 자격 증명 객체와 nonce 등 확인
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityTokenString = String(data: identityTokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                print("🔴 토큰 또는 nonce 가져오기 실패")
                return
            }

            // Apple로부터 받은 토큰과 nonce로 Firebase 자격 증명 객체 생성
            let firebaseCredential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: identityTokenString,
                rawNonce: nonce,
                accessToken: nil // Apple은 accessToken을 제공하지 않으므로 nil
            )

            // Firebase에 로그인 요청
            Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
                if let error = error {
                    print("🔴 Firebase 로그인 실패: \(error.localizedDescription)")
                    return
                }

                guard let firebaseUser = authResult?.user else {
                    print("🔴 Firebase 사용자 없음")
                    return
                }

                print("🟢 Firebase 로그인 성공: \(firebaseUser.uid)")

                let userRef = Firestore.firestore().collection("users").document(firebaseUser.uid)

                userRef.getDocument { docSnapshot, error in
                    if let doc = docSnapshot, !doc.exists {
                        // 이름 구성 (처음 로그인만 해당)
                        let givenName = credential.fullName?.givenName ?? ""
                        let familyName = credential.fullName?.familyName ?? ""
                        let fullName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)

                        // GRUser 생성
                        let now = Date()
                        let newUser = GRUser(
                            id: firebaseUser.uid,
                            userEmail: firebaseUser.email ?? "",
                            userName: fullName.isEmpty ? "AppleUser" : fullName,
                        )

                        // Firestore 저장
                        userRef.setData(newUser.toFirestoreData()) { error in
                            if let error = error {
                                print("🔴 Firestore 저장 실패: \(error.localizedDescription)")
                            } else {
                                print("🟢 Firestore에 사용자 저장 성공")
                            }
                        }
                    }

                    // AuthService 상태 업데이트
                    DispatchQueue.main.async {
                        authService.user = firebaseUser
                        authService.currentUserUID = firebaseUser.uid
                        authService.authenticationState = .authenticated
                    }
                }
            }

        case .failure(let error):
            // Apple 로그인 실패 시
            print("🔴 Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AppleLoginView()
}
