//
//  ProfileDetailView.swift
//  Grruung
//
//  Created by subin on 5/29/25.
//

import SwiftUI
import PhotosUI

// MARK: - 모델 정의

struct SettingItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
}

struct SettingSection: Identifiable {
    let id = UUID()
    let items: [SettingItem]
}

// MARK: - 메인 뷰

struct ProfileDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var username = "Quaqqa"
    @State private var newName = ""
    @State private var isShowingNameEditorPopup = false
    
    // 설정 항목 데이터
    let settingSections: [SettingSection] = [
        SettingSection(items: [
            .init(title: "결제내역", iconName: "doc.text"),
            .init(title: "선물함", iconName: "gift")
        ]),
        SettingSection(items: [
            .init(title: "연결된 계정 변경", iconName: "link"),
            .init(title: "연결된 기기 변경", iconName: "arrow.triangle.2.circlepath")
        ])
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // MARK: - 프로필 섹션
                    VStack(spacing: 20) {
                        ZStack(alignment: .bottomTrailing) {
                            PhotosPicker(selection: $selectedItem,
                                         matching: .images,
                                         photoLibrary: .shared()) {
                                Group {
                                    if let profileImage {
                                        profileImage
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    } else {
                                        Image("CatLion")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    }
                                }
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            }
                                         .onChange(of: selectedItem) { newItem in
                                             Task {
                                                 if let data = try? await newItem?.loadTransferable(type: Data.self),
                                                    let uiImage = UIImage(data: data) {
                                                     profileImage = Image(uiImage: uiImage)
                                                 }
                                             }
                                         }
                            
                            Image(systemName: "camera.fill")
                                .foregroundStyle(.white)
                                .padding(6)
                                .background(Circle().fill(Color.orange))
                                .offset(x: 3, y: 3)
                        }
                        .padding(.top, 20)
                        
                        Button {
                            newName = username
                            isShowingNameEditorPopup = true
                        } label: {
                            HStack(spacing: 6) {
                                Text(username)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(.white)
                                
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#FFB778"), Color(hex: "#FFA04D")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding(.horizontal)
                    
                    // MARK: - 설정 섹션
                    VStack(spacing: 30) {
                        ForEach(settingSections) { section in
                            VStack {
                                ForEach(section.items) { item in
                                    
                                    if item.title == "결제내역" {
                                        NavigationLink {
                                            PurchaseHistoryView()
                                        } label: {
                                            SettingRow(icon: item.iconName, text: item.title)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        Button(action: {
                                            // 각 설정 항목별 액션
                                        }) {
                                            SettingRow(icon: item.iconName, text: item.title)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.3)))
                    }
                    
                    // FIXME: - End
                    
                    // 로그아웃 버튼
                    Button(action: {
                        authService.signOut()
                    }) {
                        SettingRow(icon: "rectangle.portrait.and.arrow.right", text: "로그아웃")
                            .foregroundColor(.red)
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.3)))
                    
                    Button {
                        print("계정 삭제")
                    } label: {
                        
                        HStack {
                            Image(systemName: "trash")
                            Text("계정 삭제")
                        }
                        .foregroundColor(.red)
                        .padding(.top)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50) // 하단 Safe Area 여백 추가
            }

            .padding(.bottom, 50)
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
                Text("내 정보 관리")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
        .scrollContentBackground(.hidden)
        .background(
                LinearGradient(
                    colors: [Color(hex: "FFF6EE"), Color(hex: "FDE0CA")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                )
        
        // MARK: - 닉네임 편집 팝업
        if isShowingNameEditorPopup {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button {
                        isShowingNameEditorPopup = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
                .frame(height: 40)
                .overlay(
                    Text("닉네임")
                        .font(.headline)
                )
                
                TextField("닉네임을 입력하세요", text: $newName)
                    .padding()
                    .background(Color(.systemGray6))
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                
                Button {
                    username = newName
                    isShowingNameEditorPopup = false
                } label: {
                    Text("완료")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
            .padding()
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 20)
        }
    }
}


// MARK: - 설정 뷰

struct SettingRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.primary)
            
            Text(text)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview
#Preview {
    ProfileDetailView()
}
