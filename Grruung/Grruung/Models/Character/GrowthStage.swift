//
//  GrowthStageImage.swift
//  Grruung
//
//  Created by NO SEONGGYEONG on 5/21/25.
//
import Foundation

struct GrowthStage: Identifiable {
    let id = UUID()
    let stage: String
    let imageURL: URL?
    let order: Int
}
