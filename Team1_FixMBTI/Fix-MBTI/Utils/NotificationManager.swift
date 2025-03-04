//
//  NotificationManager.swift
//  Fix-MBTI
//  랜덤 알림 관리 파일
//  Created by KimJunsoo on 2/5/25.
//

import Foundation
import UserNotifications
import SwiftData

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let instance = NotificationManager()
    
    private var storedProfiles: [MBTIProfile] = []
    private var storedMissions: [Mission] = []
    private var storedModelContext: ModelContext?
    
    // 초기화 시 delegate 설정
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // 알림 권한 요청
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
//        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("알림 권한 허용됨 ✅")
            } else {
                print("알림 권한 거부됨 ❌")
            }
        }
    }
    
    // 기존 알림 삭제 (새로운 설정을 반영하기 위함)
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ 기존 알림 모두 삭제 완료")
    }
    
    // 랜덤한 시간 후 미션 알림 예약
    func scheduleMissionNotification(profiles: [MBTIProfile], missions: [Mission], modelContext: ModelContext) {
        
        self.storedProfiles = profiles
        self.storedMissions = missions
        self.storedModelContext = modelContext
        
        removeAllNotifications() // 기존 알림 삭제
        
        let missionCount = UserDefaults.standard.integer(forKey: "missionCount")
        let actualCount = max(1, missionCount) // 최소 1개, 최대 설정값까지
        
        var accumulatedDelay: Double = 0 // 이전 알림의 delay를 누적
        
        for _ in 1...actualCount {
            let content = UNMutableNotificationContent()
            content.title = "새로운 MBTI 미션이 도착했습니다!"
            content.body = "지금 앱을 열어 미션을 확인하세요."
            content.sound = .default
            
            let randomDelay = Double.random(in: 10...30)
//            let randomDelay = Double.random(in: 1080...18000) 
            accumulatedDelay += randomDelay
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: accumulatedDelay, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            
            print("📢 랜덤 미션 알림 예약 완료: \(randomDelay)초 후 도착 예정")
            
        }
        
        checkPendingNotifications()
    }
    
    // 앱이 실행 중일 때 알림을 받을 수 있도록 설정
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // 예약된 알림 확인
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📌 현재 예약된 알림 개수: \(requests.count)")
            for request in requests {
                print("📌 예약된 알림: \(request.identifier), 트리거: \(request.trigger.debugDescription)")
            }
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let profile = storedProfiles.first,
              let modelContext = storedModelContext else {
            completionHandler()
            return
        }
        
        let targetCategories = [profile.currentMBTI.last?.description, profile.targetMBTI.last?.description].compactMap { $0 }
        let availableMissions = storedMissions.filter { targetCategories.contains(String($0.category)) }
        
        if let randomMission = availableMissions.randomElement() {
            let newActiveMission = ActiveMission(mission: randomMission)
            modelContext.insert(newActiveMission)
            print("🎯 알림 수신으로 미션 추가됨: \(randomMission.title)")
        }
        
        completionHandler()
    }
    
}
