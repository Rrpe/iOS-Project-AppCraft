//
//  ListDetailView.swift
//  FixMBTI
//
//  Created by KimJunsoo on 2/4/25.
//

import SwiftUI
import SwiftData

struct ListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let post: PostMission
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // 이미지 로드 로직 추가
                if let imageName = post.imageName,
                   let uiImage = loadImage(fileName: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Text(post.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text(post.timestamp.formatted(date: .numeric, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                Text(post.detailText)
                    .font(.body)
                    .padding(.horizontal)
                
                Text(post.content)
                    .font(.body)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                    Spacer()
                    Button("Delete") {
                        deletePost()
                        dismiss()
                    }
                    Spacer()
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical)
        }
        .navigationTitle("게시물 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deletePost() {
        // 게시물 삭제 로직 추가
        modelContext.delete(post)
    }
    
    // 이미지 로드 함수
    private func loadImage(fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let imagePath = documentsDirectory?.appendingPathComponent(fileName) {
            return UIImage(contentsOfFile: imagePath.path)
        }
        return nil
    }
}

#Preview {
}
