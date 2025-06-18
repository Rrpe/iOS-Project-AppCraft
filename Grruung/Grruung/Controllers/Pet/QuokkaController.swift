//
//  QuokkaController.swift
//  Grruung
//
//  Created by NoelMacMini on 6/2/25.
//

import SwiftUI
import SwiftData
import FirebaseStorage

// 애니메이션 진행 상태 정보를 담을 구조체 정의
struct AnimationProgress {
    let currentIndex: Int // 현재 프레임 번호
    let totalFrames: Int  // 전체 프레임 수
    
    // 진행률(%)은 필요할 때마다 계산해서 사용
    var percentage: Double {
        return totalFrames > 0 ? Double(currentIndex) / Double(totalFrames) : 0
    }
}

// 간단한 쿼카 애니메이션 컨트롤러
@MainActor
class QuokkaController: ObservableObject {
    
    // MARK: - Published 프로퍼티들 (UI 업데이트용)
    @Published var currentFrame: UIImage? = nil         // 현재 표시할 프레임
    @Published var isAnimating: Bool = false            // 애니메이션 재생 중인지
    @Published var currentFrameIndex: Int = 0           // 현재 프레임 번호
    
    // 다운로드 관련
    @Published var isDownloading: Bool = false          // 다운로드 중인지
    @Published var downloadProgress: Double = 0.0       // 다운로드 진행률 (0.0 ~ 1.0)
    @Published var downloadMessage: String = ""         // 상태 메시지
    
    // MARK: - 비공개 프로퍼티들
    private var animationFrames: [UIImage] = []         // 로드된 애니메이션 프레임들
    private var animationTimer: Timer?                  // 애니메이션 타이머
    private var isReversing: Bool = false               // 역순 재생 중인지
    
    private let storage = Storage.storage()             // Firebase Storage
    private var modelContext: ModelContext?             // SwiftData 컨텍스트
    private let frameRate: Double = 24.0                // 초당 프레임 수
    
    // MARK: - 애니메이션 재생 로직 관련 프로퍼티
    enum PlayMode { case once, pingPong }
    private var currentPlayMode: PlayMode = .pingPong
    private var onComplete: (() -> Void)? = nil
    
    private var onProgressUpdate: ((AnimationProgress) -> Void)? = nil // 진행률 업데이트를 위한 콜백 핸들러 타입을 AnimationProgress로 변경
    
    // MARK: - 고정 설정 (quokka만 처리)
    private let characterType = "quokka"
    
    // MARK: - 애니메이션 타입별 프레임 수
    private let frameCountMap: [CharacterPhase: [String: Int]] = [
        .infant: [
            "normal": 122,
            "sleeping": 1,  // 임시 값
            "eating": 307,
            "sleep1Start": 204,
            "sleep2Pingpong": 60,
            "sleep3mouth": 54,
            "sleep4WakeUp": 173
        ],
        .child: [
            "normal": 64,
            "sleeping": 1,  // 임시 값
            "eating": 1,     // 임시 값
        ],
        // .adolescent, .adult, .elder 등 다른 단계도 이곳에 추가 가능
        .adolescent: [
            "normal": 182,
            "eating": 1,
            "sleeping": 1
        ],
        .adult: [
            "normal": 178,
            "eating": 1,
            "sleeping": 1
        ],
        .elder: [
            "normal": 1, // 추후 추가
            "eating": 1,
            "sleeping": 1
        ]
    ]
    
    // 단계별 애니메이션 타입 매핑
    private func getAnimationTypesForPhase(_ phase: CharacterPhase) -> [String] {
        switch phase {
        case .egg:
            return ["normal"] // egg는 Bundle에 있으니 실제로는 사용 안함
        case .infant:
            return ["normal", "sleeping", "eating", "sleep1Start", "sleep2Pingpong", "sleep3mouth", "sleep4WakeUp"]
        case .child:
            return ["normal"]
        case .adolescent, .adult, .elder:
            return ["normal", "sleeping", "eating"] // 기본 애니메이션만
        }
    }
    
