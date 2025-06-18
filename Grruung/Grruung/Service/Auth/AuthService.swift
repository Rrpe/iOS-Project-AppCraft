//
//  Untitled.swift
//  Grruung
//
//  Created by NoelMacMini on 4/30/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthService: ObservableObject {
    // 인증 상태를 나타내는 열거형
    enum AuthenticationState {
        case unauthenticated   // 로그인되지 않음
        case authenticated     // 로그인됨
    }
    
    @Published var user: User?
    @Published var currentUserUID: String = ""
    @Published var authenticationState: AuthenticationState = .unauthenticated
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // 초기화 시 현재 로그인된 사용자가 있는지 확인
    init() {
        self.user = auth.currentUser
        self.authenticationState = auth.currentUser != nil ? .authenticated : .unauthenticated
        self.currentUserUID = auth.currentUser?.uid ?? ""
    }
    
    // 현재 인증 상태 확인 메서드 (앱 시작 시 또는 필요할 때 호출)
    func checkAuthState() {
        self.user = auth.currentUser
        self.authenticationState = auth.currentUser != nil ? .authenticated : .unauthenticated
    }
    
    // 회원가입
    func signUp(userEmail: String, userName: String, password: String) async throws {
        do {
            // 1. Firebase Auth로 사용자 생성
            let authResult = try await auth.createUser(withEmail: userEmail, password: password)
            
            // 2. GRUser 모델 생성
            let user = GRUser(
                id: authResult.user.uid,
                userEmail: userEmail,
                userName: userName
            )
            
            // 3. Firestore에 추가 사용자 정보 저장
            try await db.collection("users").document(authResult.user.uid).setData(user.toFirestoreData())
            
            // 4. 현재 사용자 설정
            self.user = authResult.user
            
        } catch {
            throw error
        }
    }
    
    // 로그인
    func signIn(userEmail: String, password: String) async throws {
        // 1. 이메일로 Firebase Authentication에 로그인 요청
        let authResult = try await auth.signIn(withEmail: userEmail, password: password)
        self.user = authResult.user
        self.currentUserUID = authResult.user.uid // useruid 저장
        print("[L] 로그인 성공")
        
        // 2. 인증 상태 업데이트
        self.authenticationState = .authenticated
    }
    
    // 로그아웃
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
            self.currentUserUID = ""
            self.authenticationState = .unauthenticated
            print("[L] 로그아웃 성공")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
