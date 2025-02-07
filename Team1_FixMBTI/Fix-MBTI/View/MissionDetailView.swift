//
//  MissionDetailView.swift
//  FixMBTI
//
//  Created by KimJunsoo on 2/4/25.
//

import Foundation
import SwiftUI
import SwiftData

struct MissionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var inputText: String = ""
    
    private let mission: Mission  // let으로 변경
    
    init(mission: Mission) {  // 명시적 생성자 추가
        self.mission = mission
    }
    
    var body: some View {
        VStack {
            Button(action: { isImagePickerPresented.toggle() }) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "FA812F"))
                    }
                    .frame(width: 350, height: 350)
                    .background(Color(hex: "F8F8F8"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
            HStack {
                Text(mission.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .padding(.leading)
                
                Spacer()
                
                Text(mission.category)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "FA812F"))
                    .padding(.trailing)
                
            }
            
            HStack {
                Text(mission.detailText)
                    .font(.caption)
                    .lineLimit(1)
                    .padding(.leading)
                Spacer()
            }
            
            TextEditor(text: $inputText)
                .font(.system(size: 18))
                .overlay(alignment: .topLeading) {
                    Text("문구 입력..")
                        .font(.system(size: 18))
                        .foregroundStyle(inputText.isEmpty ? .gray : .clear)
                        .padding(.top, 8)
                        .padding(.horizontal, 5)
                }
                .frame(height: 200)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            
            
            Spacer()
            
            Text("완료")
                .padding()
                .frame(maxWidth: .infinity)
                .background(inputText.isEmpty ? Color.gray : Color(hex: "FA812F")) 
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                .offset(y: -20)
                .disabled(inputText.isEmpty)
                .onTapGesture {
                    savePost()
                }
        }
        .padding()
        .navigationTitle("게시물 작성")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func savePost() {
        var fileName: String? = nil
        
        // 이미지가 선택되었을 경우에만 이미지 저장
        if let imageData = selectedImage?.jpegData(compressionQuality: 0.8) {
            fileName = UUID().uuidString + ".jpg"
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(fileName!)
                try? imageData.write(to: fileURL)
            }
        }
        
        // PostMission 생성 및 저장
        let postMission = PostMission(
            mission: mission,
            content: inputText,
            imageName: fileName
        )
        modelContext.insert(postMission)
        
        // 원본 ActiveMission 삭제
        let activeMissions = try? modelContext.fetch(FetchDescriptor<ActiveMission>())
        activeMissions?.forEach { activeMission in
            if activeMission.title == mission.title {
                modelContext.delete(activeMission)
            }
        }
        try? modelContext.save()
        
        dismiss()
    }
}



#Preview {
    MissionDetailView(mission: Mission(title: "오늘하루 계획 짜봐", detailText: "sdsdsdsdsdsd", category: "E"))
}
