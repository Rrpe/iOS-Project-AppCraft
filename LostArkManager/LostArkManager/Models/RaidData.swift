//
//  RaidData.swift
//  LostArkManager
//
//  Created by KimJunsoo on 2/28/25.
//

import SwiftData

@Model
class RaidData {
    var name: String
    var mode: String // 싱글, 노말, 하드
    var clearGold: [Int] // 각 관문별 보상
    var addGold: [Int] // 더보기 비용
    
    init(name: String, mode: String, clearGold: [Int], addGold: [Int]) {
        self.name = name
        self.mode = mode
        self.clearGold = clearGold
        self.addGold = addGold
    }
}

let raidList: [RaidData] = [
    RaidData(name: "카멘", mode: "싱글", clearGold: [2000, 2400, 3600], addGold: [650, 800, 1300]),
    RaidData(name: "카멘", mode: "노말", clearGold: [2500, 3000, 4500], addGold: [800, 1000, 1300]),
    RaidData(name: "카멘", mode: "하드", clearGold: [3500, 4500, 7500, 8000], addGold: [1100, 1500, 2400, 2400]),
    RaidData(name: "서막(에키드나)", mode: "싱글", clearGold: [4000, 7600], addGold: [800, 1650]),
    RaidData(name: "서막(에키드나)", mode: "노말", clearGold: [5000, 9500], addGold: [2200, 3400]),
    RaidData(name: "서막(에키드나)", mode: "하드", clearGold: [6000, 12500], addGold: [2200, 4100]),
    RaidData(name: "1막(에기르)", mode: "노말", clearGold: [7500, 15500], addGold: [3200, 5300]),
    RaidData(name: "1막(에기르)", mode: "하드", clearGold: [9000, 18500], addGold: [4100, 6600]),
    RaidData(name: "2막(아브렐슈드)", mode: "노말", clearGold: [8500, 16500], addGold: [3800, 5600]),
    RaidData(name: "2막(아브렐슈드)", mode: "하드", clearGold: [10000, 20500], addGold: [4500, 7200]),
    RaidData(name: "3막(모르둠)", mode: "노말", clearGold: [6000, 9500, 12500], addGold: [2400, 3200, 4200]),
    RaidData(name: "3막(모르둠)", mode: "하드", clearGold: [7000, 11000, 20000], addGold: [2700, 4100, 5800])
]