    // MARK: - SwiftData 컨텍스트 설정
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("✅ QuokkaController: SwiftData 컨텍스트 설정 완료")
    }
    
    // MARK: - 첫 번째 프레임만 로드 (기본 표시용)
    func loadFirstFrame(phase: CharacterPhase, animationType: String = "normal") {
        // egg 단계는 Bundle에서 로드
        if phase == .egg {
            currentFrame = UIImage(named: "egg_normal_1")
            return
        }
        
        // 다른 단계는 SwiftData에서 첫 번째 프레임만 로드
        loadSingleFrameFromSwiftData(phase: phase, animationType: animationType, frameIndex: 1)
    }
    
    // MARK: - SwiftData에서 특정 프레임 하나만 로드
    private func loadSingleFrameFromSwiftData(phase: CharacterPhase, animationType: String, frameIndex: Int) {
        guard let context = modelContext else {
            print("❌ SwiftData 컨텍스트가 없음")
            return
        }
        
        let phaseString = phase.toEnglishString()
        let localCharacterType = self.characterType
        
        // 특정 프레임 하나만 조회
        let descriptor = FetchDescriptor<GRAnimationMetadata>(
            predicate: #Predicate { metadata in
                metadata.characterType == localCharacterType &&
                metadata.phase == phaseString &&
                metadata.animationType == animationType &&
                metadata.frameIndex == frameIndex
            }
        )
        
        do {
            let results = try context.fetch(descriptor)
            if let metadata = results.first, let image = loadImageFromPath(metadata.filePath) {
                currentFrame = image
                currentFrameIndex = frameIndex - 1 // 0부터 시작하도록
                print("✅ 첫 번째 프레임 로드 성공: \(metadata.filePath)")
            } else {
                print("❌ 메타데이터를 찾을 수 없음: \(phaseString)/\(animationType)/\(frameIndex)")
            }
        } catch {
            print("❌ SwiftData 조회 실패: \(error)")
        }
    }
    
    // MARK: - 파일 경로에서 이미지 로드
    private func loadImageFromPath(_ filePath: String) -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageURL = documentsPath.appendingPathComponent(filePath)
        
        // 파일 존재 확인
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            print("❌ 파일이 존재하지 않음: \(imageURL.path)")
            return nil
        }
        
        // 이미지 데이터 로드
        guard let imageData = try? Data(contentsOf: imageURL),
              let image = UIImage(data: imageData) else {
            print("❌ 이미지 로드 실패: \(filePath)")
            return nil
        }
        
        return image
    }
    
    // 전체 애니메이션 프레임 로드 (노멀 상태)
    func loadAllAnimationFrames(phase: CharacterPhase, animationType: String) {
        guard let context = modelContext else {
            print("❌ SwiftData 컨텍스트가 없음")
            return
        }
        
        let phaseString = phase.toEnglishString()
        
        // 모든 프레임 조회 (frameIndex로 정렬)
        let descriptor = FetchDescriptor<GRAnimationMetadata>(
            predicate: #Predicate { metadata in
                metadata.characterType == "quokka" &&
                metadata.phase == phaseString &&
                metadata.animationType == animationType
            },
            sortBy: [SortDescriptor(\.frameIndex)]
        )
        
        do {
            let metadataList = try context.fetch(descriptor)
            print("📥 \(metadataList.count)개 프레임 메타데이터 발견 (\(animationType))")
            
            // 프레임들을 순서대로 로드
            var loadedFrames: [UIImage] = []
            for metadata in metadataList {
                if let image = loadImageFromPath(metadata.filePath) {
                    loadedFrames.append(image)
                }
            }
            
            animationFrames = loadedFrames
            
            if !animationFrames.isEmpty {
                print("✅ \(animationFrames.count)개 애니메이션 프레임 로드 완료")
            }
            
        } catch {
            print("❌ 애니메이션 프레임 로드 실패: \(error)")
        }
    }
    
    /// 기존 메타데이터에서 프레임들을 로드합니다
    private func loadExistingFramesFromMetadata(_ metadataList: [GRAnimationMetadata]) async {
        await MainActor.run {
            downloadMessage = "기존 데이터 로드 중..."
            downloadProgress = 0.2
        }
        
        // 메타데이터를 프레임 인덱스 순으로 정렬
        let sortedMetadata = metadataList.sorted { $0.frameIndex < $1.frameIndex }
        var loadedFrames: [UIImage] = []
        
        for (index, metadata) in sortedMetadata.enumerated() {
            // Documents 폴더에서 이미지 로드
            if let image = loadImageFromDocuments(fileName: URL(fileURLWithPath: metadata.filePath).lastPathComponent) {
                loadedFrames.append(image)
            } else {
                print("⚠️ 프레임 \(metadata.frameIndex) 로드 실패: \(metadata.filePath)")
            }
            
            // 진행률 업데이트 (20% ~ 80%)
            let progress = 0.2 + (Double(index + 1) / Double(sortedMetadata.count)) * 0.6
            await MainActor.run {
                downloadProgress = progress
                downloadMessage = "기존 데이터 로드 중... (\(index + 1)/\(sortedMetadata.count))"
            }
        }
        
        // 로드된 프레임들을 설정
        await MainActor.run {
            self.animationFrames = loadedFrames
            
            // 첫 번째 프레임을 현재 프레임으로 설정
            if !loadedFrames.isEmpty {
                self.currentFrame = loadedFrames[0]
            }
            
            downloadProgress = 0.9
            downloadMessage = "데이터 설정 완료"
        }
        
        print("✅ 기존 메타데이터에서 \(loadedFrames.count)개 프레임 로드 완료")
    }

    /// Documents 폴더에서 이미지를 로드합니다
    private func loadImageFromDocuments(fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return nil
        }
        
        return image
    }
    
    // MARK: - 다운로드 상태 확인
    // 다운로드 여부 확인
