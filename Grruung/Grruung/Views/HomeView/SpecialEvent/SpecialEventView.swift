//
//  SpecialEventView.swift
//  Grruung
//
//  Created by KimJunsoo on 6/10/25.
//

import SwiftUI

struct SpecialEventView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isPresented: Bool
    
    @State private var currentIndex = 0
    @State private var events: [SpecialEvent] = []
    @State private var showingEventConfirmation = false
    @State private var selectedEvent: SpecialEvent?
    
    // MARK: - Init
    init(viewModel: HomeViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        
        // 현재 레벨에 맞는 이벤트 목록 가져오기
        let level = viewModel.level
        _events = State(initialValue: SpecialEventManager.shared.getAvailableEvents(level: level))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 배경 - 반투명 오버레이
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // 뷰 밖 영역 터치 시 닫기
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // 메인 컨텐츠
            VStack(spacing: 0) {
                // 헤더
                headerView
                    .padding(.bottom, 10)
                
                // 이벤트 카드 - 고정 높이로 설정
                eventCardContainer
                    .frame(height: 230)
                    .padding(.bottom, 20)
                
                // 이벤트 이름 및 설명
                if let event = getCurrentEvent() {
                    eventDetailView(event)
                }
                
                Spacer(minLength: 20)
            }
            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.7)
            .background(GRColor.mainColor2_1)
            .cornerRadius(20)
            .shadow(color: GRColor.mainColor8_2.opacity(0.3), radius: 15, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(GRColor.mainColor3_2.opacity(0.5), lineWidth: 1)
            )
        }
        .transition(.opacity)
        .alert("이벤트 참여", isPresented: $showingEventConfirmation) {
            Button("취소", role: .cancel) { }
            Button("참여하기") {
                if let event = selectedEvent {
                    participateInEvent()
                }
            }
        } message: {
            if let event = selectedEvent {
                Text("\(event.name)에 참여하려면 활동력 \(event.activityCost)이 소모됩니다.")
            }
        }
    }
    
    // MARK: - Subviews
    
    // 헤더
    private var headerView: some View {
        HStack {
            Text("특수 이벤트")
                .font(.headline)
                .bold()
                .foregroundStyle(.black)
            
            Spacer()
            
            Button {
                withAnimation {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(GRColor.mainColor6_2)
                    .font(.system(size: 22))
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // 이벤트 카드 컨테이너 - 고정 크기와 레이아웃 안정화
    private var eventCardContainer: some View {
        ZStack {
            // 배경 공간 - 레이아웃 안정화를 위한 고정 크기
            Rectangle()
                .fill(Color.clear)
                .frame(width: 300, height: 220)
            
            // 이벤트 카드 - 모든 이벤트 카드가 같은 크기로 유지됨
            if !events.isEmpty {
                eventCardView
            }
            
            // 이전/다음 버튼
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentIndex = (currentIndex - 1 + events.count) % events.count
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(GRColor.mainColor3_2)
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .padding(.leading, 0)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentIndex = (currentIndex + 1) % events.count
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(GRColor.mainColor3_2)
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .padding(.trailing, 0)
            }
            .frame(width: 300)
        }
    }
    
    // 이벤트 카드 - 모든 카드는 동일한 크기
    private var eventCardView: some View {
        let event = getCurrentEvent() ?? events[0]
        
        return ZStack {
            // 이미지 배경 - 고정 크기
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [GRColor.mainColor3_1, GRColor.mainColor3_2]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 200)
                .shadow(color: GRColor.mainColor8_2.opacity(0.3), radius: 5, x: 0, y: 3)
            
            // 이벤트 이미지 - 고정 크기
            getEventImage(for: event)
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            // 잠금 상태 표시
            if !event.unlocked {
                ZStack {
                    Color.black.opacity(0.6)
                    VStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.white)
                        
                        Text("Lv.\(event.requiredLevel) 필요")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 260, height: 180)
                .cornerRadius(15)
            }
        }
    }
    
    // 이벤트 상세 정보 - 스탯 수치 제거
    private func eventDetailView(_ event: SpecialEvent) -> some View {
        VStack(spacing: 15) {
            Text(event.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(GRColor.fontMainColor)
            
            Text(event.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(GRColor.fontSubColor)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)  // 텍스트가 잘리지 않도록
                .frame(height: 60)  // 설명 영역 고정 높이
            
            // 활동력 소모 정보 - 간결하게 표시
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(GRColor.grColorYellow)
                
                Text("활동력 \(event.activityCost) 소모")
                    .font(.subheadline)
                    .foregroundStyle(GRColor.fontSubColor)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .background(GRColor.mainColor1_1)
            .cornerRadius(15)
            
            // 참여 버튼
            Button(action: {
                selectedEvent = event
                showingEventConfirmation = true
            }) {
                Text(event.unlocked ? "참여하기" : "잠김")
                    .font(.headline)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(event.unlocked ? GRColor.mainColor3_2 : Color.gray.opacity(0.5))
                    .foregroundStyle(event.unlocked ? GRColor.fontMainColor : Color.white.opacity(0.7))
                    .cornerRadius(15)
                    .shadow(color: event.unlocked ? GRColor.mainColor8_2.opacity(0.3) : Color.clear, radius: 3, x: 0, y: 2)
            }
            .disabled(!event.unlocked)
            .padding(.top, 10)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Methods
    
    /// 현재 선택된 이벤트 가져오기
    private func getCurrentEvent() -> SpecialEvent? {
        guard !events.isEmpty else { return nil }
        return events[currentIndex]
    }
    
    /// 이벤트 참여 처리
    private func participateInEvent() {
        guard let event = selectedEvent, event.unlocked else { return }
        
        // HomeViewModel의 public 메서드 호출
        let success = viewModel.participateInSpecialEvent(
            eventId: event.id,
            name: event.name,
            activityCost: event.activityCost,
            effects: event.effects,
            expGain: event.expGain,
            successMessage: event.successMessage,
            failMessage: event.failMessage
        )
        
        // 성공한 경우에만 화면 닫기
        if success {
            withAnimation {
                isPresented = false
            }
        }
    }
    
    // 이벤트에 맞는 이미지 반환
    private func getEventImage(for event: SpecialEvent) -> Image {
        switch event.id {
        case "hot_spring":
            return Image("spevent_onsen")
        case "camping":
            return Image("spevent_camp")
        case "beach":
            return Image("spevent_beach")
        case "amusement_park":
            return Image("spevent_amuspark")
        case "mountain_hiking":
            return Image("spevent_mountain")
        default:
            // 기본 이미지가 없는 경우 시스템 아이콘 사용
            return Image(systemName: event.icon)
        }
    }
}

// MARK: - Preview
#Preview {
    SpecialEventView(viewModel: HomeViewModel(), isPresented: .constant(true))
}
