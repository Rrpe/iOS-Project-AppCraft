//
//  MBTIProfile.swift
//  FixMBTI
//
//  Created by KimJunsoo on 2/4/25.
//

import Foundation
import SwiftData
/*
 I0 N0 F0 J0
 E1 S1 T1 P1
 이건 추후에 해보는게 어떨까요?
 */
@Model
class MBTIProfile {
    var currentMBTI: String     // 사용자 MBTI
    var targetMBTI: String      // 목표 MBTI
    
    init(currentMBTI: String, targetMBTI: String) {
        self.currentMBTI = currentMBTI
        self.targetMBTI = targetMBTI
    }
}