//    func isPhaseDataDownloaded(phase: CharacterPhase) -> Bool {
//        guard let context = modelContext, phase != .egg else {
//            return phase == .egg // egg는 Bundle에 있으므로 항상 true
//        }
//        
//        let phaseString = phase.toEnglishString()
//        let animationTypes = getAnimationTypesForPhase(phase)
//        
//        // 모든 애니메이션 타입이 완전히 다운로드되었는지 확인
//        for animationType in animationTypes {
//            let expectedFrameCount = frameCountMap[animationType] ?? 0
//            
//            let descriptor = FetchDescriptor<GRAnimationMetadata>(
//                predicate: #Predicate { metadata in
//                    metadata.characterType == "quokka" &&
//                    metadata.phase == phaseString &&
//                    metadata.animationType == animationType
//                }
//            )
//            
//            do {
//                let results = try context.fetch(descriptor)
//                if results.count < expectedFrameCount {
//                    print("❌ \(animationType) 다운로드 미완료: \(results.count)/\(expectedFrameCount)")
//                    return false
//                }
//            } catch {
//                print("❌ 다운로드 상태 확인 실패: \(error)")
//                return false
//            }
//        }
//        
//        print("✅ \(phaseString) 단계 모든 데이터 다운로드 완료")
//        return true
//    }
    
    // MARK: - 데이터 완전성 확인
    /// [HomeViewModel] checkAnimationDataCompleteness 메서드에 사용
    func isPhaseDataComplete(phase: CharacterPhase, evolutionStatus: EvolutionStatus) -> Bool {
        guard phase != .egg else { return true }
        
        // 진화 상태에 따라 필요한 애니메이션 타입 결정
        let requiredAnimationTypes = getRequiredAnimationTypes(phase: phase, evolutionStatus: evolutionStatus)
        
        // 각 애니메이션 타입의 완전성 확인
        for animationType in requiredAnimationTypes {
            if !isAnimationTypeComplete(phase: phase, animationType: animationType) {
                print("❌ 미완료 애니메이션: \(phase.rawValue) - \(animationType)")
                return false
            }
        }
        
        print("✅ \(phase.rawValue) 단계 모든 데이터 다운로드 완료 (상태: \(evolutionStatus.rawValue))")
        return true
    }
    
    // 진화 상태에 따른 필요 애니메이션 타입 반환
    /// [QuokkaController] isPhaseDataComplete 메서드에 사용
    private func getRequiredAnimationTypes(
        phase: CharacterPhase,
        evolutionStatus: EvolutionStatus
    ) -> [String] {
        // 기본 애니메이션들
        var required = ["normal", "sleeping", "eating"]
        
        // infant 단계에서 수면 애니메이션 추가
        if phase == .infant {
            required.append(contentsOf: [
                "sleep1Start",
                "sleep2Pingpong",
                "sleep3mouth",
                "sleep4WakeUp"
            ])
        }
        
        return required
    }
    
    // 특정 애니메이션 타입의 완전성 확인
    /// [QuokkaController] isPhaseDataComplete 메서드에 사용
    private func isAnimationTypeComplete(phase: CharacterPhase, animationType: String) -> Bool {
        guard let context = modelContext else { return false }
        
        let expectedFrameCount = frameCountMap[phase]?[animationType] ?? 0
        if expectedFrameCount == 0 { return true }
        
        let phaseString = phase.toEnglishString()
        let localCharacterType = self.characterType
        
        let descriptor = FetchDescriptor<GRAnimationMetadata>(
            predicate: #Predicate { metadata in
                metadata.characterType == localCharacterType &&
                metadata.phase == phaseString &&
                metadata.animationType == animationType
            }
        )
        
        do {
            let results = try context.fetch(descriptor)
            return results.count >= expectedFrameCount
        } catch {
            print("❌ 완전성 확인 실패: \(error)")
            return false
        }
    }
    
    // 메타데이터에 해당하는 실제 파일들이 존재하는지 확인
    private func checkIfFilesExist(_ metadataList: [GRAnimationMetadata]) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // 처음 10개 파일만 샘플 체크 (성능상 이유)
        let sampleMetadata = Array(metadataList.prefix(10))
        
        for metadata in sampleMetadata {
            let fileURL = documentsDirectory.appendingPathComponent(metadata.filePath)
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                print("❌ 샘플 파일 없음: \(metadata.filePath)")
                return false
            }
        }
        
        print("✅ 샘플 파일들 존재 확인됨")
        return true
    }
    
    // MARK: - 정리 함수
    func cleanup() {
        stopAnimation()
        animationFrames.removeAll()
        currentFrame = nil
        print("🧹 QuokkaController 정리 완료")
    }
}

