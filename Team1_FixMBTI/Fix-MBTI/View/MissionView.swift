//
//  MissionView.swift
//  FixMBTI
//
//  Created by KimJunsoo on 2/4/25.
//

import SwiftUI
import SwiftData

struct MissionView: View {
    @Environment(\.modelContext) private var modelContext
    //    @Query private var missions: [Mission]
    @Query private var profiles: [MBTIProfile]
    @Query(sort: \ActiveMission.timestamp) private var activeMissions: [ActiveMission]
    
    @State private var showAlert = false
    
    // NotificationDelegate 인스턴스 생성
    private let notificationDelegate = NotificationDelegate()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(activeMissions) { activeMission in
                    NavigationLink(destination: MissionDetailView(mission: Mission(title: activeMission.title,
                                                                                   detailText: activeMission.detailText,
                                                                                   category: activeMission.category))) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(activeMission.title)")
                                    .font(.headline)
                                    .foregroundStyle(Color(hex: "222222"))
                                
                                HStack {
                                    Text(activeMission.timestamp.formatted(
                                        .dateTime
                                            .year().month().day()
                                            .hour().minute().second()
                                            .locale(Locale(identifier: "ko_KR"))
                                    ))
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "222222"))
                                    
                                    HStack {
                                        Text(activeMission.category)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color(hex: "FA812F"))  // category만 오렌지색으로
                                        Text("체험")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color(hex: "222222"))  // "체험"은 기존 색상 유지
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        .padding(.top)
                        .cornerRadius(15)
                    }
                }
                .onDelete(perform: deleteMission)
            }
            .onAppear {
                print("🔍 현재 MBTI: \(profiles.first?.currentMBTI ?? "default")")
                print("🔍 목표 MBTI: \(profiles.first?.targetMBTI ?? "default")")
                
                // Delegate 설정 및 콜백 등록
                notificationDelegate.addMissionCallback = addMission
                UNUserNotificationCenter.current().delegate = notificationDelegate
            }
            .listRowSpacing(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("미션")
                        .font(.headline)
                }
            }
            .toolbar {
                Button(action: addMission) {
                    Label("미션 추가", systemImage: "plus")
                }
                
                Button(action: sendTestNotification) {
                    Label("알림 테스트", systemImage: "bell.fill")
                }
            }
        }
        .accentColor(Color(hex: "FA812F"))
    }
    
    private func addMission() {
        guard let profile = profiles.first else { return }
        
        let currentArray = Array(profile.currentMBTI)
        let targetArray = Array(profile.targetMBTI)
        var differentCategories: [String] = []
        
        for i in 0..<4 {
            if currentArray[i] != targetArray[i] {
                differentCategories.append(String(targetArray[i]))
            }
        }
        
        print("🎯 변화해야 할 카테고리들: \(differentCategories)")
        
        let availableMissions = missions.filter { mission in
            differentCategories.contains(mission.category)
        }
        
        if let randomMission = availableMissions.randomElement() {
            // 중복 체크
            if !activeMissions.contains(where: { $0.title == randomMission.title }) {
                let newActiveMission = ActiveMission(mission: randomMission)
                modelContext.insert(newActiveMission)
                print("📝 새 미션 추가됨: \(randomMission.title) (카테고리: \(randomMission.category))")
            }
        }
    }
    
    func deleteMission(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(activeMissions[index])
        }
    }
    
    // 테스트용 알림 즉시 보내기
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "테스트 알림"
        content.body = "이것은 즉시 발송된 테스트 알림입니다."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 5초 후 실행
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("📢 테스트 알림 예약 완료 (5초 후 도착)")
    }
    
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var addMissionCallback: (() -> Void)?
    
    // 알림이 도착했을 때 호출되는 함수
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 알림이 도착하면 바로 미션 추가
        addMissionCallback?()
        
        // 알림도 보여주기
        completionHandler([.banner, .sound, .badge])
    }
}

#Preview {
    MissionView()
}

