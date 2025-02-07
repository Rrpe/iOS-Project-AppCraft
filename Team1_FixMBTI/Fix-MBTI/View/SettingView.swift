//
//  SettingView.swift
//  FixMBTI
//
//  Created by KimJunsoo on 2/4/25.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var missions: [Mission]
    @Query private var profiles: [MBTIProfile]
    
    @State private var isShowingMBTISelection = false
    @State private var isNotificationEnabled = true
    @AppStorage("missionCount") private var missionCount: Int = 1 // 기본값 1개
    
    var body: some View {
        NavigationStack {
            List {
                
                Section(header: Text("내 MBTI").font(.caption).foregroundColor(Color(hex: "444444"))) {
                    HStack {
                        Text(profiles.first?.currentMBTI ?? "미설정")
                            .font(.headline)
                        Spacer()
                    }
                }
                
                Section(header: Text("체험 MBTI").font(.caption).foregroundColor(Color(hex: "444444"))) {
                    HStack {
                        Text(profiles.first?.targetMBTI ?? "미설정")
                            .font(.headline)
                        
                        Spacer()
                    }
                }
                
                Section {
                    Button(action: { isShowingMBTISelection = true }) {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(Color(hex: "FA812F"))
                            Text("MBTI 변경")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: { openMBTITest() }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(Color(hex: "FA812F"))
                            Text("MBTI 검사하러 가기")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 알림 설정 섹션
                Section {
                    Toggle(isOn: $isNotificationEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color(hex: "FA812F"))
                            Text("알림 설정")
                        }
                    }
                    .onChange(of: isNotificationEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.instance.scheduleMissionNotification(
                                profiles: profiles,
                                missions: missions,
                                modelContext: modelContext
                            )
                        } else {
                            NotificationManager.instance.removeAllNotifications()
                        }
                    }
                }
                
                // 🔹 미션 개수 설정
                Section(header: Text("미션 개수 설정").font(.caption).foregroundColor(Color(hex: "444444"))) {
                    Picker("미션 개수", selection: $missionCount) {
                        ForEach(1...5, id: \.self) { count in
                            Text("\(count)개").tag(count)
                        }
                    }
                    .padding(5)
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: missionCount) { oldValue, newValue in
                        NotificationManager.instance.scheduleMissionNotification(
                            profiles: profiles,
                            missions: missions,
                            modelContext: modelContext
                        )
                        print("🔄 미션 개수 변경됨: \(oldValue) → \(newValue)")
                    }
                }
            }
            .padding(.top, 10)
            .navigationTitle("환경 설정")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingMBTISelection) {
                MBTISelectionView()
            }
        }
        
        .listStyle(.grouped)
    }
    
    private func openMBTITest() {
        if let url = URL(string: "https://www.16personalities.com/ko") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingView()
}
