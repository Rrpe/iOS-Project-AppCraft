//
//  TestController.swift
//  Grruung
//
//  Created by NoelMacMini on 6/1/25.
//
import SwiftUI
import SwiftData
import FirebaseStorage

// 가장 간단한 테스트용 애니메이션 컨트롤러
@MainActor
class TestController: ObservableObject {
    
    // MARK: - Published 프로퍼티들 (UI가 자동으로 업데이트됨)
    @Published var currentFrame: UIImage? = nil         // 현재 표시할 프레임
    @Published var isAnimating: Bool = false            // 애니메이션 재생 중인지 여부
    @Published var currentFrameIndex: Int = 0           // 현재 프레임 번호
    @Published var isDownloading: Bool = false          // 다운로드 중인지 여부
    @Published var downloadProgress: Double = 0.0       // 다운로드 진행률
    @Published var downloadMessage: String = ""         // 상태 메시지
    @Published var loadedFrameCount: Int = 0            // 로드된 프레임 수
    
    // MARK: - 비공개 프로퍼티들
    private var animationFrames: [UIImage] = []         // 로드된 애니메이션 프레임들
    private let storage = Storage.storage()             // Firebase Storage 인스턴스
    private var modelContext: ModelContext?             // SwiftData 컨텍스트
    private let frameRate: Double = 24.0                // 초당 프레임 수
    
    // MARK: - 고정 설정 (테스트용으로 quokka infant normal만)
    private let characterType = "quokka"
    private let phase = "infant"
    private let animationType = "normal"
    private let totalFrames = 122
    
