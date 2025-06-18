//
//  CheonTestView.swift
//  Grruung
//
//  Created by subin on 5/28/25.
//

import SwiftUI

struct MyPageView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 사용자 정보
                    ProfileSection()
                    
                    // 서비스 섹션
                    SeviceGrid()
                    
                    // 설정 섹션
                    SettingsSection()
                }
                .padding()
            }
            .background(
                LinearGradient(colors: [Color(hex: "FFF6EE"), Color(hex: "FDE0CA")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }
}

struct ProfileSection: View {
    var body: some View {
        NavigationLink {
            ProfileDetailView()
        } label: {
            HStack(spacing: 30) {
                Image("CatLion")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("냥냥이")
                        .font(.title2)
                        .bold()
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 서비스 섹션

struct SeviceItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
}

struct SeviceGrid: View {
    let items: [SeviceItem] = [
        .init(title: "상점", iconName: "storefront.fill"),
        .init(title: "애완동물", iconName: "pawprint.fill"),
        .init(title: "동산", iconName: "leaf.fill"),
        .init(title: "들려준 이야기", iconName: "message.fill"),
        .init(title: "이벤트", iconName: "gift.fill"),
    ]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("서비스")
                .font(.headline)
                .bold()
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(items) { item in
                    NavigationLink {
                        SeviceDestination(for: item)
                    } label: {
                        VStack {
                            Image(systemName: item.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(GRColor.mainColor6_2)
                                .padding()
                            
                            Text(item.title)
                                .font(.caption)
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
            .padding()
            //            .background(
            //                RoundedRectangle(cornerRadius: 12)
            //                    .stroke(Color.gray.opacity(0.4), lineWidth: 1))
        }
    }
}
// MARK: - 액션 처리 메서드

@ViewBuilder
private func SeviceDestination(for item: SeviceItem) -> some View {
    switch item.title {
    case "상점":
        StoreView()
    case "애완동물":
        HomeView()
    case "동산":
        CharDexView()
    default:
        Text("준비중 입니다.")
    }
}

// 평가 및 리뷰 전용 뷰
struct AppStoreReviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 배경
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            // 앱스토어로 이동
            Text("앱스토어로 이동합니다...")
                .onAppear {
                    // 앱스토어로 이동
                    openAppStoreDirectly()
                    
                    // 0.5초 후 이전 화면으로 돌아가기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(name: Notification.Name("ReturnToMyPageView"), object: nil)
                    }
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ReturnToMyPageView"))) { _ in
            // 알림 수신 시 MyPageView로 돌아가기
            dismiss()
        }
    }
    
    // 앱스토어 이동 함수 복사
    private func openAppStoreDirectly() {
        let appStoreID = "YOUR_APP_ID" // 실제 앱 ID로 변경
        let appStoreURL = "https://rrpe.github.io/Grruung-webpf/"
        
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - 설정 섹션

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
}

struct SettingsSection: View {
    let settings: [SettingsItem] = [
        .init(title: "알림", iconName: "bell"),
        .init(title: "공지사항", iconName: "megaphone"),
        .init(title: "고객센터", iconName: "headset"),
        .init(title: "평가 및 리뷰", iconName: "hand.thumbsup"),
        .init(title: "약관 및 정책", iconName: "info.circle")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("설정")
                .font(.headline)
                .bold()
                .padding(.horizontal)
                .padding(.top)
            
            VStack {
                ForEach(settings) { item in
                    NavigationLink {
                        settingsDestination(for: item)
                    } label: {
                        HStack {
                            Image(systemName: item.iconName)
                                .foregroundStyle(.black)
                                .frame(width: 24)
                            
                            Text(item.title)
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding()
                    }
                }
            }
            //            .background(
            //                RoundedRectangle(cornerRadius: 12)
            //                    .stroke(Color.gray.opacity(0.4), lineWidth: 1))
        }
    }
}

// 앱스토어 이동
private func openAppStoreDirectly() {
    let appStoreID = "YOUR_APP_ID" // 실제 앱 ID로 변경
    let appStoreURL = "https://apps.apple.com/app/id\(appStoreID)?action=write-review"
    
    if let url = URL(string: appStoreURL) {
        UIApplication.shared.open(url)
    }
}

// MARK: - 액션 처리 메서드

@ViewBuilder
private func settingsDestination(for item: SettingsItem) -> some View {
    switch item.title {
    case "알림":
        MyPageAlarmView()
    case "공지사항":
        NoticeView()
    case "고객센터":
        CustomerCenterView()
    case "평가 및 리뷰":
        AppStoreReviewView()
    case "약관 및 정책":
        TermsPolicyView()
    default:
        Text("준비 중")
    }
}

// MARK: - Preview
#Preview {
    MyPageView()
}

