//
//  AnimationTestViewModel.swift
//  Grruung
//
//  Created by NoelMacMini on 5/12/25.
//

import SwiftUI
import SwiftData
import FirebaseStorage
import Combine

class AnimationTestViewModel: ObservableObject {
    // Firebase Storage 참조
    private let storage = Storage.storage().reference()
    
    // 메모리 캐시
    private let imageCache = NSCache<NSString, UIImage>()
    
    // 진행 상태
    @Published var isLoading = false
    @Published var progress: Double = 0
    @Published var message: String = ""
    @Published var errorMessage: String? = nil
    
    // SwiftData 컨텍스트
    private var modelContext: ModelContext?
    
    // 캐시 디렉토리 URL
    private let cacheDirectoryURL: URL
    
    // 취소 토큰
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 캐시 제한 해제
        imageCache.countLimit = 0
        imageCache.totalCostLimit = 0
        
        // 캐시 디렉토리 설정
        if let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheDirectoryURL = cachesDirectory.appendingPathComponent("animations", isDirectory: true)
            
            // 디렉토리 생성
            try? FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                     withIntermediateDirectories: true)
        } else {
            // Fallback - 보통 여기까지 오지 않습니다
            cacheDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("animations", isDirectory: true)
        }
        
    }
    
    // ModelContext를 설정하는 메서드 추가
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Firebase에서 애니메이션 다운로드
    // 캐릭터 타입과 단계에 따른 경로 관리를 위한 로직 추가
    private func getAnimationPath(characterType: String, phase: CharacterPhase, animationType: String) -> String {
        // phase를 영어 키워드로 변환
        let englishPhase = getEnglishPhase(phase)
        
        // 특별한 경우: egg 단계는 모든 캐릭터에 공통으로 사용
        if phase == .egg {
            return "animations/egg/\(animationType)"
        }
        
        // 다른 단계는 캐릭터별로 다른 경로 사용
        let storageAnimationType = getStorageAnimationType(characterType: characterType, phase: phase, uiAnimationType: animationType)
        
        return "animations/\(characterType)/\(englishPhase)/\(storageAnimationType)"
    }
    
    
    // phase를 영어로 변환하는 함수 추가
    private func getEnglishPhase(_ phase: CharacterPhase) -> String {
        switch phase {
        case .egg: return "egg"
        case .infant: return "infant"
        case .child: return "child"
        case .adolescent: return "adolescent"
        case .adult: return "adult"
        case .elder: return "elder"
        }
    }
    
    // 성장 단계와 캐릭터 타입별 애니메이션 매핑
    private let animationMapping: [CharacterPhase: [String: [String: String]]] = [
        .egg: [
            "egg": [:], // egg는 모든 캐릭터에 공통
        ],
        .infant: [
            "quokka": [
                "normal": "idle",
                "sleep": "sleep",
                "play": "play"
            ],
            "lion": [
                "normal": "idle",
                "angry": "angry",
                "happy": "happy"
            ]
        ],
        .child: [
            "quokka": [
                "normal": "idle",
                "sleep": "sleep",
                "play": "play"
            ],
            "lion": [
                "normal": "idle",
                "angry": "angry",
                "happy": "happy"
            ]
        ],
        .adolescent: [
            "quokka": [
                "normal": "idle",
                "sleep": "sleep",
                "play": "play"
            ],
            "lion": [
                "normal": "idle",
                "angry": "angry",
                "happy": "happy"
            ]
        ],
        .adult: [
            "quokka": [
                "normal": "idle",
                "sleep": "sleep",
                "play": "play"
            ],
            "lion": [
                "normal": "idle",
                "angry": "angry",
                "happy": "happy"
            ]
        ],
        .elder: [
            "quokka": [
                "normal": "idle",
                "sleep": "sleep",
                "play": "play"
            ],
            "lion": [
                "normal": "idle",
                "angry": "angry",
                "happy": "happy"
            ]
        ]
    ]
    
    // UI 애니메이션 타입을 스토리지 애니메이션 타입으로 변환하는 메서드
    private func getStorageAnimationType(characterType: String, phase: CharacterPhase, uiAnimationType: String) -> String {
        // 특정 단계와 캐릭터에 대한 매핑 확인
        if let phaseMapping = animationMapping[phase],
           let characterMapping = phaseMapping[characterType],
           let storageType = characterMapping[uiAnimationType] {
            return storageType
        }
        
        // 매핑이 없으면 원래 이름 그대로 사용
        return uiAnimationType
    }
    
    
    /// 특정 캐릭터의 애니메이션 타입 다운로드
    func downloadAnimation(characterType: String, phase: CharacterPhase, animationType: String) {
        guard let modelContext = modelContext else {
            errorMessage = "데이터 컨텍스트 초기화 실패"
            return
        }
        
        isLoading = true
        progress = 0
        message = "다운로드 준비 중..."
        errorMessage = nil
        
        // 다운로드할 폴더 경로
        let animationPath = getAnimationPath(characterType: characterType, phase: phase, animationType: animationType)
        print("요청 경로: \(animationPath)")
        let folderRef = storage.child(animationPath)
        print("요청 folderRef 경로: \(folderRef)")
        
        // 폴더 내 모든 파일 목록 가져오기
        folderRef.listAll { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "파일 목록 가져오기 실패: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let result = result, !result.items.isEmpty else {
                DispatchQueue.main.async {
                    self.errorMessage = "애니메이션 파일 없음: \(animationPath)"
                    self.isLoading = false
                }
                return
            }
            
            // 파일명 기준으로 정렬 (숫자 순서대로)
            let sortedItems = result.items.sorted { item1, item2 in
                // 파일명에서 숫자 추출하여 정렬
                let name1 = item1.name.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                let name2 = item2.name.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                
                if let num1 = Int(name1), let num2 = Int(name2) {
                    return num1 < num2
                }
                return item1.name < item2.name
            }
            
            // 다운로드할 총 파일 수
            let totalFiles = sortedItems.count
            var downloadedFiles = 0
            
            DispatchQueue.main.async {
                self.message = "애니메이션 프레임 \(totalFiles)개 다운로드 중..."
            }
            
            // 캐릭터 애니메이션 타입 폴더 경로
            let animationDirectory = self.cacheDirectoryURL
                .appendingPathComponent(characterType, isDirectory: true)
                .appendingPathComponent(phase.rawValue, isDirectory: true)
                .appendingPathComponent(animationType, isDirectory: true)
            
            // 폴더 생성
            try? FileManager.default.createDirectory(at: animationDirectory,
                                                     withIntermediateDirectories: true)
            
            // 각 이미지 파일 다운로드
            for (index, item) in sortedItems.enumerated() {
                // 저장할 파일 이름 결정 (Firebase 파일명 그대로 사용)
                let fileName = item.name
                
                // 프레임 인덱스 추출 (파일명에서 숫자 부분)
                let frameIndexString = fileName.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                let frameIndex = Int(frameIndexString) ?? (index + 1)
                
                // 로컬 저장 경로
                let localURL = animationDirectory.appendingPathComponent(fileName)
                
                // 파일 이미 존재하는지 확인
                if FileManager.default.fileExists(atPath: localURL.path) {
                    // 이미 존재하는 파일 메타데이터 업데이트
                    self.updateMetadata(
                        characterType: characterType,
                        phase: phase, 
                        animationType: animationType,
                        frameIndex: frameIndex,
                        filePath: localURL.path
                    )
                    
                    // 카운트 증가 및 진행률 업데이트
                    downloadedFiles += 1
                    let progress = Double(downloadedFiles) / Double(totalFiles)
                    
                    DispatchQueue.main.async {
                        self.progress = progress
                        self.message = "다운로드 중... (\(downloadedFiles)/\(totalFiles))"
                        print("다운로드 중... (\(downloadedFiles)/\(totalFiles))")
                        
                        // 모든 파일 처리 완료
                        if downloadedFiles == totalFiles {
                            self.message = "다운로드 완료! \(totalFiles)개 프레임"
                            print("다운로드 완료! \(totalFiles)개 프레임")
                            self.isLoading = false
                        }
                    }
                    continue
                }
                
                // Firebase에서 파일 다운로드
                let downloadTask = item.write(toFile: localURL)
                
                // 진행률 업데이트
                downloadTask.observe(.progress) { snapshot in
                    let fileProgress = (snapshot.progress?.fractionCompleted ?? 0)
                    let overallProgress = (Double(downloadedFiles) + fileProgress) / Double(totalFiles)
                    
                    DispatchQueue.main.async {
                        self.progress = overallProgress
                    }
                }
                
                // 완료 처리
                downloadTask.observe(.success) { snapshot in
                    do {
                        // 파일 크기 확인
                        let fileAttributes = try FileManager.default.attributesOfItem(atPath: localURL.path)
                        let fileSize = fileAttributes[.size] as? Int ?? 0
                        
                        // 메타데이터 저장
                        self.saveMetadata(
                            characterType: characterType,
                            phase: phase,
                            animationType: animationType,
                            frameIndex: frameIndex,
                            filePath: localURL.path,
                            fileSize: fileSize
                        )
                        
                        // 선택적으로 메모리 캐시에 추가
                        if let image = UIImage(contentsOfFile: localURL.path) {
                            let cacheKey = self.getCacheKey(
                                characterType: characterType, phase: phase,
                                animationType: animationType,
                                frameIndex: frameIndex
                            )
                            self.imageCache.setObject(image, forKey: cacheKey as NSString)
                        }
                        
                        // 진행 카운터 업데이트
                        downloadedFiles += 1
                        
                        DispatchQueue.main.async {
                            self.message = "다운로드 중... (\(downloadedFiles)/\(totalFiles))"
                            
                            // 모든 파일 다운로드 완료
                            if downloadedFiles == totalFiles {
                                self.message = "다운로드 완료! \(totalFiles)개 프레임"
                                self.isLoading = false
                            }
                        }
                    } catch {
                        print("파일 크기 확인 오류: \(error.localizedDescription)")
                        
                        // 오류가 있어도 진행 카운터 업데이트
                        downloadedFiles += 1
                    }
                }
                
                // 오류 처리
                downloadTask.observe(.failure) { snapshot in
                    print("다운로드 실패: \(item.name), 오류: \(snapshot.error?.localizedDescription ?? "알 수 없음")")
//                    if let error = snapshot.error as NSError? {
//                        print("다운로드 실패: \(item.name), 오류 코드: \(error.code), 설명: \(error.localizedDescription), 도메인: \(error.domain)")
//                        // 추가 오류 정보가 있으면 출력
//                        if let userInfo = error.userInfo as? [String: Any], !userInfo.isEmpty {
//                            print("추가 정보: \(userInfo)")
//                        }
//                    }
                    
                    // 오류가 있어도 진행 카운터 업데이트
                    downloadedFiles += 1
                    
                    // 만약 모든 처리가 완료되었다면 전체 종료
                    if downloadedFiles == totalFiles {
                        DispatchQueue.main.async {
                            self.message = "다운로드 완료 (일부 파일 오류)"
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    /// 테스트용으로 첫 번째 프레임만 다운로드
    func downloadSingleFrame(characterType: String, phase: CharacterPhase, animationType: String) {
        guard let modelContext = modelContext else {
            errorMessage = "데이터 컨텍스트 초기화 실패"
            return
        }
        
        isLoading = true
        progress = 0
        message = "테스트 다운로드 준비 중..."
        errorMessage = nil
        
        // 경로 구성 시 getAnimationPath 함수 사용
        let animationPath = getAnimationPath(characterType: characterType, phase: phase, animationType: animationType)
        
        // 단일 프레임 경로 구성 (첫 번째 프레임)
        let frameNumber = 1
        
        
        let filePath = "animations/\(characterType)/\(animationType)/\(animationType)\(frameNumber).png"
        // "CharacterImageSet/\(formattedCharType)/\(formattedAnimType)/\(formattedAnimType)\(frameNumber).png"
        
        print("테스트 파일 경로: \(filePath) (UI 애니메이션 타입: \(animationType))")
        
        let fileRef = storage.child(filePath)
        print("테스트 파일 전체 경로: \(fileRef)")
        
        // 캐릭터 애니메이션 타입 폴더 경로
        let animationDirectory = self.cacheDirectoryURL
            .appendingPathComponent(characterType, isDirectory: true)
            .appendingPathComponent(animationType, isDirectory: true)
        
        // 폴더 생성
        try? FileManager.default.createDirectory(at: animationDirectory,
                                                withIntermediateDirectories: true)
        
        // 로컬 저장 경로
        let localFileName = "\(animationType)\(frameNumber).png"
        let localURL = animationDirectory.appendingPathComponent(localFileName)
        
        // 다운로드 전 상세 정보 출력
        print("===== 다운로드 시작 정보 =====")
        print("다운로드 경로: \(filePath)")
        print("저장 경로: \(localURL.path)")
        print("=============================")
        
        // Firebase에서 파일 다운로드
        let downloadTask = fileRef.write(toFile: localURL)
        
        // 진행률 업데이트
        downloadTask.observe(.progress) { snapshot in
            let fileProgress = (snapshot.progress?.fractionCompleted ?? 0)
            
            DispatchQueue.main.async {
                self.progress = fileProgress
                self.message = "테스트 다운로드 중... \(Int(fileProgress * 100))%"
            }
        }
        
        // 완료 처리
        downloadTask.observe(.success) { snapshot in
            do {
                // 파일 크기 확인
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: localURL.path)
                let fileSize = fileAttributes[.size] as? Int ?? 0
                
                // 메타데이터 저장
                self.saveMetadata(
                    characterType: characterType,
                    phase: phase,
                    animationType: animationType,
                    frameIndex: frameNumber,
                    filePath: localURL.path,
                    fileSize: fileSize
                )
                
                // 이미지 확인
                if let image = UIImage(contentsOfFile: localURL.path) {
                    // 메모리 캐시에 추가
                    let cacheKey = self.getCacheKey(
                        characterType: characterType,
                        phase: phase,
                        animationType: animationType,
                        frameIndex: frameNumber
                    )
                    self.imageCache.setObject(image, forKey: cacheKey as NSString)
                    
                    DispatchQueue.main.async {
                        self.message = "테스트 다운로드 성공! 크기: \(self.formatFileSize(fileSize))"
                        self.isLoading = false
                    }
                    
                    // 성공 로그
                    print("===== 다운로드 성공 =====")
                    print("파일 경로: \(localURL.path)")
                    print("파일 크기: \(fileSize) 바이트")
                    print("이미지 크기: \(image.size.width)x\(image.size.height)")
                    print("=========================")
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "이미지 로드 실패: 파일은 다운로드되었으나 이미지로 변환할 수 없습니다."
                        self.isLoading = false
                    }
                    
                    print("===== 이미지 로드 실패 =====")
                    print("파일은 다운로드되었으나 이미지로 변환할 수 없습니다.")
                    print("===============================")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "파일 처리 실패: \(error.localizedDescription)"
                    self.isLoading = false
                }
                
                print("===== 파일 처리 실패 =====")
                print("오류: \(error.localizedDescription)")
                print("===========================")
            }
        }
        
        // 오류 처리
        downloadTask.observe(.failure) { snapshot in
            DispatchQueue.main.async {
                self.errorMessage = "다운로드 실패: \(snapshot.error?.localizedDescription ?? "알 수 없는 오류")"
                self.isLoading = false
            }
            
            print("===== 다운로드 실패 =====")
            print("파일 경로: \(filePath)")
            
            if let error = snapshot.error as NSError? {
                print("오류 코드: \(error.code)")
                print("오류 설명: \(error.localizedDescription)")
                print("오류 도메인: \(error.domain)")
                
//                if let userInfo = error.userInfo, !userInfo.isEmpty {
//                    print("상세 정보:")
//                    for (key, value) in userInfo {
//                        print("  \(key): \(value)")
//                    }
//                }
            }
            print("=========================")
        }
    }
    // 파일 크기 포맷팅
    private func formatFileSize(_ byteCount: Int) -> String {
        if byteCount < 1024 {
            return "\(byteCount) 바이트"
        } else if byteCount < 1024 * 1024 {
            let kb = Double(byteCount) / 1024.0
            return String(format: "%.1f KB", kb)
        } else {
            let mb = Double(byteCount) / (1024.0 * 1024.0)
            return String(format: "%.1f MB", mb)
        }
    }
    
    /// 특정 파일이 Firebase Storage에 존재하는지 확인
    func checkFileExistence(characterType: String, phase: CharacterPhase, animationType: String, frameNumber: Int = 1) {
        // 경로 구성 시 getAnimationPath 함수 사용
        let animationPath = getAnimationPath(characterType: characterType, phase: phase, animationType: animationType)
        
        // 파일 경로 구성
        let filePath = "\(animationPath)/\(animationType)\(frameNumber).png"
        print("확인 중인 파일: \(filePath) (UI 애니메이션 타입: \(animationType))")
        
        let fileRef = storage.child(filePath)
        
        // 메타데이터만 가져와서 존재 여부 확인
        message = "파일 존재 여부 확인 중..."
        isLoading = true
        
        fileRef.getMetadata { metadata, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error as NSError? {
                    self.errorMessage = "파일이 존재하지 않음: \(error.localizedDescription)"
                    
                    print("===== 파일 존재 안함 =====")
                    print("경로: \(filePath)")
                    print("오류 코드: \(error.code)")
                    print("오류 설명: \(error.localizedDescription)")
                    print("=========================")
                } else if let metadata = metadata {
                    self.message = "파일 존재함! 크기: \(self.formatFileSize(Int(metadata.size)))"
                    
                    print("===== 파일 존재함 =====")
                    print("경로: \(filePath)")
                    print("크기: \(metadata.size) 바이트")
                    print("타입: \(metadata.contentType ?? "unknown")")
                    print("생성: \(metadata.timeCreated ?? Date())")
                    print("=======================")
                }
            }
        }
    }
    
    // MARK: - 이미지 로드 메서드
    
    /// 특정 애니메이션 프레임 이미지 로드
    func loadAnimationFrame(characterType: String, phase: CharacterPhase, animationType: String, frameIndex: Int) -> UIImage? {
        // 1. 메모리 캐시 확인
        let cacheKey = getCacheKey(characterType: characterType, phase: phase, animationType: animationType, frameIndex: frameIndex)
        if let cachedImage = imageCache.object(forKey: cacheKey as NSString) {
            // 메타데이터 접근 시간 업데이트
            updateLastAccessedTime(characterType: characterType, animationType: animationType, frameIndex: frameIndex)
            return cachedImage
        }
        
        // 2. 파일 시스템에서 로드
        guard let filePath = getFilePath(characterType: characterType, phase: phase, animationType: animationType, frameIndex: frameIndex),
              let image = UIImage(contentsOfFile: filePath) else {
            return nil
        }
        
        // 메모리 캐시에 추가
        imageCache.setObject(image, forKey: cacheKey as NSString)
        
        // 메타데이터 접근 시간 업데이트
        updateLastAccessedTime(characterType: characterType, animationType: animationType, frameIndex: frameIndex)
        
        return image
    }
    
    /// 애니메이션의 모든 프레임 로드 (특정 캐릭터와 애니메이션 타입의)
    func loadAllAnimationFrames(characterType: String, phase: CharacterPhase, animationType: String) -> [UIImage] {
        guard let modelContext = modelContext else {
            print("X ModelContext가 없어서 로드 불가")
            return []
        }
        
        // phase를 영어로 변환
        let englishPhase = getEnglishPhase(phase)
        
        print("애니메이션 프레임 로드 시도:")
        print("  - characterType: \(characterType)")
        print("  - phase: \(phase.rawValue)")
        print("  - phase (영어, 검색용): \(englishPhase)")
        print("  - animationType: \(animationType)")
        
        do {
            // 특정 캐릭터와 애니메이션 타입의 모든 메타데이터 쿼리
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate {
                    $0.characterType == characterType &&
                    $0.phase == englishPhase &&
                    $0.animationType == animationType
                },
                sortBy: [SortDescriptor(\.frameIndex)]
            )
            
            let metadataItems = try modelContext.fetch(descriptor)
            print("발견된 메타데이터 개수: \(metadataItems.count)")
            
            // 메타데이터 상세 정보 출력(디버깅용)
            for (index, metadata) in metadataItems.enumerated() {
                print("  [\(index)] 프레임 \(metadata.frameIndex): \(metadata.filePath)")
            }
            
            // 각 프레임 로드
            var frames: [UIImage] = []
            for metadata in metadataItems {
                print("이미지 로드 시도: \(metadata.filePath)")
                
                if let image = UIImage(contentsOfFile: metadata.filePath) {
                    frames.append(image)
                    
                    // 메모리 캐시에 추가
                    let cacheKey = getCacheKey(
                        characterType: metadata.characterType,
                        phase: CharacterPhase(rawValue: metadata.phase) ?? .egg,
                        animationType: metadata.animationType,
                        frameIndex: metadata.frameIndex
                    )
                    imageCache.setObject(image, forKey: cacheKey as NSString)
                    
                    // 마지막 접근 시간 업데이트
                    metadata.lastAccessed = Date()
                } else {
                    print("이미지 로드 실패: \(metadata.filePath)")
                    // 파일이 실제로 존재하는지 확인
                    let fileExists = FileManager.default.fileExists(atPath: metadata.filePath)
                    print("   파일 존재 여부: \(fileExists)")
                }
            }
            
            // 변경사항 저장
            try modelContext.save()
            
            print("최종 로드된 프레임 수: \(frames.count)")
            return frames
        } catch {
            print("애니메이션 프레임 로드 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - 유틸리티 메서드
    
    /// 캐시 키 생성
    private func getCacheKey(characterType: String, phase: CharacterPhase, animationType: String, frameIndex: Int) -> String {
        return "\(characterType)_\(animationType)_\(frameIndex)"
    }
    
    /// 파일 경로 가져오기
    private func getFilePath(characterType: String, phase: CharacterPhase, animationType: String, frameIndex: Int) -> String? {
        guard let modelContext = modelContext else { return nil }
        
        do {
            // 메타데이터 쿼리
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate {
                    $0.characterType == characterType &&
                    $0.phase == phase.rawValue &&
                    $0.animationType == animationType &&
                    $0.frameIndex == frameIndex
                }
            )
            
            let metadataItems = try modelContext.fetch(descriptor)
            return metadataItems.first?.filePath
        } catch {
            print("파일 경로 쿼리 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 메타데이터 저장
    private func saveMetadata(characterType: String, phase: CharacterPhase, animationType: String, frameIndex: Int, filePath: String, fileSize: Int) {
        guard let modelContext = modelContext else {
            print("❌ ModelContext가 없습니다")
            return
        }
        
        // phase를 영어로 변환
        let englishPhase = getEnglishPhase(phase)
        
        print("메타데이터 저장 시도:")
        print("  - characterType: \(characterType)")
        print("  - phase: \(phase.rawValue)")
        print("  - phase (영어, 저장용): \(englishPhase)")
        print("  - animationType: \(animationType)")
        print("  - frameIndex: \(frameIndex)")
        print("  - filePath: \(filePath)")
        
        // 기존 메타데이터 확인
        do {
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate {
                    $0.characterType == characterType &&
                    $0.phase == englishPhase &&
                    $0.animationType == animationType &&
                    $0.frameIndex == frameIndex
                }
            )
            
            let existingItems = try modelContext.fetch(descriptor)
            
            if let existingMetadata = existingItems.first {
                // 기존 메타데이터 업데이트
                print("기존 메타데이터 업데이트")
                existingMetadata.filePath = filePath
                existingMetadata.fileSize = fileSize
                existingMetadata.downloadDate = Date()
                existingMetadata.lastAccessed = Date()
                existingMetadata.isDownloaded = true
            } else {
                // 새 메타데이터 생성
                print("새 메타데이터 생성")
                let metadata = GRAnimationMetadata(
                    characterType: characterType,
                    phase: phase,
                    animationType: animationType,
                    frameIndex: frameIndex,
                    filePath: filePath,
                    fileSize: fileSize
                )
                // 실제 저장되는 문자열은 영어로 설정
                metadata.phase = englishPhase
                
                modelContext.insert(metadata)
            }
            
            // 변경사항 저장
            try modelContext.save()
            print("메타데이터 저장 성공")
        } catch {
            print("메타데이터 저장 실패: \(error.localizedDescription)")
        }
    }
    
    /// 메타데이터 업데이트
    private func updateMetadata(characterType: String, phase: CharacterPhase, animationType: String, frameIndex: Int, filePath: String) {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate {
                    $0.characterType == characterType &&
                    $0.phase == phase.rawValue &&
                    $0.animationType == animationType &&
                    $0.frameIndex == frameIndex
                }
            )
            
            let metadataItems = try modelContext.fetch(descriptor)
            
            if let metadata = metadataItems.first {
                // 기존 메타데이터 업데이트
                metadata.filePath = filePath
                metadata.lastAccessed = Date()
                metadata.isDownloaded = true
            } else {
                // 새 메타데이터 생성 (파일 크기는 나중에 업데이트)
                let metadata = GRAnimationMetadata(
                    characterType: characterType,
                    phase: phase,
                    animationType: animationType,
                    frameIndex: frameIndex,
                    filePath: filePath
                )
                
                modelContext.insert(metadata)
            }
            
            // 변경사항 저장
            try modelContext.save()
        } catch {
            print("메타데이터 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    /// 마지막 접근 시간 업데이트
    private func updateLastAccessedTime(characterType: String, animationType: String, frameIndex: Int) {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate {
                    $0.characterType == characterType &&
                    $0.animationType == animationType &&
                    $0.frameIndex == frameIndex
                }
            )
            
            let metadataItems = try modelContext.fetch(descriptor)
            
            if let metadata = metadataItems.first {
                metadata.lastAccessed = Date()
                try modelContext.save()
            }
        } catch {
            print("접근 시간 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 캐시 관리 메서드
    
    /// 특정 애니메이션 관련 캐시 삭제
    func clearCache(characterType: String, phase: CharacterPhase, animationType: String) {
        guard let modelContext = modelContext else { return }
        
        do {
            // 메타데이터 쿼리
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate {
                    $0.characterType == characterType &&
                    $0.phase == phase.rawValue &&
                    $0.animationType == animationType
                }
            )
            
            let metadataItems = try modelContext.fetch(descriptor)
            
            // 파일 삭제 및 메타데이터 삭제
            for metadata in metadataItems {
                // 파일 시스템에서 삭제
                try? FileManager.default.removeItem(atPath: metadata.filePath)
                
                // 메모리 캐시에서 삭제
                let cacheKey = getCacheKey(
                    characterType: metadata.characterType,
                    phase: CharacterPhase(rawValue: metadata.phase) ?? .egg,
                    animationType: metadata.animationType,
                    frameIndex: metadata.frameIndex
                )
                imageCache.removeObject(forKey: cacheKey as NSString)
                
                // SwiftData에서 삭제
                modelContext.delete(metadata)
            }
            
            // 변경사항 저장
            try modelContext.save()
            
            print("\(characterType)/\(animationType) 캐시 삭제 완료: \(metadataItems.count)개 항목")
        } catch {
            print("캐시 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    /// 모든 캐시 삭제
    func clearAllCache() {
        guard let modelContext = modelContext else { return }
        
        do {
            // 모든 메타데이터 가져오기
            let descriptor = FetchDescriptor<GRAnimationMetadata>()
            let allMetadata = try modelContext.fetch(descriptor)
            
            // 파일 삭제 및 메타데이터 삭제
            for metadata in allMetadata {
                // 파일 시스템에서 삭제
                try? FileManager.default.removeItem(atPath: metadata.filePath)
                
                // SwiftData에서 삭제
                modelContext.delete(metadata)
            }
            
            // 메모리 캐시 비우기
            imageCache.removeAllObjects()
            
            // 변경사항 저장
            try modelContext.save()
            
            print("모든 캐시 삭제 완료: \(allMetadata.count)개 항목")
        } catch {
            print("모든 캐시 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    /// 오래된 캐시 삭제 (일정 기간 이상 접근하지 않은 항목)
    func clearOldCache(olderThanDays: Int = 30) {
        guard let modelContext = modelContext else { return }
        
        // 기준 날짜 계산
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -olderThanDays, to: Date()) else { return }
        
        do {
            // 오래된 메타데이터 쿼리
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate { $0.lastAccessed < cutoffDate }
            )
            
            let oldMetadata = try modelContext.fetch(descriptor)
            
            // 파일 삭제 및 메타데이터 삭제
            for metadata in oldMetadata {
                // 파일 시스템에서 삭제
                try? FileManager.default.removeItem(atPath: metadata.filePath)
                
                // 메모리 캐시에서 삭제
                let cacheKey = getCacheKey(
                    characterType: metadata.characterType,
                    phase: CharacterPhase(rawValue: metadata.phase) ?? .egg,
                    animationType: metadata.animationType,
                    frameIndex: metadata.frameIndex
                )
                imageCache.removeObject(forKey: cacheKey as NSString)
                
                // SwiftData에서 삭제
                modelContext.delete(metadata)
            }
            
            // 변경사항 저장
            try modelContext.save()
            
            print("오래된 캐시 삭제 완료: \(oldMetadata.count)개 항목")
        } catch {
            print("오래된 캐시 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 정보 제공 메서드
    
    /// 특정 애니메이션 프레임 개수 가져오기
    func getFrameCount(characterType: String, phase: CharacterPhase, animationType: String) -> Int {
        guard let modelContext = modelContext else { return 0 }
        
        do {
            // 메타데이터 쿼리
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate {
                    $0.characterType == characterType &&
                    $0.phase == phase.rawValue &&
                    $0.animationType == animationType
                },
                sortBy: [SortDescriptor(\.frameIndex)]
            )
            
            let metadataItems = try modelContext.fetch(descriptor)
            return metadataItems.count
        } catch {
            print("프레임 개수 가져오기 실패: \(error.localizedDescription)")
            return 0
        }
    }
    
    /// 특정 애니메이션 총 크기 가져오기
    func getTotalSize(characterType: String, phase: CharacterPhase, animationType: String) -> Int {
        guard let modelContext = modelContext else { return 0 }
        
        do {
            // 메타데이터 쿼리
            let descriptor = FetchDescriptor<GRAnimationMetadata>(
                predicate: #Predicate {
                    $0.characterType == characterType &&
                    $0.phase == phase.rawValue &&
                    $0.animationType == animationType
                }
            )
            
            let metadataItems = try modelContext.fetch(descriptor)
            let totalSize = metadataItems.reduce(0) { $0 + $1.fileSize }
            return totalSize
        } catch {
            print("애니메이션 크기 가져오기 실패: \(error.localizedDescription)")
            return 0
        }
    }
    
    /// 모든 애니메이션 목록 가져오기
    func getAllAnimations() -> [(characterType: String, phase: CharacterPhase, animationType: String, frameCount: Int)] {
        guard let modelContext = modelContext else { return [] }
        
        do {
            // 모든 메타데이터 가져오기
            let descriptor = FetchDescriptor<GRAnimationMetadata>()
            let allMetadata = try modelContext.fetch(descriptor)
            
            // 고유한 캐릭터-애니메이션 조합 추출
            var uniqueCombinations: Set<String> = []
            var result: [(characterType: String, phase: CharacterPhase, animationType: String, frameCount: Int)] = []
            
            for metadata in allMetadata {
                let key = "\(metadata.characterType)|\(metadata.phase)|\(metadata.animationType)"
                if !uniqueCombinations.contains(key) {
                    uniqueCombinations.insert(key)
                    
                    let phase = CharacterPhase(rawValue: metadata.phase) ?? .egg
                    
                    // 해당 조합의 프레임 개수 계산
                    let count = getFrameCount(
                        characterType: metadata.characterType,
                        phase: phase,
                        animationType: metadata.animationType
                    )
                    
                    result.append((
                        characterType: metadata.characterType,
                        phase: phase,
                        animationType: metadata.animationType,
                        frameCount: count
                    ))
                }
            }
            
            return result
        } catch {
            print("애니메이션 목록 가져오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    // 리소스 정리
    func cleanup() {
        cancellables.removeAll()
    }
}
