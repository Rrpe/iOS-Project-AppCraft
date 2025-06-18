//
//  FirebaseImageView.swift
//  Grruung
//
//  Created by mwpark on 6/2/25.
//

import SwiftUI
import FirebaseStorage

struct FirebaseImageView: View {
    let imageName: String
    @State private var uiImage: UIImage? = nil

    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
            } else {
                Image("CatLion")
                    .resizable()
//                ProgressView() // 로딩 표시
            }
        }
        .onAppear {
            // TODO: - 파베 스토리지에 저장할 경우 경로로 불러오기
            loadImageFromFirebase(path: "/quokka_growth_stages/\(imageName)") { image in
                self.uiImage = image
            }
        }
    }

    private func loadImageFromFirebase(path: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference(withPath: path)
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("이미지 다운로드 실패: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
}
