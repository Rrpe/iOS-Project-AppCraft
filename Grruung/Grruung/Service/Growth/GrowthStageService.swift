//
//  GrowthStageService.swift
//  Grruung
//
//  Created by NO SEONGGYEONG on 5/21/25.
//

import FirebaseStorage
import SwiftUI

class GrowthStageService: ObservableObject {
    private let storage = Storage.storage()
    @Published var growthStages: [GrowthStage] = []

    // 단순히 폴더명만 받도록 변경
    func fetchGrowthStageImages(folderName: String = "growth_stages") async -> [GrowthStage] {
        let stageNames = ["egg", "infant", "child", "adolescent", "adult", "elder"]
        let stageKorNames = ["운석", "유아기", "소아기", "청년기", "성년기", "노년기"]
        var growthStages: [GrowthStage] = []
        
        print("이미지 폴더: \(folderName)")
        
        await withTaskGroup(of: GrowthStage?.self) { group in
            for (index, stageName) in stageNames.enumerated() {
                group.addTask {
                    // 지정된 폴더에서 이미지 불러오기
                    let path = "\(folderName)/\(stageName).png"
                    print("이미지 가져오기: \(path)")
                    
                    do {
                        let stageRef = self.storage.reference().child(path)
                        let url = try await stageRef.downloadURL()
                        return GrowthStage(stage: stageKorNames[index], imageURL: url, order: index)
                    } catch {
                        // 기본 폴더로 폴백
                        if folderName != "growth_stages" {
                            do {
                                let defaultPath = "growth_stages/\(stageName).png"
                                let defaultRef = self.storage.reference().child(defaultPath)
                                let url = try await defaultRef.downloadURL()
                                print("기본 이미지 사용: \(stageName)")
                                return GrowthStage(stage: stageKorNames[index], imageURL: url, order: index)
                            } catch {
                                print("이미지 없음: \(stageName)")
                            }
                        }
                        return GrowthStage(stage: stageKorNames[index], imageURL: nil, order: index)
                    }
                }
            }

            for await stage in group {
                if let stage = stage {
                    growthStages.append(stage)
                }
            }
        }

        return growthStages.sorted(by: { $0.order < $1.order })
    }
    
    func clearImageCache() {
        URLCache.shared.removeAllCachedResponses()
        // Firebase Storage 캐시도 초기화
        let storage = Storage.storage()
        storage.maxUploadRetryTime = 5
        storage.maxDownloadRetryTime = 5
    }
}
