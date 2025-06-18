//
//  ChatPetView.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//  Updated by YourName on 6/15/25.
//

import SwiftUI

struct ChatPetView: View {
    @StateObject private var viewModel: ChatPetViewModel
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isInputFocused: Bool
    @State private var showUpdateAlert = false // 업데이트 알림 표시 여부
    @State private var showingShopView = false // 상점 화면 표시 여부
    @State private var showSettings = false // 설정 표시 여부

    // 캐릭터와 프롬프트 직접 저장
    let character: GRCharacter
    let prompt: String
    
    init(character: GRCharacter, prompt: String) {
        self.character = character
        self.prompt = prompt
        _viewModel = StateObject(wrappedValue: ChatPetViewModel(character: character, prompt: prompt))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경색 변경 - 건강관리뷰와 동일하게 메인 컬러 사용
                GRColor.mainColor1_1
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 챗펫 정보 헤더 (남은 채팅 기회 포함)
                    petInfoHeader
                    
                    // 대화 내역
                    chatMessagesArea
                    
                    // 메시지 입력 영역
                    messageInputArea
                }
                
                // 로딩 표시
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.2))
                                .frame(width: 100, height: 100)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("대화종료") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundStyle(GRColor.mainColor6_2)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(GRColor.mainColor6_2)
                    }
                }
            }
            .alert(item: Binding<AlertItem?>(
                get: {
                    viewModel.errorMessage.map { message in
                        AlertItem(message: message)
                    }
                },
                set: { _ in
                    viewModel.errorMessage = nil
                }
            )) { alert in
                Alert(
                    title: Text("오류"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("확인"))
                )
            }
            .alert("음성 대화 모드", isPresented: $showUpdateAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("추후 음성 대화 모드 업데이트 예정입니다.")
            }
            .alert("대화 횟수 제한", isPresented: $viewModel.showChatLimitAlert) {
                Button("상점 가기") {
                    showingShopView = true
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("대화 횟수를 모두 사용했습니다. 상점에서 채팅 티켓을 구매하거나, 내일 다시 시도해주세요.")
            }
            .alert("티켓 구매 필요", isPresented: $viewModel.showBuyTicketAlert) {
                Button("상점 가기") {
                    showingShopView = true
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("대화 티켓이 부족합니다. 상점에서 티켓을 구매하시겠습니까?")
            }
            .sheet(isPresented: $showSettings) {
                ChatPetSettingsView(showSubtitle: $viewModel.showSubtitle)
            }
            .onTapGesture {
                // 배경 탭 시 키보드 숨기기
                if isInputFocused {
                    isInputFocused = false
                }
            }
        }
    }
    
    // MARK: - 펫 정보 헤더 (남은 채팅 기회 포함)
    private var petInfoHeader: some View {
        ZStack {
            // 배경
            RoundedRectangle(cornerRadius: 15)
                .fill(GRColor.mainColor2_1)
                .shadow(color: GRColor.mainColor8_2.opacity(0.1), radius: 3, x: 0, y: 2)
            
            // 내용
            VStack(spacing: 8) {
                // 펫 이미지와 이름
                VStack(spacing: 4) {
                    // 펫 이미지 - 실제로는 character.image 사용
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(GRColor.mainColor6_2)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(GRColor.mainColor6_1.opacity(0.3))
                        )
                    
                    // 펫 이름
                    Text(character.name)
                        .font(.headline)
                        .foregroundStyle(GRColor.fontMainColor)
                }
                .padding(.vertical, 8)
            }
            
            // 오른쪽 상단에 남은 채팅 횟수 표시
            VStack {
                HStack {
                    Spacer()
                    
                    // 남은 채팅 횟수 아이콘과 숫자
                    HStack(spacing: 4) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(GRColor.mainColor6_2)
                        
                        Text("\(viewModel.remainingChats)/3")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(viewModel.remainingChats > 0 ? GRColor.mainColor6_2 : GRColor.grColorOrange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(GRColor.mainColor3_1)
                            .overlay(
                                Capsule()
                                    .stroke(GRColor.mainColor3_2.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(10)
                }
                
                Spacer()
            }
        }
        .frame(height: 120)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - 대화 내역 영역
    private var chatMessagesArea: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            showSubtitle: viewModel.showSubtitle,
                            character: character
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                // 새 메시지가 추가될 때마다 스크롤
                .onChange(of: viewModel.messages.count) {
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: GRColor.mainColor8_2.opacity(0.1), radius: 3, x: 0, y: 2)
                    .padding(.horizontal, 8)
            )
        }
    }
    
    // MARK: - 메시지 입력 영역
    private var messageInputArea: some View {
        VStack(spacing: 0) {
            Divider()
                .background(GRColor.mainColor3_2.opacity(0.3))
            
            HStack(spacing: 12) {
                if !viewModel.isListening {
                    TextField("메시지 입력", text: $viewModel.inputText)
                        .padding(10)
                        .background(GRColor.mainColor1_1)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(GRColor.mainColor3_2.opacity(0.5), lineWidth: 1)
                        )
                        .focused($isInputFocused)
                } else {
                    Text("음성 변환 중...")
                        .foregroundStyle(GRColor.fontSubColor)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(GRColor.mainColor1_1)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(GRColor.mainColor3_2.opacity(0.5), lineWidth: 1)
                        )
                }
                
                // 음성 대화 모드 버튼 - 클릭 시 업데이트 예정 알림
                Button(action: {
                    showUpdateAlert = true
                }) {
                    Image(systemName: "mic")
                        .font(.system(size: 20))
                        .foregroundStyle(GRColor.fontMainColor)
                        .padding(8)
                        .background(GRColor.mainColor4_1)
                        .clipShape(Circle())
                }
                
                // 메시지 전송 버튼 (텍스트가 있을 때만 표시)
                if !viewModel.inputText.isEmpty && !viewModel.isListening {
                    Button(action: {
                        viewModel.sendMessage()
                        isInputFocused = false
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(GRColor.buttonColor_2)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(GRColor.mainColor2_1)
        }
    }
}

// MARK: - 메시지 버블 컴포넌트
struct MessageBubble: View {
    let message: ChatMessage
    let showSubtitle: Bool
    let character: GRCharacter
    
    var body: some View {
        HStack {
            if message.isFromPet {
                // 펫 메시지 (왼쪽 정렬)
                HStack(alignment: .bottom, spacing: 8) {
                    // 펫 프로필 이미지
                    Circle()
                        .fill(GRColor.mainColor6_1)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .foregroundStyle(GRColor.mainColor6_2)
                        )
                    
                    // 메시지 버블
                    VStack(alignment: .leading, spacing: 4) {
                        // 메시지 내용
                        Text(message.text)
                            .padding(12)
                            .background(GRColor.mainColor5_1)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(GRColor.mainColor5_2.opacity(0.3), lineWidth: 1)
                            )
                        
                        // 시간 표시
                        if showSubtitle {
                            Text(formatTime(message.timestamp))
                                .font(.caption2)
                                .foregroundStyle(GRColor.fontSubColor)
                                .padding(.leading, 8)
                        }
                    }
                    
                    Spacer()
                }
            } else {
                // 사용자 메시지 (오른쪽 정렬)
                HStack(alignment: .bottom, spacing: 8) {
                    Spacer()
                    
                    // 메시지 버블
                    VStack(alignment: .trailing, spacing: 4) {
                        // 메시지 내용
                        Text(message.text)
                            .padding(12)
                            .foregroundStyle(.white)
                            .background(GRColor.buttonColor_2)
                            .cornerRadius(16)
                        
                        // 시간 표시
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundStyle(GRColor.fontSubColor)
                            .padding(.trailing, 8)
                    }
                    
                    // 사용자 프로필 이미지
                    Circle()
                        .fill(GRColor.mainColor8_1)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(GRColor.mainColor8_2)
                        )
                }
            }
        }
    }
    
    // 시간 포맷팅 함수
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 챗펫 설정 뷰
struct ChatPetSettingsView: View {
    @Binding var showSubtitle: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("대화 설정")) {
                    Toggle(isOn: $showSubtitle) {
                        Label("자막 표시", systemImage: "text.bubble")
                    }
                    .tint(GRColor.buttonColor_2)
                    
                    // 음성 변경 옵션 (비활성화 상태)
                    HStack {
                        Label("음성 변경", systemImage: "speaker.wave.2")
                        Spacer()
                        Text("업데이트 예정")
                            .foregroundStyle(.gray)
                    }
                    .opacity(0.6)
                }
                .listRowBackground(GRColor.mainColor1_1)
            }
            .background(GRColor.mainColor1_1.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("설정", displayMode: .inline)
            .navigationBarItems(trailing: Button("완료") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundStyle(GRColor.buttonColor_2))
        }
    }
}
