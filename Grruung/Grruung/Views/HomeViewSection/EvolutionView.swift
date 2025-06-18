//
//  EvolutionView.swift
//  Grruung
//
//  Created by NoelMacMini on 6/4/25.
//

import SwiftUI

struct EvolutionView: View {
    // 전달받은 캐릭터 정보
    let character: GRCharacter
    
    let isUpdateMode: Bool // 업데이트 모드 여부
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var homeViewModel: HomeViewModel
    
    // 진화 상태 관리
    @State private var evolutionStep: EvolutionStep = .preparing
    @State private var statusMessage: String = ""
    @State private var targetPhase: CharacterPhase = .infant // 진화 목표 단계
    
    // 컨트롤러 연결
    @StateObject private var quokkaController = QuokkaController()
    
    // 진화 단계 열거형
    enum EvolutionStep {
        case preparing, downloading, updating, completed, unavailable
    }
    
    // 초기화에서 업데이트 모드 파라미터 추가
    init(character: GRCharacter, homeViewModel: HomeViewModel, isUpdateMode: Bool = false) {
        self.character = character
        self.homeViewModel = homeViewModel
        self.isUpdateMode = isUpdateMode
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 상단 제목
                Text(getScreenTitle())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // 중앙 캐릭터 이미지 영역
                characterImageSection
                
                // 진행률 표시 영역
                progressSection
                
                // 상태 메시지 (QuokkaController 메시지 우선 사용)
                Text(quokkaController.downloadMessage.isEmpty ? statusMessage : quokkaController.downloadMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // 하단 버튼
                bottomButton
            }
            .padding()
            .onAppear {
                setupInitialState()
                quokkaController.setModelContext(modelContext) // SwiftData 컨텍스트 설정
            }
            .navigationTitle(isUpdateMode ? "업데이트" : "진화")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(evolutionStep == .downloading || evolutionStep == .updating) // 진행 상태에서 뒤로 가기 막기
        }
    }
    
    // MARK: - UI 컴포넌트들
    
    private var characterImageSection: some View {
        ZStack {
            // 배경 원
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 200, height: 200)
            
            // 캐릭터 이미지
            // QuokkaController에서 현재 프레임 가져오기
            if let currentFrame = quokkaController.currentFrame {
                Image(uiImage: currentFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            } else {
                // 기본 이미지 (프레임이 없을 때)
                if evolutionStep == .completed {
                    // 완료됐을 때 기본 이미지
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.red)
                } else {
                    Image(systemName: "sparkles").font(.system(size: 60)).foregroundStyle(.yellow)
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 15) {
            if evolutionStep == .downloading || evolutionStep == .updating {
                // 진행률 바 (QuokkaController에서 진행률 가져오기)
                ProgressView(value: quokkaController.downloadProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                
                // 퍼센트 표시
                Text("\(Int(quokkaController.downloadProgress * 100))%")
                    .font(.caption).fontWeight(.medium).foregroundStyle(.blue)
            }
        }
    }
    
    private var bottomButton: some View {
        Group {
            switch evolutionStep {
            case .preparing:
                Button(isUpdateMode ? "업데이트 시작" : "진화 시작") { startProcess() }
                    .buttonStyle(.borderedProminent)
            case .downloading, .updating:
                Button("진행 중...") { }.disabled(true).buttonStyle(.bordered)
            case .completed:
                Button("완료") { dismiss() }.buttonStyle(.borderedProminent)
            case .unavailable:
                Button("확인") { dismiss() }.buttonStyle(.bordered)
            }
        }.font(.body).padding(.horizontal, 40)
    }
    
    // MARK: - 헬퍼 메서드들
    
    private func getScreenTitle() -> String {
        if isUpdateMode { return "데이터 업데이트" }
        
        switch evolutionStep {
        case .preparing: return "진화 준비"
        case .downloading: return "진화 중"
        case .completed: return "진화 완료!"
        default: return "진화"
        }
    }
    
    private func setupInitialState() {
        guard character.species == .quokka else {
            evolutionStep = .unavailable
            statusMessage = "이 캐릭터는 아직 진화를 지원하지 않습니다."
            return
        }
        evolutionStep = .preparing
        
        if isUpdateMode {
            targetPhase = character.status.phase
            statusMessage = "새로운 애니메이션 데이터를 다운로드할 준비가 되었습니다."
        } else {
            // 진화 상태에 따라 목표 단계와 메시지 설정
            switch character.status.evolutionStatus {
            case .toInfant:
                targetPhase = .infant
                statusMessage = "알이 부화할 준비가 되었습니다!"
            case .toChild:
                targetPhase = .child
                statusMessage = "더 큰 모습으로 성장할 준비가 되었습니다!"
            case .toAdolescent:
                targetPhase = .adolescent
                statusMessage = "더 성숙한 모습으로 성장할 준비가 되었습니다!"
            case .toAdult:
                targetPhase = .adult
                statusMessage = "완전히 성장할 준비가 되었습니다!"
            default:
                evolutionStep = .unavailable
                statusMessage = "현재는 진화할 수 없습니다."
            }
        }
    }
    
    private func startProcess() {
        guard character.species == .quokka else { return }
        
        evolutionStep = isUpdateMode ? .updating : .downloading
        statusMessage = isUpdateMode ? "업데이트 시작!" : "진화 시작!"
        
        Task {
            await quokkaController.downloadData(
                for: targetPhase,
                evolutionStatus: character.status.evolutionStatus
            )
            
            await MainActor.run {
                evolutionStep = .completed
                if isUpdateMode {
                    statusMessage = "업데이트 완료!"
                    homeViewModel.completeAnimationUpdate()
                } else {
                    statusMessage = "진화 완료!"
                    homeViewModel.completeEvolution(to: targetPhase)
                }
            }
        }
    }
}

// MARK: - 프리뷰
//
