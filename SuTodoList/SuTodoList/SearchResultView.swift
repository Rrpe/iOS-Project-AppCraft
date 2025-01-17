//
//  searchResultView.swift
//  SuTodoList
//
//  Created by KimJunsoo on 1/17/25.
//

import SwiftUI
import SwiftData

struct SearchResultView: View {
    var searchText: String
    
    @Query private var items: [Item] // SwiftData 사용 시 실제 데이터 모델 연결
    
    var body: some View {
            List(filteredItems) { item in
                HStack {
                    Image(systemName: item.isFinish ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isFinish  ? .green : .gray)
                    Text(item.title ?? "제목 없음")
                        .strikethrough(item.isFinish, color: .gray)
                        .foregroundStyle(item.isFinish ? .gray : .black)
                }
            }
            .navigationTitle("검색 결과")
        }

        private var filteredItems: [Item] {
            if searchText.isEmpty {
                return []
            } else {
                return items.filter { ($0.title ?? "").localizedCaseInsensitiveContains(searchText) }
            }
        }
}
