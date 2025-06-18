//
//  WriteStoryViewModel.swift
//  Grruung
//
//  Created by NO SEONGGYEONG on 5/7/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage


class WriteStoryViewModel: ObservableObject {
    @Published var posts: [GRPost] = []
    
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage() // Firebase Storage (이미지 업로드용)
    
    private func uploadImageToStorage(imageData: Data) async throws -> String {
        let imageName = UUID().uuidString + ".jpg"
        let imageRef = storage.reference().child("post_images/\(imageName)") // "post_images" 폴더에 저장
        
        do {
            // 2. Firebase Storage에 이미지 데이터 업로드
            print("Firebase Storage로 이미지 데이터 (\(imageData.count) 바이트) 업로드 중 ...")
            let _ = try await imageRef.putDataAsync(imageData, metadata: nil) // async/await를 위해 putDataAsync 사용
            
            // 3. 다운로드 URL 가져오기
            let downloadURL = try await imageRef.downloadURL()
            let urlString = downloadURL.absoluteString
            print("Firebase Storage에 이미지 업로드 완료: \(urlString)")
            return urlString
        } catch {
            print("Firebase Storage에 이미지 업로드 실패: \(error)")
            throw error
        }
    }
    
    
    func createPost(characterUUID: String, postTitle: String, postBody: String, imageData: Data?) async throws -> String {
        
        var imageUrlToSave: String = ""
        
        if let data = imageData {
            imageUrlToSave = try await uploadImageToStorage(imageData: data)
        }
        
        let newPostData: [String: Any] = [
            "characterUUID": characterUUID,
            "postTitle": postTitle,
            "postImage": imageUrlToSave,
            "postBody": postBody,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        
        do {
            let documentReference = try await db.collection("GRPost").addDocument(data: newPostData)
            print("게시물 생성 완료. ID: \(documentReference.documentID)")
            return documentReference.documentID
        } catch {
            print("게시물 생성 중 오류 발생: \(error)")
            throw error
        }
    }
    
    func editPost(postID: String, postTitle: String, postBody: String, newImageData: Data?, existingImageUrl: String?, deleteImage: Bool) async throws {
        
        var imageUrlToSave = existingImageUrl ?? ""
        
        if let data = newImageData {
            print("새 이미지 데이터 \(data.count) 바이트를 업로드 중입니다...")
            
            
            // 1. 기존 이미지가 있다면 Firebase Storage에서 삭제
            //    - existingImageUrl이 비어있지 않고,
            //    - 유효한 URL이며,
            //    - Firebase Storage URL인 경우에만 삭제 시도
            if let oldUrlString = existingImageUrl,
               !oldUrlString.isEmpty,
               let oldUrl = URL(string: oldUrlString) ,
               oldUrl.host?.contains("firebasestorage.googleapis.com") ?? false {
                
                let oldImageRef = storage.reference(forURL: oldUrlString)
                do {
                    try await oldImageRef.delete()
                    print("기존 이미지 삭제 완료: \(oldUrlString)")
                } catch {
                    print("기존 이미지 삭제 실패: \(error)")
                }
            }
            
            // 2. 새 이미지를 Firebase Storage에 업로드
            imageUrlToSave = try await uploadImageToStorage(imageData: data)
        } else if deleteImage {
            // 이미지를 삭제하는 경우
            imageUrlToSave = ""
            
            // 기존 이미지가 있다면 스토리지에서 삭제
            if let oldUrlString = existingImageUrl,
               !oldUrlString.isEmpty,
               let oldUrl = URL(string: oldUrlString),
               oldUrl.host?.contains("firebasestorage.googleapis.com") ?? false {
                
                let oldImageRef = storage.reference(forURL: oldUrlString)
                do {
                    try await oldImageRef.delete()
                    print("기존 이미지 삭제 완료: \(oldUrlString)")
                } catch {
                    print("기존 이미지 삭제 실패: \(error)")
                }
            }
        }
        do {
            try await db.collection("GRPost").document(postID).updateData([
                "postTitle": postTitle,
                "postImage": imageUrlToSave,
                "postBody": postBody,
                "updatedAt": Timestamp(date: Date())
            ])
            print("Post updated with ID: \(postID)")
        } catch {
            throw error
        }
    }
    
    func deletePost(postID: String) async throws {
        do {
            try await db.collection("GRPost").document(postID).delete()
        } catch {
            throw error
        }
    }
    
    func findPost(postID: String) async throws -> GRPost? {
        do {
            let document = try await db.collection("GRPost").document(postID).getDocument()
            
            guard let data = document.data() else {
                print("Document with ID \(postID) does not exist or has no data.")
                return nil
            }
            print("Post found with ID: \(postID)")
            return GRPost(
                postID: document.documentID,
                characterUUID: data["characterUUID"] as? String ?? "",
                postTitle: data["postTitle"] as? String ?? "",
                postBody: data["postBody"] as? String ?? "",
                postImage: data["postImage"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
            )
        } catch {
            throw error
        }
    }
}
