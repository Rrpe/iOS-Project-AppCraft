import SwiftUI
import SwiftData

struct AddPageView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // 현재 뷰 닫기
    @State private var title: String = ""
    @State private var isFinish: Bool = false
    
    let currentDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("새로운 할 일")) {
                    TextField("할 일 제목을 입력하세요", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("날짜 : \(formatDate(currentDate))")
                    Toggle(isOn: $isFinish) {
                        Text("완료 상태")
                    }
                }
            }
            .navigationTitle("할 일 추가")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveItem()
                    }
                    .disabled(title.isEmpty) // 제목이 비어있으면 저장 버튼 비활성화
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveItem() {
        // SwiftData 모델에 새로운 항목 추가
        withAnimation {
            let newItem = Item(title: title, timestamp: Date(), isFinish: isFinish)
            modelContext.insert(newItem)
            dismiss() // 뷰 닫기
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