    // MARK: - SwiftData 컨텍스트 설정
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("TestController: SwiftData 컨텍스트 설정 완료")
    }
    
    // MARK: - Firebase에서 다운로드
    func downloadAnimation() async {
        guard let context = modelContext else {
            downloadMessage = "SwiftData 컨텍스트가 설정되지 않음"
            return
        }
        
        // 다운로드 시작
        isDownloading = true
        downloadProgress = 0.0
        downloadMessage = "다운로드 준비 중..."
        
        print("Firebase에서 quokka infant normal 다운로드 시작")
        
        // Firebase Storage 경로
        let basePath = "animations/\(characterType)/\(phase)/\(animationType)"
        var downloadedFrames = 0
        
        // 각 프레임 다운로드
        for frameIndex in 1...totalFrames {
            let fileName = "\(characterType)_\(phase)_\(animationType)_\(frameIndex).png"
            let firebasePath = "\(basePath)/\(fileName)"
            
            // 개별 프레임 다운로드
            let success = await downloadSingleFrame(
                firebasePath: firebasePath,
                fileName: fileName,
                frameIndex: frameIndex,
                context: context
            )
            
            if success {
                downloadedFrames += 1
            }
            
            // 진행률 업데이트
            downloadProgress = Double(downloadedFrames) / Double(totalFrames)
            downloadMessage = "다운로드 중... (\(downloadedFrames)/\(totalFrames))"
            
            // UI 업데이트를 위한 잠시 대기
            //try? await Task.sleep(nanoseconds: 10_000_000) // 0.01초
        }
        
        // 다운로드 완료
        isDownloading = false
        downloadMessage = "다운로드 완료! \(downloadedFrames)개 프레임"
        print("다운로드 완료: \(downloadedFrames)개 프레임")
    }
    
    // MARK: - 개별 프레임 다운로드
    private func downloadSingleFrame(
        firebasePath: String,
        fileName: String,
        frameIndex: Int,
        context: ModelContext
    ) async -> Bool {
        let storageRef = storage.reference().child(firebasePath)
        
        do {
            // Firebase에서 데이터 다운로드
            let data = try await storageRef.data(maxSize: 5 * 1024 * 1024) // 5MB 제한
            
            // Documents 폴더에 저장할 경로
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let localPath = "animations/\(characterType)/\(phase)/\(animationType)/\(fileName)"
            let fullURL = documentsPath.appendingPathComponent(localPath)
            
            // 디렉토리 생성
            let directoryURL = fullURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            
            // 파일 저장
            try data.write(to: fullURL)
            
            // SwiftData에 메타데이터 저장
            let metadata = GRAnimationMetadata(
                characterType: characterType,
                phase: CharacterPhase.infant, // enum으로 전달
                animationType: animationType,
                frameIndex: frameIndex,
                filePath: localPath,
                fileSize: data.count
            )
            // 실제 저장될 때는 영어로 저장
            metadata.phase = phase
            
            // ✅ 저장 후 phase를 명확히 "infant"로 설정
            metadata.phase = "infant"
            
            context.insert(metadata)
            try context.save()
            
            print("✅ 프레임 \(frameIndex) 다운로드 및 저장 완료")
            return true
            
        } catch {
            print("❌ 프레임 \(frameIndex) 다운로드 실패: \(error)")
            return false
        }
    }
    
    // MARK: - SwiftData에서 로드
    func loadAnimationFromSwiftData() async {
        guard let context = modelContext else {
            downloadMessage = "SwiftData 컨텍스트가 설정되지 않음"
            return
        }
        
        // 클로저 캡처 문제 해결을 위한 로컬 변수
        let characterTypeLocal = self.characterType
        let phaseLocal = self.phase
        let animationTypeLocal = self.animationType
        
        downloadMessage = "프레임 로드 중..."
        animationFrames.removeAll()
        
        print("=== SwiftData에서 로드 시작 ===")
        
        // 수정된 predicate (경고 해결)
        let descriptor = FetchDescriptor<GRAnimationMetadata>(
            predicate: #Predicate { metadata in
                metadata.characterType == "quokka" &&
                metadata.phase == "infant" &&
                metadata.animationType == "normal"
            },
            sortBy: [SortDescriptor(\.frameIndex)]
        )
        
        do {
            let metadataList = try context.fetch(descriptor)
            print("발견된 메타데이터 수: \(metadataList.count)")
            
            for metadata in metadataList {
                if let image = loadImageFromPath(metadata.filePath) {
                    animationFrames.append(image)
                    print("이미지 로드 성공: 프레임 \(metadata.frameIndex)")
                } else {
                    print("이미지 로드 실패: \(metadata.filePath)")
                }
            }
            
            loadedFrameCount = animationFrames.count
            
            if !animationFrames.isEmpty {
                currentFrame = animationFrames[0]
                currentFrameIndex = 0
                downloadMessage = "로드 완료! \(loadedFrameCount)개 프레임"
                print("✅ 총 \(loadedFrameCount)개 프레임 로드 완료")
            } else {
                downloadMessage = "로드된 프레임이 없습니다"
                print("❌ 로드된 프레임이 없음")
            }
            
        } catch {
            print("❌ SwiftData 조회 실패: \(error)")
            downloadMessage = "로드 실패: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 파일 경로에서 이미지 로드
    private func loadImageFromPath(_ filePath: String) -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageURL = documentsPath.appendingPathComponent(filePath)
        
        print("이미지 로드 시도: \(imageURL.path)")
        
        // 파일 존재 여부 확인
        let fileExists = FileManager.default.fileExists(atPath: imageURL.path)
        if !fileExists {
            print("❌ 파일이 존재하지 않음: \(imageURL.path)")
            return nil
        }
        
        // 이미지 데이터 로드
        guard let imageData = try? Data(contentsOf: imageURL) else {
            print("❌ 이미지 데이터 로드 실패: \(filePath)")
            return nil
        }
        
        // UIImage 변환
        guard let image = UIImage(data: imageData) else {
            print("❌ UIImage 변환 실패: \(filePath)")
            return nil
        }
        
        print("✅ 이미지 로드 성공: \(image.size.width)x\(image.size.height)")
        return image
    }
    
    // MARK: - 애니메이션 재생 (수정된 버전)
    func startAnimation() {
        guard !animationFrames.isEmpty, !isAnimating else {
            print("애니메이션 시작 불가: 프레임(\(animationFrames.count)), 재생중(\(isAnimating))")
            return
        }
        
        isAnimating = true
        
        // async Task로 애니메이션 루프 실행
        Task { @MainActor in
            await runAnimationLoop()
        }
        
        print("애니메이션 시작 - \(animationFrames.count)개 프레임")
    }
    
    // 애니메이션 루프를 async/await로 처리
    private func runAnimationLoop() async {
        let timeInterval = 1.0 / frameRate
        
        while isAnimating && !animationFrames.isEmpty {
            updateFrame()
            
            // 다음 프레임까지 대기 (nanoseconds 단위)
            try? await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
        }
    }
    
    // 애니메이션 정지
    func stopAnimation() {
        isAnimating = false
        print("애니메이션 정지")
    }
    
    // 애니메이션 재생/정지 토글
    func toggleAnimation() {
        if isAnimating {
            stopAnimation()
        } else {
            startAnimation()
        }
    }
    
    // 프레임 업데이트
    private func updateFrame() {
        currentFrameIndex = (currentFrameIndex + 1) % animationFrames.count
        currentFrame = animationFrames[currentFrameIndex]
        
        // 매 10프레임마다 로그 출력
        if currentFrameIndex % 10 == 0 {
            print("현재 프레임: \(currentFrameIndex + 1)/\(animationFrames.count)")
        }
    }
    
    // MARK: - 다운로드 상태 확인
    func isDataDownloaded() -> Bool {
        guard let context = modelContext else { return false }
        
        let characterTypeLocal = self.characterType
        let phaseLocal = self.phase
        let animationTypeLocal = self.animationType
        
        let descriptor = FetchDescriptor<GRAnimationMetadata>(
            predicate: #Predicate { metadata in
                metadata.characterType == "quokka" &&
                metadata.phase == "infant" &&
                metadata.animationType == "normal"
            }
        )
        
        do {
            let results = try context.fetch(descriptor)
            let isDownloaded = results.count >= totalFrames
            print("다운로드 상태 확인: \(results.count)/\(totalFrames) - \(isDownloaded)")
            return isDownloaded
        } catch {
            print("다운로드 상태 확인 실패: \(error)")
            return false
        }
    }
    
    // MARK: - 정리
    func cleanup() {
        stopAnimation()
        print("TestController 정리 완료")
    }
    
    // MARK: - 기존 파일들로부터 메타데이터 생성
    func generateMetadataFromExistingFiles() async {
        guard let context = modelContext else {
            downloadMessage = "SwiftData 컨텍스트가 설정되지 않음"
            return
        }
        
        downloadMessage = "기존 파일에서 메타데이터 생성 중..."
        
        print("=== 기존 파일에서 메타데이터 생성 시작 ===")
        
        // Documents/animations 폴더 스캔
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let animationsPath = documentsPath.appendingPathComponent("animations")
        
        var createdCount = 0
        
        // 예상 경로: animations/quokka/infant/normal/
        let targetPath = animationsPath
            .appendingPathComponent("quokka")
            .appendingPathComponent("infant")
            .appendingPathComponent("normal")
        
        print("스캔 경로: \(targetPath.path)")
        
        do {
            // 폴더가 존재하는지 확인
            guard FileManager.default.fileExists(atPath: targetPath.path) else {
                downloadMessage = "파일이 저장된 폴더가 없습니다"
                print("❌ 폴더가 존재하지 않음: \(targetPath.path)")
                return
            }
            
            // 폴더 내 모든 파일 가져오기
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: targetPath,
                includingPropertiesForKeys: [.fileSizeKey, .creationDateKey],
                options: .skipsHiddenFiles
            )
            
            print("발견된 파일 수: \(fileURLs.count)")
            
            // 각 파일에 대해 메타데이터 생성
            for fileURL in fileURLs {
                // PNG 파일만 처리
                guard fileURL.pathExtension.lowercased() == "png" else { continue }
                
                let fileName = fileURL.lastPathComponent
                print("처리 중: \(fileName)")
                
                // 파일명에서 프레임 번호 추출
                // 예: "quokka_infant_normal_1.png" → frameIndex = 1
                if let frameIndex = extractFrameIndex(from: fileName) {
                    
                    // 파일 크기 가져오기
                    let fileSize = getFileSize(at: fileURL)
                    
                    // 상대 경로 계산
                    let relativePath = "animations/quokka/infant/normal/\(fileName)"
                    
                    // 메타데이터 생성
                    let metadata = GRAnimationMetadata(
                        characterType: "quokka",
                        phase: CharacterPhase.infant,
                        animationType: "normal",
                        frameIndex: frameIndex,
                        filePath: relativePath,
                        fileSize: fileSize
                    )
                    
                    // phase를 영어로 설정
                    metadata.phase = "infant"
                    
                    print("✅ 메타데이터 생성: 프레임 \(frameIndex), 크기 \(fileSize)바이트")
                    
                    context.insert(metadata)
                    createdCount += 1
                } else {
                    print("❌ 프레임 번호 추출 실패: \(fileName)")
                }
            }
            
            // 변경사항 저장
            try context.save()
            print("✅ 총 \(createdCount)개 메타데이터 생성 및 저장 시도 완료.")
            
            let characterTypeToCompare = self.characterType
            let animationTypeToCompare = self.animationType

            // --- 저장 직후 즉시 데이터 조회 (디버깅 강화) ---
            let fetchDescriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate { metadata in
                    // 저장 시도한 값과 동일한 조건
                    metadata.characterType == characterTypeToCompare && // 또는 "quokka"
                    metadata.phase == "infant" &&       // 영어 "infant"
                    metadata.animationType == animationTypeToCompare // 또는 "normal"
                },
                sortBy: [SortDescriptor(\.frameIndex)]
            )
            let results = try context.fetch(fetchDescriptor)
            print("‼️ 저장 직후 즉시 조회 결과: \(results.count)개 발견")
            if results.isEmpty && createdCount > 0 { // 또는 다운로드 성공 개수 > 0
                print("🆘 저장된 메타데이터를 즉시 조회했으나 찾을 수 없음!")
            } else {
                for item in results.prefix(5) { // 처음 5개만 출력 (너무 많을 경우 대비)
                    print("  -> 즉시 조회된 항목: type=\(item.characterType), phase=\(item.phase), anim=\(item.animationType), frame=\(item.frameIndex), path=\(item.filePath)")
                }
            }
            // --- 디버깅 코드 끝 ---
            
        } catch {
            downloadMessage = "메타데이터 생성 실패: \(error.localizedDescription)"
            print("❌ 메타데이터 생성 실패: \(error)")
        }
        
        print ("================================")
    }

    // MARK: - 헬퍼 함수들
    private func extractFrameIndex(from fileName: String) -> Int? {
        // "quokka_infant_normal_123.png" → 123
        let components = fileName.replacingOccurrences(of: ".png", with: "").split(separator: "_")
        
        if let lastComponent = components.last,
           let frameIndex = Int(lastComponent) {
            return frameIndex
        }
        
        return nil
    }

    private func getFileSize(at url: URL) -> Int {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int ?? 0
        } catch {
            print("파일 크기 확인 실패: \(error)")
            return 0
        }
    }
    
    @MainActor
    func testDirectFileLoad() {
        // 테스트할 파일의 상대 경로 (Documents 폴더 기준)
        // Firebase Storage 경로와 동일한 구조로 지정합니다.
        let testRelativePath = "animations/quokka/infant/normal/quokka_infant_normal_1.png" // 첫 번째 프레임으로 가정

        print("🧪 [파일 직접 로드 테스트] 시도 경로: \(testRelativePath)")

        // 기존의 loadImageFromPath 함수 사용
        if let image = loadImageFromPath(testRelativePath) {
            print("✅ [파일 직접 로드 테스트] 성공! 이미지 크기: \(image.size)")
            self.currentFrame = image // UI에 테스트 이미지 표시 (선택 사항)
            self.downloadMessage = "파일 직접 로드 성공: \(testRelativePath)"
        } else {
            print("❌ [파일 직접 로드 테스트] 실패: \(testRelativePath)")
            self.downloadMessage = "파일 직접 로드 실패: \(testRelativePath) (로그를 확인하세요)"
        }
    }
}
