//
//  VertexAIService.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//

import Foundation
import FirebaseCore
import FirebaseVertexAI

/// Vertex AI 연동을 위한 서비스 클래스
class VertexAIService {
    // MARK: - Properties
    /// 싱글톤 인스턴스
    static let shared = VertexAIService()
    
    /// 생성 모델
    private var model: GenerativeModel?
    
    // 응답 캐싱 (같은 프롬프트에 대한 중복 요청 방지)
    private var responseCache: [String: String] = [:]
    
    // 초기화 상태 추적
    private var isInitialized = false
    private var initializationError: Error?
    
    // MARK: - Initialization
    private init() {
        setupModel()
    }
    
    // MARK: - Setup
    // Vertex AI 모델 설정
    private func setupModel() {
        // Firebase Vertex AI 초기화
        let vertex = VertexAI.vertexAI()
        
        // 가장 가벼운 Gemini 모델 사용
        model = vertex.generativeModel(modelName: "gemini-2.0-flash")
        
        isInitialized = true
        print("[VertexAI] 모델 초기화 성공")
        
        // 오류 처리
        if model == nil {
            isInitialized = false
            print("[VertexAI] 초기화 실패")
        }
    }
    
    // 모델이 초기화되지 않았을 경우 재시도
    private func retryInitializationIfNeeded() {
        if !isInitialized || model == nil {
            setupModel()
        }
    }
    
    // 프롬프트 길이 로깅
    // 프롬프트 길이가 너무 길어서 생기는 오류인지 네트워크 오류인지 아직 확실치 않으나 가끔 새로운 펫 생성 후 대화시 연결끊김 오류떠서 길이 제한 기능 작성
    private func logPromptStats(prompt: String) {
        let promptLength = prompt.count
        print("[VertexAI] 현재 프롬프트 길이: \(promptLength)자")
        
        // 섹션별 길이 계산 (대략적인 추정)
        let lines = prompt.components(separatedBy: "\n\n")
        for (index, section) in lines.enumerated() {
            let sectionName: String
            switch index {
            case 0: sectionName = "기본 프롬프트"
            case 1: sectionName = "상태 정보"
            case 2: sectionName = "대화 컨텍스트"
            case 3: sectionName = "중요 기억"
            case 4: sectionName = "지침 및 사용자 입력"
            default: sectionName = "기타 섹션 \(index)"
            }
            print("[VertexAI] \(sectionName) 길이: \(section.count)자")
        }
    }
    
    // MARK: - Public Methods
    
    // 펫 응답 생성 함수
    /// - Parameters:
    ///   - prompt: 프롬프트 텍스트
    ///   - completion: 응답 콜백
    func generatePetResponse(
        prompt: String,
        completion: @escaping (String?, Error?) -> Void
    ) {
        // 초기화 확인 및 재시도
        retryInitializationIfNeeded()
        
        // 모델이 초기화되지 않았으면 에러 반환
        guard isInitialized, let model = model else {
            let error = initializationError ?? NSError(
                domain: "VertexAIService",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "AI 모델이 초기화되지 않았습니다."]
            )
            completion(nil, error)
            return
        }
        
        // 캐싱된 응답이 있는지 확인
        if let cachedResponse = responseCache[prompt] {
            completion(cachedResponse, nil)
            return
        }
        
        // 프롬프트 길이 로깅
        logPromptStats(prompt: prompt)
        
        // 프롬프트 길이 제한 확인 (토큰 수가 아닌 문자 수로 대략적 제한)
        let maxPromptLength = 8000
        let truncatedPrompt: String
        
        if prompt.count > maxPromptLength {
            // 프롬프트가 너무 길면 잘라내기
            let prefix = prompt.prefix(maxPromptLength / 2)
            let suffix = prompt.suffix(maxPromptLength / 2)
            truncatedPrompt = String(prefix) + "...\n[중간 내용 생략]...\n" + String(suffix)
            print("[VertexAI] 프롬프트가 너무 길어서 잘라냄: \(prompt.count) -> \(truncatedPrompt.count)")
        } else {
            truncatedPrompt = prompt
        }
        
        // 응답 생성
        Task {
            do {
                let requestStartTime = Date()
                
                // 잠시 대기 후 응답 생성 시도 (첫 요청 타이밍 문제 방지)
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기
                
                // 응답 생성
                let response = try await model.generateContent(prompt)
                
                // 응답 처리
                if let responseText = response.text {
                    let requestTime = Date().timeIntervalSince(requestStartTime)
                    print("[VertexAI] 응답 생성 시간: \(String(format: "%.2f", requestTime))초")
                    
                    // 응답 캐싱 (메모리 효율성을 위해 최대 10개만 캐시)
                    if self.responseCache.count >= 10 {
                        if let firstKey = self.responseCache.keys.first {
                            self.responseCache.removeValue(forKey: firstKey)
                        }
                    }
                    self.responseCache[prompt] = responseText
                    
                    DispatchQueue.main.async {
                        completion(responseText, nil)
                    }
                } else {
                    throw NSError(
                        domain: "VertexAIService",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "응답이 비어있습니다."]
                    )
                }
            } catch {
                print("[VertexAI] 응답 생성 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    // 캐시를 지웁니다.
    func clearCache() {
        responseCache.removeAll()
    }
}
