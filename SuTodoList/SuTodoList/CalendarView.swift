//
//  CalendarView.swift
//  SuTodoList
//
//  Created by KimJunsoo on 1/17/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentDate = Date()
    private let calendar = Calendar.current

    var body: some View {
        VStack {
            // 월 및 이전/다음 버튼
            HStack {
                Button(action: {
                    currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                }) {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(monthYearString(for: currentDate))
                    .font(.title2)
                    .bold()

                Spacer()

                Button(action: {
                    currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            // 요일 표시
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
            }

            // 날짜 표시
            let days = daysInMonth(for: currentDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { day in
                    if let day = day {
                        Text("\(day)")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    } else {
                        // 빈 칸
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }

    // 날짜를 월과 연도로 포맷
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    // 현재 월의 날짜 계산
    private func daysInMonth(for date: Date) -> [Int?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay) - 1 // 0 기반
        var days: [Int?] = Array(repeating: nil, count: weekday) // 옵셔널(Int?)로 명시
        days += range.map { $0 }
        return days
    }
}