// MARK: - 다운로드 기능
extension QuokkaController {
    // MARK: - 데이터 다운로드 (일반화된 버전)
    func downloadData(for phase: CharacterPhase, evolutionStatus: EvolutionStatus) async {
        guard phase != .egg, let context = modelContext, let phaseAnimations = frameCountMap[phase] else {
            await updateDownloadState(message: "다운로드할 데이터가 없거나, 컨텍스트가 설정되지 않았습니다.")
            return
        }
        
        let phaseString = phase.toEnglishString()
        
        if isPhaseDataComplete(phase: phase, evolutionStatus: evolutionStatus) {
            await updateDownloadState(progress: 1.0, message: "이미 모든 데이터가 존재합니다.")
            print("✅ \(phaseString) 데이터는 이미 완전합니다. 다운로드를 건너뜁니다.")
            return
        }
        
        // 다운로드 전 기존 데이터 정리
        await clearPhaseMetadata(phase: phase)
        
        await updateDownloadState(isDownloading: true, progress: 0.0, message: "성장에 필요한 데이터를 받아오는 중...")
        
        let totalFramesToDownload = phaseAnimations.values.reduce(0, +)
        print("📥 \(phaseString) 데이터 다운로드 시작 - 총 \(totalFramesToDownload)개 프레임")
        
        await withTaskGroup(of: Bool.self) { taskGroup in
            var completedFrames = 0
            for (animationType, frameCount) in phaseAnimations {
                for frameIndex in 1...frameCount {
                    taskGroup.addTask { [weak self] in
                        guard let self = self else { return false }
                        return await self.downloadSingleFrame(phase: phase, animationType: animationType, frameIndex: frameIndex, context: context)
                    }
                }
            }
            
            for await success in taskGroup {
                if success { completedFrames += 1 }
                let progress = Double(completedFrames) / Double(totalFramesToDownload)
                await updateDownloadState(progress: progress, message: "곧 성장이 완료됩니다...")
            }
        }
        
        await updateDownloadState(isDownloading: false, progress: 1.0, message: "성장이 완료되었습니다!")
        print("✅ \(phaseString) 데이터 병렬 다운로드 완료")
    }
    // MARK: - 개별 프레임 다운로드
    private func downloadSingleFrame(phase: CharacterPhase, animationType: String, frameIndex: Int, context: ModelContext) async -> Bool {
        let phaseString = phase.toEnglishString()
        let fileName = "quokka_\(phaseString)_\(animationType)_\(frameIndex).png"
        let firebasePath = "animations/quokka/\(phaseString)/\(animationType)/\(fileName)"
        let storageRef = storage.reference().child(firebasePath)
        
        do {
            // Firebase에서 데이터 다운로드
            let data = try await storageRef.data(maxSize: 5 * 1024 * 1024) // 5MB 제한
            
            // 로컬 파일 경로 설정
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let localPath = "animations/quokka/\(phaseString)/\(animationType)/\(fileName)"
            let fullURL = documentsPath.appendingPathComponent(localPath)
            
            // 디렉토리 생성
            try FileManager.default.createDirectory(at: fullURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            // 파일 저장
            try data.write(to: fullURL)
            
            // SwiftData 저장을 별도 Task로 처리 (동시성 문제 방지)
            await MainActor.run {
                let metadata = GRAnimationMetadata(
                    characterType: self.characterType,
                    phase: phase,
                    animationType: animationType,
                    frameIndex: frameIndex,
                    filePath: localPath,
                    fileSize: data.count,
                    totalFramesInAnimation: frameCountMap[phase]?[animationType] ?? 0
                )
                
                context.insert(metadata)
                try? context.save()
            }
            
            print("✅ 프레임 다운로드 성공: \(fileName)")
            return true
            
        } catch {
            print("❌ 프레임 다운로드 실패: \(fileName) - \(error)")
            return false
        }
    }

    // MARK: - 다운로드 상태 업데이트 (메인 스레드에서 실행)
    @MainActor
    private func updateDownloadState(
        isDownloading: Bool? = nil,
        progress: Double? = nil,
        message: String? = nil
    ) {
        if let isDownloading = isDownloading {
            self.isDownloading = isDownloading
        }
        if let progress = progress {
            self.downloadProgress = progress
        }
        if let message = message {
            self.downloadMessage = message
        }
    }
    
    // MARK: - 진화 완료 처리
//    @MainActor
//    func completeEvolution() {
//        // 진화 완료 후 첫 번째 프레임 로드
//        loadFirstFrame(phase: .infant, animationType: "normal")
//        
//        // 상태 메시지 업데이트
//        downloadMessage = "진화가 완료되었습니다!"
//        downloadProgress = 1.0
//        isDownloading = false
//        
//        print("🎉 진화 완료 - Infant 단계로 전환")
//    }
    
    
    // MARK: - 애니메이션 재생
    
    /// 애니메이션을 재생하는 메인 함수
    /// - Parameters:
    ///   - type: 재생할 애니메이션 종류 (e.g., "normal", "sleep1Start")
    ///   - phase: 캐릭터 성장 단계
    ///   - mode: 재생 방식 (.once 또는 .pingPong)
    ///   - progressUpdate: 프레임 진행 상태
    ///   - completion: .once 모드에서 재생이 끝났을 때 호출될 클로저
    func playAnimation(type: String, phase: CharacterPhase, mode: PlayMode, progressUpdate: ((AnimationProgress) -> Void)? = nil, completion: (() -> Void)? = nil) {
        print("🎬 요청: \(phase.rawValue) - \(type), 모드: \(mode)")
        stopAnimation() // 기존 애니메이션 중지
        
        self.currentPlayMode = mode
        self.onComplete = completion
        self.onProgressUpdate = progressUpdate
        
        // 프레임 로드
        loadAllAnimationFrames(phase: phase, animationType: type)
        
        // 프레임이 있으면 애니메이션 시작
        if !animationFrames.isEmpty {
            currentFrameIndex = 0
            isReversing = false
            currentFrame = animationFrames[0]
            startAnimationTimer()
        } else {
            print("⚠️ \(phase.rawValue) - \(type) 애니메이션 프레임이 없어 재생할 수 없습니다.")
        }
    }
    
    // 타이머 시작
    private func startAnimationTimer() {
        guard !isAnimating else { return }
        isAnimating = true
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / frameRate, repeats: true) { [weak self] _ in
            self?.updateFrame()
        }
        print("▶️ 애니메이션 타이머 시작")
    }
    
