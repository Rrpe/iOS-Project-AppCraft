//
//  MyPageAlarmView.swift
//  Grruung
//
//  Created by subin on 6/4/25.
//

import SwiftUI

struct MyPageAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var permissionManager = AlarmPermissionManager()
    
    @AppStorage("generalNotification") private var generalNotification = false
    @AppStorage("gameNotification") private var gameNotification = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 알림이 비활성화되어 있을 경우에만 표시
                if !permissionManager.isNotificationAuthorized {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("알림 비활성화")
                                .font(.headline)
                                .bold()
                        }
                        
                        Text("알림 권한이 꺼져 있어도 앱 내 설정은 저장됩니다.\n푸시 알림을 받으려면 시스템 설정에서 알림을 켜주세요.")
                            .font(.subheadline)
                        
                        Button(action: {
                            permissionManager.openSystemSettings()
                        }) {
                            HStack {
                                Text("시스템 설정 열기")
                            }
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(colors: [Color(hex: "#FFB778"), Color(hex: "FFA04D")], startPoint: .leading, endPoint: .trailing)))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
//                    .background(Color.orange.opacity(0.2))
//                    .cornerRadius(12)
                }
                
                // 알림 설명
                VStack(alignment: .leading, spacing: 8) {
                    Text("알림 설정")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Grruung에서 보내는 푸시 알림을 설정합니다.")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                
                // 알림 스위치 (항상 활성화)
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("푸시 알림", isOn: $generalNotification)
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("게임 내 알림", isOn: $gameNotification)
                            .font(.headline)
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(GRColor.subColorOne) // 갈색으로 변경
                        .font(.system(size: 18, weight: .semibold))
                }
            }

            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
        .onAppear {
            permissionManager.checkNotificationPermission()
        }
        .refreshable {
            await permissionManager.refreshPermissionStatus()
        }
    }
}

// MARK: - Preview
#Preview {
    MyPageAlarmView()
}
