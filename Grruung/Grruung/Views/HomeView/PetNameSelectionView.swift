//
//  PetNameSelectionView.swift
//  Grruung
//
//  Created by KimJunsoo on 6/2/25.
//

import SwiftUI

struct PetNameSelectionView: View {
    @State private var petName = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State private var navigateToHome = false
    
    // 개발 단계에서는 쿼카로 고정하고, 나중에 랜덤으로 설정할 수 있도록 준비
    // 추후 랜덤 구현을 위한 주석 포함
    @State private var selectedSpecies: PetSpecies = .quokka
    // @State private var selectedSpecies: PetSpecies = Bool.random() ? .quokka : .CatLion
    
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) var dismiss
    
    var onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 - 가장 먼저 배치
                LinearGradient(
                    colors: [Color(hex: "FEF9EA"), Color(hex: "FDE0CA")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // 헤더
                    Text("새로운 친구의 이름을 지어주세요")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                        .multilineTextAlignment(.center)

                    // 펫 이미지 (운석 단계 이미지 표시)
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 220, height: 220)
                        
                        Image("egg") // 운석 이미지 (Assets에 추가 필요)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .padding()
                    }
                    .padding(.vertical, 20)
                    
                    // 펫 종류 안내 (실제로는 아직 운석 상태)
                    Text("우주에서 온 신비한 운석")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    
                    // 이름 입력 필드
                    VStack(alignment: .leading, spacing: 8) {
                        Text("이름")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("이름을 입력하세요", text: $petName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .disabled(isLoading)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    // 생성 버튼
                    Button(action: {
                        createPet()
                    }) {
                        Text("친구 만들기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(petName.isEmpty ? Color.gray : Color.orange)
                            .cornerRadius(12)
                    }
                    .disabled(petName.isEmpty || isLoading)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    
                    if isLoading {
                        ProgressView("캐릭터를 생성하고 있어요...")
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    // 안내 메시지
                    Text("이 친구는 처음에는 운석 상태로 시작해요.\n사랑과 관심으로 키워주세요!")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                }
                
                .padding()
                .alert(isPresented: $showError) {
                    Alert(
                        title: Text("오류"),
                        message: Text(errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                        dismissButton: .default(Text("확인"))
                    )
                }
                // 홈 화면으로 이동하는 네비게이션 링크
                .navigationDestination(isPresented: $navigateToHome) {
                    MainView()
                        .environmentObject(authService)
                        .navigationBarBackButtonHidden(true)
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func createPet() {
        guard !petName.isEmpty else { return }
        isLoading = true
        
        // 캐릭터 상태 초기화 (운석 단계부터 시작)
        let status = GRCharacterStatus(
            level: 0,
            exp: 0,
            expToNextLevel: 50,
            phase: .egg, // 운석 단계
            satiety: 100,
            stamina: 100,
            activity: 100,
            affection: 0,
            affectionCycle: 0,
            healthy: 50,
            clean: 50,
            address: "userHome" // 홈 화면에 표시될 캐릭터로 설정
        )
        
        // 캐릭터 생성 - 이미지 이름을 egg_normal_1로 변경
        let newCharacter = GRCharacter(
            species: selectedSpecies,
            name: petName,
            imageName: "egg", // 운석 이미지의 정확한 이름으로 수정
            birthDate: Date(),
            createdAt: Date(),
            status: status
        )
        
        // Firebase에 저장
        FirebaseService.shared.createAndSetMainCharacter(character: newCharacter) { characterID, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "캐릭터 생성 실패: \(error.localizedDescription)"
                    showError = true
                    print("❌ 캐릭터 생성 실패: \(error.localizedDescription)")
                } else if let characterID = characterID {
                    print("✅ 캐릭터 생성 완료: \(characterID)")
                    
                    // 완료 후 홈 화면으로 이동
                    navigateToHome = true
                    
                    // 또는 onComplete 콜백 호출 (부모 뷰에 의해 제공된 콜백)
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    PetNameSelectionView(onComplete: {})
        .environmentObject(AuthService())
}
