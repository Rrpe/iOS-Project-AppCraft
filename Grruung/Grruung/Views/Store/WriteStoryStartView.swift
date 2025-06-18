//
//  StoryListView.swift
//  Grruung
//
//  Created by NO SEONGGYEONG on 5/27/25.
//

import SwiftUI

struct WriteStoryStartView: View {
    @StateObject private var charViewModel: CharacterDetailViewModel
    @StateObject private var viewModel = WriteStoryViewModel()
    @StateObject private var writingCountVM = WritingCountViewModel()
    @EnvironmentObject private var authService: AuthService
    @State private var currentViewMode: ViewMode = .create
    @State private var navigateToWriteView = false
    @State private var showNoCountAlert = false
    
    var characterUUID: String
    
    init(characterUUID: String) {
        self.characterUUID = characterUUID
        _charViewModel = StateObject(wrappedValue: CharacterDetailViewModel(characterUUID: characterUUID))
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack {
                VStack(spacing: 16) {
                    if !charViewModel.character.imageName.isEmpty {
                        AsyncImage(url: URL(string:charViewModel.character.imageName)) {
                            image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(10)
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(10)
                        }
                    }
                    Text("들려준 이야기 쓰기 시작하기")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    
                    Text("\(charViewModel.character.name)에게 \(charViewModel.user.userName)님의 이야기를 들려주세요.")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    
                    Spacer()
                }
                .padding()
            }
            
            // 하단 플로팅 버튼
            VStack {
                Spacer()
                Button {
                    // 항상 이용 가능
                    navigateToWriteView = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue) // 항상 파란색 (이용 가능)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.bottom, 16)
            }
            .navigationDestination(isPresented: $navigateToWriteView) {
                WriteStoryView(currentMode: currentViewMode, characterUUID: characterUUID)
                    .environmentObject(authService)
            }
        }
        .navigationTitle("이야기 들려주기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("오늘 남은 보상: \(writingCountVM.remainingRewards())/5")
                    .font(.subheadline)
                    .foregroundStyle(writingCountVM.remainingRewards() > 0 ? .green : .gray)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            // 화면이 나타날 때마다 글쓰기 횟수 새로 로드
            writingCountVM.initialize(with: authService)
        }
        .alert("글쓰기 횟수 부족", isPresented: $showNoCountAlert) {
            Button("확인", role: .cancel) { }
            Button("충전하기") {
                // 여기에 충전 화면으로 이동하는 코드 추가
            }
        } message: {
            Text("오늘 사용 가능한 글쓰기 횟수를 모두 사용했습니다.\n추가 글쓰기를 원하시면 충전이 필요합니다.")
        }
    }
}

#Preview {
    NavigationStack {
        WriteStoryStartView(characterUUID: "CF6NXxcH5HgGjzVE0nVE")//, userId: "uCMGt4DjgiPPpyd2p9Di")
            .environmentObject(AuthService())
    }
}
