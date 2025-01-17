import SwiftUI
import SwiftData

struct EditPageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State var title: String
    @State var isFinish: Bool

    var item: Item

    init(item: Item) {
        self.item = item
        _title = State(initialValue: item.title ?? "")
        _isFinish = State(initialValue: item.isFinish)
    }

    var body: some View {
        Form {
            Section(header: Text("할 일 정보")) {
                TextField("제목을 입력하세요", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Toggle("완료 상태", isOn: $isFinish)
            }
        }
        .navigationTitle("할 일 수정")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("변경") {
                    saveChanges()
                }
                .disabled(title.isEmpty)
            }
        }
    }

    private func saveChanges() {
        withAnimation {
            item.title = title
            item.isFinish = isFinish
//            try? modelContext.save()
            dismiss()
        }
    }
}