    // 애니메이션 정지
    func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        isAnimating = false
        isReversing = false
        onComplete = nil // 완료 핸들러 초기화
        onProgressUpdate = nil // 진행률 핸들러 초기화
        print("⏹️ 애니메이션 정지")
    }
    
    // 프레임 업데이트 (재생 모드에 따라 분기)
    private func updateFrame() {
        guard !animationFrames.isEmpty else {
            stopAnimation()
            return
        }
        
        switch currentPlayMode {
        case .pingPong:
            updatePingPongFrame()
        case .once:
            updateOnceFrame()
        }
        
        // 현재 프레임 이미지 업데이트
        if currentFrameIndex < animationFrames.count {
            currentFrame = animationFrames[currentFrameIndex]
        }
    }
    
    // .once 모드 프레임 업데이트
    private func updateOnceFrame() {
        // AnimationProgress 구조체를 생성하여 콜백으로 전달
        let progress = AnimationProgress(currentIndex: currentFrameIndex, totalFrames: animationFrames.count)
        onProgressUpdate?(progress)
        
        currentFrameIndex += 1
        
        // 마지막 프레임에 도달하면 애니메이션 중지 및 완료 핸들러 호출
        if currentFrameIndex >= animationFrames.count {
            // 완료 직전에 마지막 상태를 전달 (currentIndex가 totalFrames와 같아짐)
            let finalProgress = AnimationProgress(currentIndex: animationFrames.count, totalFrames: animationFrames.count)
            onProgressUpdate?(finalProgress)
            
            let completionHandler = onComplete
            stopAnimation()
            completionHandler?()
            print("✅ 'once' 애니메이션 완료")
        }
    }
    
    // .pingPong 모드 프레임 업데이트
    private func updatePingPongFrame() {
        if isReversing {
            // 역순 재생 중
            currentFrameIndex -= 1
            if currentFrameIndex <= 0 {
                currentFrameIndex = 0
                isReversing = false
                print("🔄 정순 재생으로 전환")
            }
        } else {
            // 정순 재생 중
            currentFrameIndex += 1
            if currentFrameIndex >= animationFrames.count - 1 {
                currentFrameIndex = animationFrames.count - 1
                isReversing = true
                print("🔄 역순 재생으로 전환")
            }
        }
        
        // 디버깅용 로그 (매 30프레임마다)
        if currentFrameIndex % 30 == 0 {
            print("🎬 현재 프레임: \(currentFrameIndex + 1)/\(animationFrames.count) (\(isReversing ? "역순" : "정순"))")
        }
    }
    
    // 핑퐁 애니메이션 시작
    func startPingPongAnimation() {
        guard !animationFrames.isEmpty, !isAnimating else {
            print("❌ 애니메이션 시작 불가: 프레임(\(animationFrames.count)), 재생중(\(isAnimating))")
            return
        }
        
        isAnimating = true
        isReversing = false
        currentFrameIndex = 0
        
        print("🎬 핑퐁 애니메이션 시작 - \(animationFrames.count)개 프레임")
        
        // 타이머 시작 (24fps = 약 0.042초 간격)
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / frameRate, repeats: true) { [weak self] _ in
            self?.updatePingPongFrame()
        }
    }
    
    // 애니메이션 토글 (재생/정지)
    func toggleAnimation() {
        if isAnimating {
            stopAnimation()
        } else {
            startPingPongAnimation()
        }
    }
    
    // MARK: - 메타데이터 관리 메서드 (삭제 구현)
    /// 모든 애니메이션 메타데이터를 삭제합니다 (디버그용)
    func clearAllMetadata() {
        guard let modelContext = modelContext else {
            print("❌ SwiftData 컨텍스트가 설정되지 않음")
            return
        }
        
        do {
            // 모든 메타데이터 조회
            let fetchDescriptor = FetchDescriptor<GRAnimationMetadata>()
            let allMetadata = try modelContext.fetch(fetchDescriptor)
            
            print("🗑️ 총 \(allMetadata.count)개 메타데이터 삭제 시작")
            
            // 모든 메타데이터 삭제
            for metadata in allMetadata {
                modelContext.delete(metadata)
            }
            
            // 변경사항 저장
            try modelContext.save()
            
            print("✅ 모든 메타데이터 삭제 완료")
            
        } catch {
            print("❌ 메타데이터 삭제 실패: \(error)")
        }
    }
    
    // 단계별 메타데이터 삭제
    private func clearPhaseMetadata(phase: CharacterPhase) async {
        guard let context = modelContext else { return }
        let phaseString = phase.toEnglishString()
        let localCharacterType = self.characterType
        print("🗑️ \(phaseString) 단계의 기존 메타데이터 정리")
        
        try? context.delete(model: GRAnimationMetadata.self, where: #Predicate { metadata in
            metadata.characterType == localCharacterType && metadata.phase == phaseString
        })
    }

    /// 특정 캐릭터/단계/애니메이션의 메타데이터만 삭제
    func clearSpecificMetadata(characterType: String, phase: CharacterPhase, animationType: String) {
        guard let modelContext = modelContext else {
            print("❌ SwiftData 컨텍스트가 설정되지 않음")
            return
        }
        
        do {
            // 특정 조건의 메타데이터 조회
            let phaseString = BundleAnimationLoader.phaseToString(phase)
            let predicate = #Predicate<GRAnimationMetadata> { metadata in
                metadata.characterType == characterType &&
                metadata.phase == phaseString &&
                metadata.animationType == animationType
            }
            
            let fetchDescriptor = FetchDescriptor<GRAnimationMetadata>(predicate: predicate)
            let specificMetadata = try modelContext.fetch(fetchDescriptor)
            
            print("🗑️ \(characterType) \(phaseString) \(animationType) 메타데이터 \(specificMetadata.count)개 삭제")
            
            // 해당 메타데이터들 삭제
            for metadata in specificMetadata {
                modelContext.delete(metadata)
            }
            
            try modelContext.save()
            
            print("✅ 특정 메타데이터 삭제 완료")
            
        } catch {
            print("❌ 특정 메타데이터 삭제 실패: \(error)")
        }
    }
}

