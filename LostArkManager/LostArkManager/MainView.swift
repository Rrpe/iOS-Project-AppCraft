//
//  MainView.swift
//  LostArkManager
//
//  Created by KimJunsoo on 2/11/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                MainTitleCard()
                MainCharacterCard()
                GoldsummaryChartCard()
                ResetTimerCard()
                RaidProgressCard()
            }
            .padding(20)
        }
        .background(Color.myDark)
    }
    
}

// 최상단 타이틀 블록
struct MainTitleCard: View {
    var body: some View {
        Text("LostArk")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.myWhite)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// 메인 캐릭터 상태 블록
struct MainCharacterCard: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundStyle(.myWhite)
            
            Text("홀나로운기사생활")
                .foregroundStyle(.white)
                .font(.headline)
            HStack {
                Text("1710")
                Text("홀리나이트")
            }
            .foregroundStyle(.gray)
            .font(.subheadline)
        }
    }
}

// 토탈 골드 & 차트 블록
struct GoldsummaryChartCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("현재 내 골드")
                .font(.headline)
                .foregroundStyle(Color.myWhite)
            
            Text("1,000,000")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            HStack {
                Text("이전 주 수요일 기준")
                    .foregroundColor(.gray)
                Text("-12%")
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.5))
                    path.addCurve(
                        to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.6),
                        control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.2),
                        control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.8)
                    )
                }
                .stroke(Color.white, lineWidth: 2)
            }
            .frame(height: 150)
            
            HStack {
                ForEach(["수", "목", "금", "토", "일", "월", "화"], id: \.self) { period in
                    Text(period)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// 타이머 블록
struct ResetTimerCard: View {
    @State private var timeRemaining: TimeInterval = 7 * 24 * 60 * 60
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            Text("주간 리셋 타이머")
                .foregroundStyle(Color.myWhite)
                .font(.headline)
            
            HStack(alignment: .bottom ,spacing: 16) {
                TimerCard(value: Int(timeRemaining) / 86400, label: "Day")
                Text(":")
                    .croneTextModifier()
                TimerCard(value: (Int(timeRemaining) % 86400) / 3600, label: "Hour")
                Text(":")
                    .croneTextModifier()
                TimerCard(value: (Int(timeRemaining) % 3600) / 60, label: "Min")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
        .onAppear {
            startTimer()
        }
    }
    
    func startTimer() {
        // 매 초마다 반복
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // 타이머가 0이 되면 다시 일주일로 리셋
                timeRemaining = 7 * 24 * 60 * 60
            }
        }
    }}

struct TimerCard: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
            
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.myWhite)
                .frame(width:60, height:60)
                .background(Color.timer)
                .cornerRadius(8)
        }
    }
}

// 내 캐릭터들 남은 레이드 횟수 블록
struct RaidProgress: Identifiable {
    var id = UUID()
    var name: String
    var job: String
    var level: String
}

struct RaidProgressCard: View {
    let dummyData: [RaidProgress] = [
        RaidProgress(name: "홀나로운축오생활", job: "홀리나이트", level: "1680"),
        RaidProgress(name: "홀나로운심연생활", job: "홀리나이트", level: "1660"),
        RaidProgress(name: "우산에서붓이등장", job: "기상술사", level: "1640"),
    ]
    
    var body: some View {
        VStack {
            Text("내 캐릭 현황")
                .font(.headline)
                .foregroundStyle(Color.myWhite)
            
            ForEach(dummyData) { char in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(char.name)
                            .font(.headline)
                        HStack {
                            Text(char.level)
                            Text(char.job)
                        }
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                    }
                    .padding(5)
                    Spacer()
                    Text("0 / 3")
                }
                .foregroundStyle(Color.myWhite)
            }
        }
    }
}

#Preview {
    MainView()
}
