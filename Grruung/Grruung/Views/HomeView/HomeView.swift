//
//  HomeView.swift
//  Grruung
//
//  Created by NoelMacMini on 5/1/25.
//
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext // SwiftData 컨텍스트
    
    @State private var showInventory = false
    @State private var showPetGarden = false
    @State private var isShowingWriteStory = false
    @State private var isShowingChatPet = false
    @State private var isShowingSettings = false
    @State private var showEvolutionScreen = false // 진화 화면 표시 여부
    @State private var isShowingOnboarding = false
    @State private var showUpdateAlert = false // 업데이트 예정 알림창 표시 여부
    @State private var showSpecialEvent = false // 특수 이벤트 표시 여부
    @State private var showHealthCare = false // 건강관리 화면 표시 여부
    @State private var showUpdateScreen = false // 업데이트 화면 표시 상태
    @State private var showAllActionsSheet = false

    // MARK: - Body
    var body: some View {
            NavigationStack {
                ZStack {
                    // 배경 이미지 설정
                    GeometryReader { geometry in
                        Image("roomBasic1Big")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .edgesIgnoringSafeArea(.all)
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    // 원래 콘텐츠는 그대로 유지
                    if viewModel.isLoadingFromFirebase || !viewModel.isDataReady {
                        // 로딩 중 표시
                        LoadingView()
                    } else {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            // 레벨 프로그레스 바
                            levelProgressBar
                            
                            // 말풍선 섹션
                            speechBubbleSection
                            
                            // 메인 캐릭터 섹션
                            characterSection
                            
                            // 액션 버튼 그리드
                            actionButtonsGrid
                            
                            // 상태 바 섹션
                            statsSection
                            

                            Spacer()
                            
                            // 커스텀 탭바를 위한 여백
                            Color.clear
                                .frame(height: 40)
                        }
                        .padding()
                    }
                }
                .scrollContentBackground(.hidden) // 기본 배경 숨기기
                .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.loadCharacter()
                
                // ✨1 홈 뷰가 다시 나타날 때 네비게이션 트리거 설정
                // (데이터가 로드된 이후, 즉 최초 실행이 아닌 화면 전환 시에만)
                if viewModel.isDataReady {
                    viewModel.animationTrigger = .navigation
                }
            }
        }
        .alert("안내", isPresented: $showUpdateAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("추후 업데이트 예정입니다.")
        }
        .sheet(isPresented: $isShowingWriteStory) {
            if let character = viewModel.character {
                NavigationStack {
                    WriteStoryView(
                        currentMode: .create,
                        characterUUID: character.id
                    )
                    .environmentObject(authService)
                }
            }
        }
        .sheet(isPresented: $isShowingChatPet) {
            if let character = viewModel.character {
                let prompt = PetPrompt(
                    petType: character.species,
                    phase: character.status.phase,
                    name: character.name
                ).generatePrompt(status: character.status)
                
                ChatPetView(character: character, prompt: prompt)
            }
        }
        
        // 진화 화면 시트
        .sheet(isPresented: $showEvolutionScreen) {
            if let character = viewModel.character {
                EvolutionView(
                    character: character,
                    homeViewModel: viewModel,
                    isUpdateMode: false  // 진화 모드
                )
            }
        }
        
        // 업데이트 화면 시트
        .sheet(isPresented: $showUpdateScreen) {
            if let character = viewModel.character {
                EvolutionView(
                    character: character,
                    homeViewModel: viewModel,
                    isUpdateMode: true  // 업데이트 모드
                )
            }
        }
        // 온보딩 화면 시트
        .sheet(isPresented: $isShowingOnboarding) {
            OnboardingView()
        }
        .sheet(isPresented: $showAllActionsSheet) {
            AllActionsDebugView()
        }
        // 부화 팝업 오버레이
        .overlay {
            if viewModel.showEvolutionPopup {
                EvolutionPopupView(
                    isPresented: $viewModel.showEvolutionPopup,
                    onEvolutionStart: {
                        // 부화 버튼을 눌렀을 때 진화 화면 표시
                        showEvolutionScreen = true
                        print("🥚 부화 시작 - 진화 화면으로 이동")
                    },
                    onEvolutionDelay: {
                        // 보류 버튼을 눌렀을 때는 아무것도 하지 않음
                        print("⏸️ 부화 보류 - 나중에 다시 시도 가능")
                    }
                )
            }
            
            // 특수이벤트
            if showSpecialEvent {
                SpecialEventView(viewModel: viewModel, isPresented: $showSpecialEvent)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: showSpecialEvent)
            }
            
            // 헬스케어
            if showHealthCare {
                HealthCareView(
                    viewModel: viewModel,
                    isPresented: $showHealthCare
                )
            }
            
            // 인벤토리
            if showInventory {
                UserInventoryView(isPresented: $showInventory)
            }
        }
    }
    
    // 부화 진행 버튼
    private var evolutionButton: some View {
        Button(action: {
            showEvolutionScreen = true
        }) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                
                // 진화 상태에 따라 버튼 텍스트 변경
                Text(getEvolutionButtonText())
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
        }
    }
    
    // 업데이트 버튼
    private var updateButton: some View {
        Button(action: {
            showUpdateScreen = true
        }) {
            HStack {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 16))
                
                Text("데이터 업데이트")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
        }
    }
    
    // 진화 상태에 따른 버튼 텍스트 반환
    private func getEvolutionButtonText() -> String {
        guard let character = viewModel.character else { return "부화 진행" }
        
        switch character.status.evolutionStatus {
        case .toInfant:
            return "부화 진행"
        case .toChild:
            return "소아기 진화"
        case .toAdolescent:
            return "청년기 진화"
        case .toAdult:
            return "성년기 진화"
        case .toElder:
            return "노년기 진화"
        default:
            return "진화 진행"
        }
    }
    
    // 상태 메시지에 따른 색상을 반환합니다.
    private func getMessageColor() -> Color {
        let message = viewModel.statusMessage.lowercased()
        
        if message.contains("배고파") || message.contains("아파") || message.contains("지쳐") {
            return .red
        } else if message.contains("피곤") || message.contains("더러워") || message.contains("외로워") {
         
            return .orange
        } else if message.contains("행복") || message.contains("좋은") || message.contains("감사") {
            return .green
        } else if message.contains("잠을") {
            return .blue
        } else {
            return .primary
        }
    }
    
    // MARK: - UI Components
    
    // 레벨 프로그레스 바
    private var levelProgressBar: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("레벨 \(viewModel.level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                ZStack(alignment: .leading) {
                    // 배경 바 (전체 너비)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 20)
                    
                    // 진행 바
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "07a5ed"))
                            .frame(width: geometry.size.width * viewModel.expPercent, height: 20)
                            .animation(.easeInOut(duration: 0.8), value: viewModel.expPercent)
                        
                    }
                    .frame(height: 20)
                }
            }
        }
        .padding(.top, 10)
    }
    
    // 말풍선 섹션
    private var speechBubbleSection: some View {
        // SpeechBubbleView는 항상 존재하지만, 메시지 유무에 따라 투명도만 조절
        SpeechBubbleView(message: viewModel.statusMessage, color: getMessageColor())
            .frame(height: 50, alignment: .bottom) // 말풍선이 차지할 고정 높이를 지정하여 레이아웃 밀림 방지
            .opacity(!viewModel.statusMessage.isEmpty && !viewModel.isSleeping ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.4), value: viewModel.statusMessage.isEmpty)
    }
    
    // 캐릭터 섹션
    private var characterSection: some View {
        ZStack {
            // 캐릭터 이미지
            VStack {
                Spacer()
                
                ZStack {
                    ScreenView(
                        viewModel: viewModel,
                        character: viewModel.character,
                        isSleeping: viewModel.isSleeping,
                        onCreateCharacterTapped: {
                            // 캐릭터 생성 버튼이 눌렸을 때 온보딩 표시
                            isShowingOnboarding = true
                        }
                    )
                }
            }
            
            HStack {
                // 왼쪽 버튼들
                VStack(spacing: 15) {
                    ForEach(0..<3) { index in
                        let button = viewModel.sideButtons[index]
                        iconButton(systemName: button.icon, name: button.name, unlocked: button.unlocked)
                    }
                }
                
                Spacer()
                
                // 오른쪽 버튼들
                VStack(spacing: 15) {
                    ForEach(3..<6) { index in
                        let button = viewModel.sideButtons[index]
                        iconButton(systemName: button.icon, name: button.name, unlocked: button.unlocked)
                    }
                }
            }
            
            VStack {
                Spacer()
                
                // 부화&진화 진행 버튼 (진화가 필요한 경우에만 표시)
                if let character = viewModel.character,
                   character.status.evolutionStatus.needsEvolution {
                    evolutionButton
                }
                
                // 업데이트 버튼 (업데이트가 필요한 경우에만 표시)
                if viewModel.needsAnimationUpdate {
                    updateButton
                }
            }
        }
    }
    
    // 상태 바 섹션
    private var statsSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.stats, id: \.icon) { stat in
                HStack(spacing: 15) {
                    // 아이콘
                    Image(systemName: stat.icon)
                        .foregroundStyle(stat.iconColor)
                        .frame(width: 30)
                    
                    // 상태 바
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 배경 바 (전체 너비)
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 12)
                                .foregroundStyle(Color.gray.opacity(0.1))
                            
                            // 진행 바
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: geometry.size.width * stat.value, height: 12)
                                .foregroundStyle(stat.color)
                                .animation(.easeInOut(duration: 0.6), value: stat.value)
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
        .padding(.vertical)
    }
    
    // 액션 버튼 그리드
    private var actionButtonsGrid: some View {
        ZStack {
            if viewModel.isFeeding {
                ActionProgressView(progress: viewModel.feedingProgress, text: "우유 먹는 중...")
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            } else {
                HStack(spacing: 15) {
                    ForEach(Array(viewModel.actionButtons.enumerated()), id: \.offset) { index, action in
                        Button(action: {
                            if action.icon == "plus.circle" {
                                // 캐릭터 생성 버튼인 경우 온보딩 화면으로 이동
                                isShowingOnboarding = true
                            } else {
                                viewModel.performAction(at: index)
                            }
                        }) {
                            ZStack {
                                // 바깥쪽 배경 + 그림자
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(action.unlocked ? 0.25 : 0.15))
                                    .frame(width: 75, height: 75)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                                if !action.unlocked {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.white)
                                        .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                                } else {
                                    VStack(spacing: 5) {
                                        Image(action.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 42, height: 42)
                                            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)

                                        Text(action.name)
                                            .font(.caption2)
                                            .bold()
                                            .foregroundStyle(.white)
                                            .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                                    }
                                    .padding(8)
                                }
                            }
                            // 바깥 테두리 유지
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(viewModel.isAnimationRunning || (viewModel.isSleeping && action.icon != "nightIcon" && action.icon != "plus.circle"))
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }
        .frame(height: 75) // ZStack 전체 높이를 고정하여 레이아웃 흔들림 방지
    }
    
    // 아이콘 버튼
    @ViewBuilder
    private func iconButton(systemName: String, name: String, unlocked: Bool) -> some View {
        // "backpackIcon2"가 인벤토리 아이콘 이름인 것으로 보입니다
        if systemName == "backpackIcon2" {
            return AnyView(
                Button(action: {
                    // 인벤토리 오버레이 표시
                    showInventory = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(unlocked ? 0.25 : 0.1))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                        VStack(spacing: 3) {
                            Image(systemName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundStyle(unlocked ? .white : .gray)
                                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)

                            Text(name)
                                .font(.system(size: 9))
                                .bold()
                                .foregroundStyle(unlocked ? .white : .gray)
                                .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .disabled(!unlocked)
            )
        } else if systemName == "lock.fill" {
            // SF Symbol(시스템 아이콘)인 경우 처리
            return AnyView(
                Button(action: {
                    handleButtonAction(systemName: systemName)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(unlocked ? 0.25 : 0.1))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        VStack(spacing: 3) {
                            Image(systemName: "lock.fill")  // 시스템 심볼 사용
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(unlocked ? .orange : .gray)
                                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            Text(name)
                                .font(.system(size: 9))
                                .bold()
                                .foregroundStyle(unlocked ? .white : .gray)
                                .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .disabled(!unlocked)
            )
        } else {
            // 기존 아이콘 버튼 코드 유지 (다른 버튼들)
            return AnyView(
                Button(action: {
                    handleButtonAction(systemName: systemName)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(unlocked ? 0.25 : 0.1))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        VStack(spacing: 3) {
                            Image(systemName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundStyle(unlocked ? .white : .gray)
                                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            Text(name)
                                .font(.system(size: 9))
                                .bold()
                                .foregroundStyle(unlocked ? .white : .gray)
                                .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .disabled(!unlocked)
            )
        }
    }
    

    
    private func handleButtonAction(systemName: String) {
        // 애니메이션 실행 중일 때는 액션 처리하지 않음
        guard !viewModel.isAnimationRunning else {
            return
        }
        
        switch systemName {
        case "backpack.fill": // 인벤토리
            showInventory.toggle()
        case "healthIcon": // 헬스케ㅇ
            if let character = viewModel.character {
                showHealthCare = true
            } else {
                // 캐릭터가 없는 경우 경고 표시
                viewModel.statusMessage = "먼저 캐릭터를 생성해주세요."
            }
        case "specialGiftIcon": // 특수 이벤트 (아이콘 변경)
            withAnimation {
                showSpecialEvent = true
            }
        case "contractIcon": // 일기
            if let character = viewModel.character {
                // 스토리 작성 시트 표시
                isShowingWriteStory = true
            } else {
                // 캐릭터가 없는 경우 경고 표시
                viewModel.statusMessage = "먼저 캐릭터를 생성해주세요."
            }
        case "chatIcon": // 채팅
            if let character = viewModel.character {
                // 챗펫 시트 표시
                isShowingChatPet = true
            } else {
                // 캐릭터가 없는 경우 경고 표시
                viewModel.statusMessage = "먼저 캐릭터를 생성해주세요."
            }
        case "lock.fill": // 설정
#if DEBUG
            // 디버그 모드에서는 액션을 표시하는 시트와 업데이트 알림창 모두 표시
            showAllActionsSheet = true
#else
            // 릴리즈 모드에서는 업데이트 알림창만 표시
            showUpdateAlert = true
#endif
        default:
            break
        }
    }
    
    // 버튼 내용 (재사용 가능한 부분)
    private func handleSideButtonAction(systemName: String) {
        switch systemName {
        case "backpack.fill": // 인벤토리
            showInventory.toggle()
        case "healthIcon": // 헬스케어
            if let character = viewModel.character {
                showHealthCare = true
            } else {
                // 캐릭터가 없는 경우 경고 표시
                viewModel.statusMessage = "먼저 캐릭터를 생성해주세요."
            }
        case "treeIcon": // 동산
            showSpecialEvent.toggle() // 특수 이벤트 표시
        case "contractIcon": // 일기
            if let character = viewModel.character {
                // 스토리 작성 시트 표시
                isShowingWriteStory = true
            } else {
                // 캐릭터가 없는 경우 경고 표시
                viewModel.statusMessage = "먼저 캐릭터를 생성해주세요."
            }
        case "chatIcon": // 채팅
            if let character = viewModel.character {
                // 챗펫 시트 표시
                isShowingChatPet = true
            } else {
                // 캐릭터가 없는 경우 경고 표시
                viewModel.statusMessage = "먼저 캐릭터를 생성해주세요."
            }
        case "lock.fill": // 설정
            // 설정 시트 표시
            showUpdateAlert = true
        default:
            break
        }
    }
    
}

// MARK: - Preview
#Preview {
    HomeView()
}
