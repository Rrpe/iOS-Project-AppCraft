//
//  ListView.swift
//  FixMBTI
//
//  Created by KimJunsoo on 2/4/25.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var posts: [PostMission]
    @State var stackPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $stackPath) {
            
            if posts.isEmpty {
                ContentUnavailableView("게시물 없음", systemImage: "doc.text")
            } else {
                List {
                    ForEach(posts) { post in
                        NavigationLink(destination: ListDetailView(post: post)) {
                            ListCellView(post: post)
                        }
                    }
                    .onDelete { index in
                        deletePost(at: index)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("게시물")
                            .font(.headline)
                    }
                }
            }
        }
    }
    
    // 게시물 삭제 함수
    private func deletePost(at indexSet: IndexSet) {
        for index in indexSet {
            let postToDelete = posts[index]
            
            // 이미지 삭제
            if let imageName = postToDelete.imageName {
                deleteImage(named: imageName)
            }
            
            modelContext.delete(postToDelete)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("게시물 삭제 실패: \(error)")
        }
    }
    
    // 이미지 파일 삭제 함수
    private func deleteImage(named: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(named)
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}

struct ListCellView: View {
    var post: PostMission
    
    // 이미지 로드 함수 추가
    private func loadImage(fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let imagePath = documentsDirectory?.appendingPathComponent(fileName) {
            return UIImage(contentsOfFile: imagePath.path)
        }
        return nil
    }
    
    var body: some View {
        ScrollView {
            HStack {
                // 이미지 표시 로직 변경
                if let imageName = post.imageName,
                   let uiImage = loadImage(fileName: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 85)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 85)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                
                Spacer()
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                    Text("\(post.timestamp.formatted(date: .numeric, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(post.detailText)
                        .font(.caption2)
                    Spacer()
                    
                    Text(post.content)
                        .font(.footnote)
                        .foregroundColor(.primary)
                    Spacer()
                }
                Spacer()
            }
            .padding(.vertical, 5)
        }
    }
}


#Preview {
    ListView()
}
