//
//  HomeView.swift
//  Grruung
//
//  Created by NoelMacMini on 5/1/25.
//

import SwiftUI

// MARK: - 홈 뷰 구현
struct HomeTestView: View {
    @StateObject private var viewModel = HomeTestViewModel()
    @State private var showingChatPet = false
    @State private var showTestControls = false
    @State private var showCharacterPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 캐릭터 선택 버튼
                    characterSelectionButton
                    
                    // 펫 정보 및 상태 표시
                    petInfoSection
                    
                    // 펫 컨트롤 버튼
                    petControlsSection
                    
                    // 테스트 모드 토글 버튼
                    testModeToggleButton
                    
                    // 테스트 컨트롤 (토글시 표시)
                    if showTestControls {
                        testControlsSection
                    }
                }
                .padding()
            }
            .navigationTitle("홈")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingChatPet = true
                    }) {
                        Label("채팅", systemImage: "bubble.left.fill")
                    }
                    .disabled(viewModel.selectedCharacter == nil)
                }
            }
            .sheet(isPresented: $showingChatPet) {
                if let character = viewModel.selectedCharacter,
                   let prompt = viewModel.generateChatPetPrompt() {
                    ChatPetView(character: character, prompt: prompt)
                } else {
                    Text("캐릭터 정보를 불러올 수 없습니다.")
                }
            }
            .sheet(isPresented: $showCharacterPicker) {
                characterPickerView
            }
            .onAppear {
                viewModel.loadCharacters()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .padding(30)
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("오류"),
                    message: Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    // MARK: - 캐릭터 선택 버튼
    private var characterSelectionButton: some View {
        Button(action: {
            showCharacterPicker = true
        }) {
            HStack {
                if let character = viewModel.selectedCharacter {
                    // 선택된 캐릭터가 있는 경우
                    VStack(alignment: .leading) {
                        Text("현재 선택된 캐릭터: \(character.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // 선택된 캐릭터가 없는 경우
                    Text("캐릭터 선택하기")
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    // MARK: - 캐릭터 선택 피커 뷰
    private var characterPickerView: some View {
        NavigationView {
            List {
                if viewModel.characters.isEmpty {
                    Text("저장된 캐릭터가 없습니다.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ForEach(viewModel.characters) { character in
                        Button(action: {
                            viewModel.selectedCharacter = character
                            showCharacterPicker = false
                        }) {
                            HStack {
                                // 캐릭터 이미지
                                Image.testCharacterImage(for: character.species, phase: character.status.phase)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(6)
                                
                                // 캐릭터 정보
                                VStack(alignment: .leading) {
                                    Text(character.name)
                                        .font(.headline)
                                    
                                    Text("Lv.\(character.status.level) \(character.species.rawValue) - \(character.status.phase.rawValue)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                // 현재 선택된 캐릭터 표시
                                if viewModel.selectedCharacter?.id == character.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // 새 캐릭터 생성 버튼
                Button(action: {
                    showCharacterPicker = false
                    showTestControls = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                        Text("새 캐릭터 생성하기")
                            .fontWeight(.medium)
                    }
                }
                .padding(.vertical, 8)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("캐릭터 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        showCharacterPicker = false
                    }
                }
            }
            .refreshable {
                viewModel.loadCharacters()
            }
        }
    }
    
    
    // MARK: - 펫 정보 섹션
    private var petInfoSection: some View {
        VStack(spacing: 15) {
            if let character = viewModel.selectedCharacter {
                // 펫 이미지
                Image.testCharacterImage(for: character.species, phase: character.status.phase)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // 펫 이름 및 상태
                Text(character.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Lv.\(character.status.level) - \(character.status.phase.rawValue)")
                    .font(.subheadline)
                
                Text(viewModel.getStatusMessage())
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                
                // 기본 스텟 표시
                VStack(spacing: 10) {
                    // 경험치
                    HStack {
                        Text("경험치:")
                            .frame(width: 60, alignment: .leading)
                        ProgressView(value: viewModel.expPercent)
                        Text("\(viewModel.expValue)/\(viewModel.expMaxValue)")
                            .frame(width: 70, alignment: .trailing)
                    }
                    
                    // 포만감
                    HStack {
                        Text("포만감:")
                            .frame(width: 60, alignment: .leading)
                        ProgressView(value: viewModel.satietyPercent)
                        Text("\(viewModel.satietyValue)/100")
                            .frame(width: 70, alignment: .trailing)
                    }
                    
                    // 체력
                    HStack {
                        Text("체력:")
                            .frame(width: 60, alignment: .leading)
                        ProgressView(value: viewModel.staminaPercent)
                        Text("\(viewModel.staminaValue)/100")
                            .frame(width: 70, alignment: .trailing)
                    }
                    
                    // 활동량
                    HStack {
                        Text("활동량:")
                            .frame(width: 60, alignment: .leading)
                        ProgressView(value: viewModel.activityPercent)
                        Text("\(viewModel.activityValue)/100")
                            .frame(width: 70, alignment: .trailing)
                    }
                }
                .padding(.horizontal)
                
                // 히든 스텟 표시
                VStack(spacing: 10) {
                    Text("히든 스텟")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    // 건강
                    HStack {
                        Text("건강:")
                            .frame(width: 60, alignment: .leading)
                        ProgressView(value: CGFloat(viewModel.healthyValue) / 100)
                        Text("\(viewModel.healthyValue)/100")
                            .frame(width: 70, alignment: .trailing)
                    }
                    
                    // 청결
                    HStack {
                        Text("청결:")
                            .frame(width: 60, alignment: .leading)
                        ProgressView(value: CGFloat(viewModel.cleanValue) / 100)
                        Text("\(viewModel.cleanValue)/100")
                            .frame(width: 70, alignment: .trailing)
                    }
                    
                    // 애정도
                    HStack {
                        Text("애정도:")
                            .frame(width: 60, alignment: .leading)
                        ProgressView(value: CGFloat(viewModel.affectionValue) / 100)
                        Text("\(viewModel.affectionValue)/100")
                            .frame(width: 70, alignment: .trailing)
                    }
                }
                .padding(.horizontal)
                
            } else {
                Text("펫이 없습니다")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding()
                
                Button("펫 생성하기") {
                    showTestControls = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    
    // MARK: - 펫 컨트롤 버튼 섹션
    private var petControlsSection: some View {
        VStack(spacing: 15) {
            Text("상호작용")
                .font(.headline)
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.updateSelectedCharacter(satiety: 10)
                }) {
                    VStack {
                        Image(systemName: "fork.knife")
                            .font(.title)
                        Text("먹이주기")
                            .font(.caption)
                    }
                    .frame(width: 70, height: 70)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.updateSelectedCharacter(stamina: 10)
                }) {
                    VStack {
                        Image(systemName: "bed.double.fill")
                            .font(.title)
                        Text("재우기")
                            .font(.caption)
                    }
                    .frame(width: 70, height: 70)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.updateSelectedCharacter(
                        activity: 10,
                        affection: 5,
                        healthy: 5
                    )
                }) {
                    VStack {
                        Image(systemName: "figure.walk")
                            .font(.title)
                        Text("산책하기")
                            .font(.caption)
                    }
                    .frame(width: 70, height: 70)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.updateSelectedCharacter(
                        affection: 5, clean: 10
                    )
                }) {
                    VStack {
                        Image(systemName: "shower.fill")
                            .font(.title)
                        Text("씻기기")
                            .font(.caption)
                    }
                    .frame(width: 70, height: 70)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            
            Button(action: {
                viewModel.addExperience(10)
            }) {
                Label("경험치 주기 (+10)", systemImage: "star.fill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - 테스트 모드 토글 버튼
    private var testModeToggleButton: some View {
        Button(action: {
            withAnimation {
                showTestControls.toggle()
            }
        }) {
            HStack {
                Image(systemName: showTestControls ? "chevron.up" : "chevron.down")
                Text(showTestControls ? "테스트 컨트롤 닫기" : "테스트 컨트롤 열기")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
    
    // MARK: - 테스트 컨트롤 섹션
    private var testControlsSection: some View {
        VStack(spacing: 15) {
            Text("테스트 캐릭터 설정")
                .font(.headline)
                .padding(.top)
            
            // 이름 입력
            TextField("캐릭터 이름", text: $viewModel.testName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // 종류 선택
            Picker("종류", selection: $viewModel.testSpecies) {
                ForEach(PetSpecies.allCases, id: \.self) { species in
                    Text(species.rawValue).tag(species)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // 성장단계 선택
            Picker("성장단계", selection: $viewModel.testPhase) {
                ForEach([CharacterPhase.egg, .infant, .child, .adolescent, .adult, .elder], id: \.self) { phase in
                    Text(phase.rawValue).tag(phase)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // 스텟 슬라이더
            Group {
                Text("기본 스텟")
                    .font(.subheadline)
                    .padding(.top, 5)
                
                // 포만감 슬라이더
                VStack(alignment: .leading) {
                    HStack {
                        Text("포만감:")
                        Spacer()
                        Text("\(viewModel.satietyValue)")
                        
                    }
                    
                    Slider(value: Binding<Double>(
                        get: { Double(viewModel.satietyValue) },
                        set: { viewModel.satietyValue = Int($0) }
                    ), in: 0...100, step: 1)
                }
                .padding(.horizontal)
                
                // 체력 슬라이더
                VStack(alignment: .leading) {
                    HStack {
                        Text("체력:")
                        Spacer()
                        Text("\(viewModel.staminaValue)")
                    }
                    Slider(value: Binding<Double>(
                        get: { Double(viewModel.staminaValue) },
                        set: { viewModel.staminaValue = Int($0) }
                    ), in: 0...100, step: 1)
                }
                .padding(.horizontal)
                
                // 활동량 슬라이더
                VStack(alignment: .leading) {
                    HStack {
                        Text("활동량:")
                        Spacer()
                        Text("\(viewModel.activityValue)")
                    }
                    Slider(value: Binding<Double>(
                        get: { Double(viewModel.activityValue) },
                        set: { viewModel.activityValue = Int($0) }
                    ), in: 0...100, step: 1)
                }
                .padding(.horizontal)
            }
            
            Group {
                Text("히든 스텟")
                    .font(.subheadline)
                    .padding(.top, 5)
                
                // 건강 슬라이더
                VStack(alignment: .leading) {
                    HStack {
                        Text("건강:")
                        Spacer()
                        Text("\(viewModel.healthyValue)")
                    }
                    Slider(value: Binding<Double>(
                        get: { Double(viewModel.healthyValue) },
                        set: { viewModel.healthyValue = Int($0) }
                    ), in: 0...100, step: 1)
                }
                
                .padding(.horizontal)
                
                // 청결도 슬라이더
                VStack(alignment: .leading) {
                    HStack {
                        Text("청결도:")
                        Spacer()
                        Text("\(viewModel.cleanValue)")
                    }
                    Slider(value: Binding<Double>(
                        get: { Double(viewModel.cleanValue) },
                        set: { viewModel.cleanValue = Int($0) }
                    ), in: 0...100, step: 1)
                }
                .padding(.horizontal)
                
                // 애정도 슬라이더
                VStack(alignment: .leading) {
                    HStack {
                        Text("애정도:")
                        Spacer()
                        Text("\(viewModel.affectionValue)")
                    }
                    Slider(value: Binding<Double>(
                        get: { Double(viewModel.affectionValue) },
                        set: { viewModel.affectionValue = Int($0) }
                    ), in: 0...100, step: 1)
                }
                .padding(.horizontal)
            }
            
            
            Group {
                Text("경험치")
                    .font(.subheadline)
                    .padding(.top, 5)
                
                // 현재 경험치 슬라이더
                VStack(alignment: .leading) {
                    HStack {
                        Text("현재 경험치:")
                        Spacer()
                        Text("\(viewModel.expValue)")
                    }
                    Slider(value: Binding<Double>(
                        get: { Double(viewModel.expValue) },
                        set: { viewModel.expValue = Int($0) }
                    ), in: 0...Double(max(100, viewModel.expMaxValue)), step: 1)
                }
                .padding(.horizontal)
                
                // 다음 레벨 경험치 슬라이더
                VStack(alignment: .leading) {
                    HStack {
                        Text("다음 레벨까지:")
                        Spacer()
                        Text("\(viewModel.expMaxValue)")
                    }
                    Slider(value: Binding<Double>(
                        get: { Double(viewModel.expMaxValue) },
                        set: { viewModel.expMaxValue = max(100, Int($0)) }
                    ), in: 100...500, step: 10)
                }
                .padding(.horizontal)
            }
            
            // 버튼 그룹
            HStack(spacing: 15) {
                Button("테스트 캐릭터 생성") {
                    viewModel.createTestCharacter(
                        name: viewModel.testName.isEmpty ? nil : viewModel.testName,
                        satiety: viewModel.satietyValue,
                        stamina: viewModel.staminaValue,
                        activity: viewModel.activityValue,
                        affection: viewModel.affectionValue,
                        healthy: viewModel.healthyValue,
                        clean: viewModel.cleanValue
                    )
                }
                .buttonStyle(.borderedProminent)
                
                Button("Firestore에 저장") {
                    viewModel.saveTestCharacterToFirestore()
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.testMode)
            }
            .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}


#Preview {
    HomeTestView()
}
