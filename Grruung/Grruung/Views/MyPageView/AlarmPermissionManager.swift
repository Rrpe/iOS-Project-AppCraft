//
//  AlarmPermissionManager.swift
//  Grruung
//
//  Created by subin on 6/4/25.
//

import Foundation
import UserNotifications
import SwiftUI

class AlarmPermissionManager: ObservableObject {
    @Published var isNotificationAuthorized: Bool = false
    @Published var isCheckingPermission: Bool = false

    init() {
        checkNotificationPermission()
    }

    // 권한 상태 비동기 확인
    func checkNotificationPermission() {
        isCheckingPermission = true
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isNotificationAuthorized = settings.authorizationStatus == .authorized
                self?.isCheckingPermission = false
            }
        }
    }

    // 시스템 설정 열기
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    // 권한 요청
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isNotificationAuthorized = granted
                completion?(granted)
            }
        }
    }

    // refreshable에서 사용 가능
    @MainActor
    func refreshPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isNotificationAuthorized = settings.authorizationStatus == .authorized
    }
}
