//
//  ContentView.swift
//  FixMBTI
//
//  Created by KimJunsoo on 2/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [MBTIProfile]
    @Query private var missions: [Mission]
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Mission]
    
    @State private var selectedTab = 0  // 현재 선택된 탭을 추적하는 변수
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MissionView()
                .tabItem {
                    Image(selectedTab == 0 ? "HomeOn" : "HomeOff")
                }
                .tag(0)
                
            ListView()
                .tabItem {
                    Image(selectedTab == 1 ? "ListOn" : "ListOff")
                }
                .tag(1)
                
            SettingView()
                .tabItem {
                    Image(selectedTab == 2 ? "SettingOn" : "SettingOff")
                }
                .tag(2)
        }
        .onAppear {
            // 알림 예약 호출
            NotificationManager.instance.scheduleMissionNotification(
                profiles: profiles,
                missions: missions,
                modelContext: modelContext
            )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Mission.self, inMemory: true)
}
