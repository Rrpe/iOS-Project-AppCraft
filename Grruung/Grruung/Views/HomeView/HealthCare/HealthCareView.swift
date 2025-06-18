//
//  HealthCareView.swift
//  Grruung
//
//  Created by KimJunsoo on 6/10/25.
//

import SwiftUI

struct HealthCareView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedTab = 0
    
    // MARK: - Body
    var body: some View {
        // 오버레이 배경
        ZStack {
            // 반투명 배경 (탭 시 닫힘)
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // 메인 컨텐츠 컨테이너
            VStack(spacing: 0) {
                // 헤더
                HStack {
                    Text("건강 & 청결 관리")
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
                
                // 탭 선택 바
                HStack(spacing: 20) {
                    tabButton("건강관리", index: 0)
                    tabButton("청결관리", index: 1)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Divider()
                    .background(GRColor.mainColor8_2.opacity(0.2))
                    .padding(.vertical, 5)
                
                // 탭 콘텐츠
                if selectedTab == 0 {
                    healthCareContent
                } else {
                    cleanCareContent
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
    }
    
    // MARK: - 건강 관리 탭 콘텐츠
    private var healthCareContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 현재 건강 상태 표시 (체크 시에만 표시)
                if viewModel.showHealthStatus {
                    statusCard(
                        title: "현재 건강 상태",
                        value: viewModel.healthyValue,
                        maxValue: 100,
                        icon: "heart.fill",
                        color: GRColor.grColorRed
                    )
                } else {
                    healthStatusHiddenView
                }
                
                // 건강 관리 액션 버튼들
                VStack(alignment: .leading, spacing: 10) {
                    Text("건강 관리 액션")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            actionButton(
                                title: "건강 체크",
                                icon: "stethoscope",
                                description: "건강 상태 확인",
                                cost: "골드 100",
                                action: { performHealthAction("checkup") }
                            )
                            
                            actionButton(
                                title: "영양제",
                                icon: "drop.fill",
                                description: "건강 상태 10 회복",
                                cost: "골드 200",
                                action: { performHealthAction("vitamin") }
                            )
                            
                            actionButton(
                                title: "약 먹이기",
                                icon: "pills.fill",
                                description: "건강 상태 30 회복",
                                cost: "골드 500",
                                action: { performHealthAction("medicine") }
                            )
                            
                            actionButton(
                                title: "병원 방문",
                                icon: "cross.fill",
                                description: "건강 상태 완전 회복",
                                cost: "골드 1000",
                                action: { performHealthAction("hospital") }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 건강 관련 팁
                tipCard(
                    tip: "펫의 건강 상태가 30 미만으로 떨어지면 활동량 회복이 느려집니다.",
                    icon: "exclamationmark.triangle.fill",
                    isWarning: true
                )
                
                tipCard(
                    tip: "건강 체크로 현재 상태를 확인하고, 필요한 경우 약을 먹이세요.",
                    icon: "lightbulb.fill",
                    isWarning: false
                )
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
    
    // 건강 상태가 숨겨져 있을 때 표시할 뷰
    private var healthStatusHiddenView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundStyle(GRColor.mainColor6_2)
                Text("건강 상태 정보")
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
                Text("? / 100")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            }
            
            // 상태 게이지 바 (잠김 상태)
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                    .overlay(
                        HStack(spacing: 5) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "questionmark")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.white)
                            }
                        }
                    )
            }
            .frame(height: 12)
            
            // 안내 메시지
            Text("건강 체크를 통해 현재 상태를 확인할 수 있습니다.")
                .font(.subheadline)
                .foregroundStyle(Color.black.opacity(0.7))
        }
        .padding()
        .background(GRColor.mainColor1_1)
        .cornerRadius(15)
        .shadow(color: GRColor.mainColor8_2.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(GRColor.mainColor3_2.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - 청결 관리 탭 콘텐츠
    private var cleanCareContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 현재 청결 상태 표시 (체크 시에만 표시)
                if viewModel.showCleanStatus {
                    statusCard(
                        title: "현재 청결 상태",
                        value: viewModel.cleanValue,
                        maxValue: 100,
                        icon: "shower.fill",
                        color: GRColor.grColorOcean
                    )
                }  else {
                    cleanStatusHiddenView
                }
                
                // 청결 관리 액션 버튼들
                VStack(alignment: .leading, spacing: 10) {
                    Text("청결 관리 액션")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            actionButton(
                                title: "청결 체크",
                                icon: "hand.wave.fill",
                                description: "청결 상태 확인",
                                cost: "골드 100",
                                action: { performCleanAction("check") }
                            )
                            
                            actionButton(
                                title: "빗질하기",
                                icon: "comb.fill",
                                description: "청결 상태 15 회복",
                                cost: "골드 200",
                                action: { performCleanAction("brush") }
                            )
                            
                            actionButton(
                                title: "목욕시키기",
                                icon: "bathtub.fill",
                                description: "청결 상태 40 회복",
                                cost: "골드 500",
                                action: { performCleanAction("bath") }
                            )
                            
                            actionButton(
                                title: "미용실 방문",
                                icon: "scissors",
                                description: "청결 상태 완전 회복",
                                cost: "골드 1000",
                                action: { performCleanAction("salon") }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 청결 관련 팁
                tipCard(
                    tip: "펫의 청결 상태가 20 미만으로 떨어지면 건강 상태가 서서히 감소합니다.",
                    icon: "exclamationmark.triangle.fill",
                    isWarning: true
                )
                
                tipCard(
                    tip: "정기적인 목욕과 빗질로 펫의 청결을 유지하세요.",
                    icon: "lightbulb.fill",
                    isWarning: false
                )
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
    
    // 청결 상태가 숨겨져 있을 때 표시할 뷰
    private var cleanStatusHiddenView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundStyle(GRColor.mainColor6_2)
                Text("청결 상태 정보")
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
                Text("? / 100")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            }
            
            // 상태 게이지 바 (잠김 상태)
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                    .overlay(
                        HStack(spacing: 5) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "questionmark")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.white)
                            }
                        }
                    )
            }
            .frame(height: 12)
            
            // 안내 메시지
            Text("청결 체크를 통해 현재 상태를 확인할 수 있습니다.")
                .font(.subheadline)
                .foregroundStyle(Color.black.opacity(0.7))
        }
        .padding()
        .background(GRColor.mainColor1_1)
        .cornerRadius(15)
        .shadow(color: GRColor.mainColor8_2.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(GRColor.mainColor3_2.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - 컴포넌트
    
    // 탭 버튼
    private func tabButton(_ title: String, index: Int) -> some View {
        Button {
            withAnimation {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .fontWeight(selectedTab == index ? .bold : .regular)
                    .foregroundStyle(selectedTab == index ? GRColor.mainColor6_2 : Color.black.opacity(0.6))
                
                Rectangle()
                    .fill(selectedTab == index ? GRColor.mainColor6_2 : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // 상태 카드
    private func statusCard(title: String, value: Int, maxValue: Int, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
                Text("\(value)/\(maxValue)")
                    .fontWeight(.bold)
                    .foregroundStyle(getStatusColor(value: value, maxValue: maxValue))
            }
            
            // 상태 게이지 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경 바
                    RoundedRectangle(cornerRadius: 8)
                        .fill(GRColor.mainColor8_1.opacity(0.3))
                        .frame(height: 12)
                    
                    // 상태 바
                    RoundedRectangle(cornerRadius: 8)
                        .fill(getStatusColor(value: value, maxValue: maxValue))
                        .frame(width: geometry.size.width * CGFloat(value) / CGFloat(maxValue), height: 12)
                }
            }
            .frame(height: 12)
            
            // 상태 메시지
            Text(getStatusMessage(value: value, isHealth: icon == "heart.fill"))
                .font(.subheadline)
                .foregroundStyle(Color.black.opacity(0.8))

        }
        .padding()
        .background(GRColor.mainColor1_1)
        .cornerRadius(15)
        .shadow(color: GRColor.mainColor8_2.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(GRColor.mainColor3_2.opacity(0.3), lineWidth: 1)
        )
    }
    
    // 액션 버튼
    private func actionButton(title: String, icon: String, description: String, cost: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(GRColor.mainColor6_2)
                    .frame(width: 40, height: 40)
                    .background(GRColor.mainColor1_1)
                    .clipShape(Circle())
                    .shadow(color: GRColor.mainColor8_2.opacity(0.2), radius: 2, x: 0, y: 1)
                
                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(Color.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Text(cost)
                    .font(.caption2)
                    .foregroundStyle(GRColor.grColorOrange)
                    .fontWeight(.bold)
            }
            .frame(width: 90, height: 140)
            .padding(8)
            .background(GRColor.mainColor1_1)
            .cornerRadius(12)
            .shadow(color: GRColor.mainColor8_2.opacity(0.1), radius: 3, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(GRColor.mainColor3_2.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(icon.contains("heart") ? viewModel.isHealthActionInProgress : viewModel.isCleanActionInProgress)
        .opacity(
            (icon.contains("heart") ? viewModel.isHealthActionInProgress : viewModel.isCleanActionInProgress)
            ? 0.6 : 1.0
        )
    }
    
    // 팁 카드
    private func tipCard(tip: String, icon: String, isWarning: Bool) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(isWarning ? GRColor.grColorOrange : GRColor.grColorGreen)
                .frame(width: 24, height: 24)
            
            Text(tip)
                .font(.footnote)
                .foregroundStyle(Color.black.opacity(0.8))
            
            Spacer()
        }
        .padding()
        .background(isWarning ? GRColor.mainColor6_1.opacity(0.2) : GRColor.mainColor7_1.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isWarning ? GRColor.mainColor6_2.opacity(0.3) : GRColor.mainColor7_2.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - 헬퍼 메서드
    
    // 상태에 따른 색상 계산
    private func getStatusColor(value: Int, maxValue: Int) -> Color {
        let percentage = Double(value) / Double(maxValue)
        
        if percentage < 0.3 {
            return GRColor.grColorRed
        } else if percentage < 0.7 {
            return GRColor.grColorOrange
        } else {
            return GRColor.grColorGreen
        }
    }
    
    // 상태에 따른 메시지
    private func getStatusMessage(value: Int, isHealth: Bool) -> String {
        let percentage = Double(value) / 100.0
        
        if isHealth {
            if percentage < 0.3 {
                return "위험: 즉시 치료가 필요합니다!"
            } else if percentage < 0.5 {
                return "주의: 건강 상태가 좋지 않습니다."
            } else if percentage < 0.7 {
                return "양호: 조금 더 관리가 필요합니다."
            } else {
                return "건강: 상태가 좋습니다."
            }
        } else {
            if percentage < 0.3 {
                return "불결: 청결 관리가 시급합니다!"
            } else if percentage < 0.5 {
                return "지저분: 청결 상태가 좋지 않습니다."
            } else if percentage < 0.7 {
                return "보통: 조금 더 관리가 필요합니다."
            } else {
                return "깨끗: 청결 상태가 좋습니다."
            }
        }
    }
    
    // 건강 관련 액션 처리
    private func performHealthAction(_ actionId: String) {
        // 액션 진행 중이면 실행 방지
        guard !viewModel.isHealthActionInProgress else {
            return
        }
        
        var healthValue = 0
        var goldCost = 0
        
        switch actionId {
        case "checkup":
            healthValue = 0 // 체크만 하고 회복은 없음
            goldCost = 100
        case "vitamin":
            healthValue = 10
            goldCost = 200
        case "medicine":
            healthValue = 30
            goldCost = 500
        case "hospital":
            healthValue = 100 // 완전 회복
            goldCost = 1000
        default:
            return
        }
        
        // 액션 시작 (쿨타임 적용)
        viewModel.startHealthAction()
        
        // 골드 차감 로직 적용 (비동기)
        viewModel.spendGold(amount: goldCost) { success in
            if !success {
                // 골드 차감 실패 시 종료
                return
            }
            
            // 골드 차감 성공 시 액션 수행
            if actionId == "checkup" {
                // 건강 체크만 수행
                self.viewModel.statusMessage = "건강 상태 확인 결과: \(self.viewModel.healthyValue)/100"
                
                // 건강 상태 5분 동안 표시
                self.viewModel.showHealthStatusFor(minutes: 5)
            } else {
                // 회복 액션 수행
                if self.viewModel.character != nil {
                    // 캐릭터 상태 업데이트
                    self.viewModel.updateCharacterHealthStatus(healthValue: healthValue)
                    self.viewModel.statusMessage = "건강 상태가 회복되었습니다!"
                    
                    // 건강 상태 5분 동안 표시
                    self.viewModel.showHealthStatusFor(minutes: 5)
                    
                    // 회복 액션 후 팝업 닫기 (약간의 딜레이 적용)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation {
                            self.isPresented = false
                        }
                    }
                }
            }
        }
    }
    
    // 청결 관련 액션 처리
    private func performCleanAction(_ actionId: String) {
        // 액션 진행 중이면 실행 방지
        guard !viewModel.isCleanActionInProgress else {
            return
        }
        
        var cleanValue = 0
        var goldCost = 0
        
        switch actionId {
        case "check":
            cleanValue = 0 // 체크만 하고 회복은 없음
            goldCost = 100
        case "brush":
            cleanValue = 15
            goldCost = 200
        case "bath":
            cleanValue = 40
            goldCost = 500
        case "salon":
            cleanValue = 100 // 완전 회복
            goldCost = 1000
        default:
            return
        }
        
        // 액션 시작 (쿨타임 적용)
        viewModel.startCleanAction()
        
        // 골드 차감 로직 적용 (비동기)
        viewModel.spendGold(amount: goldCost) { success in
            if !success {
                // 골드 차감 실패 시 종료
                return
            }
            
            // 골드 차감 성공 시 액션 수행
            if actionId == "check" {
                // 청결 체크만 수행
                self.viewModel.statusMessage = "청결 상태 확인 결과: \(self.viewModel.cleanValue)/100"
                
                // 청결 상태 5분 동안 표시
                self.viewModel.showCleanStatusFor(minutes: 5)
            } else {
                // 회복 액션 수행
                if self.viewModel.character != nil {
                    // 캐릭터 상태 업데이트
                    self.viewModel.updateCharacterCleanStatus(cleanValue: cleanValue)
                    self.viewModel.statusMessage = "청결 상태가 개선되었습니다!"
                    
                    // 청결 상태 5분 동안 표시
                    self.viewModel.showCleanStatusFor(minutes: 5)
                    
                    // 회복 액션 후 팝업 닫기 (약간의 딜레이 적용)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation {
                            self.isPresented = false
                        }
                    }
                }
            }
        }
    }
}
