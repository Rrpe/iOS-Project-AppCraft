//
//  WriteStoryView.swift
//  Grruung
//
//  Created by NO SEONGGYEONG on 5/2/25.
//

import SwiftUI
import PhotosUI

enum ViewMode {
    case create
    case read
    case edit
}

struct WriteStoryView: View {
    
    @StateObject private var viewModel = WriteStoryViewModel()
    @StateObject private var writingCountVM = WritingCountViewModel()
    @StateObject private var charDetailVM: CharacterDetailViewModel
    
    @EnvironmentObject private var authService: AuthService
    
    @Environment(\.dismiss) var dismiss
    
    @State var currentMode: ViewMode
    var characterUUID: String
    var postID: String?
    private var isImageDelete: Bool = false // 이미지 삭제 여부
    
    @State private var currentPost: GRPost? = nil
    @State private var postBody: String = ""
    @State private var postTitle: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil // 새로 선택/변경한 이미지 데이터
    @State private var displayedImage: UIImage? = nil // 화면에 표시될 최종 이미지
    @State private var showDeleteAlert = false
    
    @State private var showNoWritingCountAlert = false
    
    @State private var isImageLoading = false
    @State private var isUploading = false
    
    @FocusState private var isTextEditorFocused: Bool
    
    private var isPlaceholderVisible: Bool {
        postBody.isEmpty
    }
    
    private var isTitlePlaceholderVisible: Bool {
        postTitle.isEmpty
    }
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        if currentMode == .edit || currentMode == .read {
            return formatter.string(from: currentPost?.createdAt ?? Date())
        }
        return formatter.string(from: Date())
    }
    
    private var navigationTitle: String {
        switch currentMode {
        case .create:
            return "이야기 들려주기"
        case .read:
            return "이야기 보기"
        case .edit:
            return "이야기 다시 들려주기"
        }
    }
    
    private var buttonTitle: String {
        switch currentMode {
        case .read:
            return "닫기"
        case .edit:
            return "저장"
        case .create:
            return "저장"
        }
    }
    
    init(currentMode: ViewMode, characterUUID: String, postID: String? = nil) {
        self.currentMode = currentMode
        self.characterUUID = characterUUID
        self.postID = postID
        self._charDetailVM = StateObject(wrappedValue: CharacterDetailViewModel(characterUUID: characterUUID))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 날짜 헤더
                dateHeaderView
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                
                // 메인 일기 카드
                VStack(spacing: 0) {
                    // 이미지 섹션
                    imageSection
                    
                    // 텍스트 컨텐츠 섹션
                    contentSection
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                }
                .background(Color.white)
                .cornerRadius(UIConstants.cornerRadius)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .padding(.bottom, 30)
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(colors: [
                Color(GRColor.mainColor1_1),
                Color(GRColor.mainColor1_2),
            ], startPoint: .top, endPoint: .bottom)
        )
        .onTapGesture {
            isTextEditorFocused = false
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupViewforCurrentMode()
            writingCountVM.initialize(with: authService)
            
            if currentMode == .create {
                // 잠시 대기 후 체크 (초기화 시간 확보)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    checkWritingCount()
                }
            }
        }
        .interactiveDismissDisabled(isUploading)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 왼쪽(뒤로가기) 버튼 추가
            if currentMode == .create {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundStyle(GRColor.mainColor6_2)
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(GRColor.subColorOne) // 갈색으로 변경
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            // 오른쪽(저장/수정) 버튼
            ToolbarItem(placement: .navigationBarTrailing) {
                if currentMode == .read {
                    Menu {
                        Button(action: {
                            // 편집 모드로 변경
                            currentMode = .edit
                            setupViewforCurrentMode()
                        }) {
                            Label("수정하기", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            showDeleteAlert = true
                        }) {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(GRColor.mainColor6_2)
                    }
                } else {
                    saveButton
                }
            }
        }
        .alert("이야기를 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                deletePost()
            }
        } message: {
            Text("삭제된 이야기는 복구할 수 없습니다.")
        }
        .alert("글쓰기 횟수 부족", isPresented: $showNoWritingCountAlert) {
            Button("취소", role: .cancel) {
                if currentMode == .create {
                    dismiss()
                }
            }
            Button("구매하기") {
                // TODO : 상점으로 이동하는 로직 추가
                print("상점으로 이동")
            }
        } message: {
            Text("글쓰기 횟수가 부족합니다. 내일 작성하거나 상점에서 아이템을 구매해주세요.")
        }
    }
    
    // MARK: - 날짜 헤더 뷰
    private var dateHeaderView: some View {
        HStack {
            Text(currentDateString)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(GRColor.fontMainColor)
            
            Spacer()
        }
    }
    
    // MARK: - 이미지 섹션
    private var imageSection: some View {
        VStack {
            if isImageLoading {
                loadingIndicator
            } else if let displayedImage = displayedImage {
                if currentMode == .read {
                    diaryImageView(uiImage: displayedImage)
                } else {
                    diaryImageView(uiImage: displayedImage)
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        self.selectedImageData = nil
                                        self.displayedImage = nil
                                        self.selectedPhotoItem = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                    }
                                    .padding(16)
                                }
                                Spacer()
                            }
                        )
                }
            } else if currentMode != .read {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    imagePickerPlaceholder
                }
                .onChange(of: selectedPhotoItem) { newItem in
                    guard let newItem = newItem else { return }
                    
                    isImageLoading = true
                    
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            if let uiImage = UIImage(data: data) {
                                displayedImage = uiImage
                            }
                        } else {
                            print("이미지 로딩 중 오류 발생")
                            selectedImageData = nil
                        }
                        
                        isImageLoading = false
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var readModeImageView: some View {
        Group {
            if isImageLoading {
                loadingIndicator
            } else if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                diaryImageView(uiImage: uiImage)
            } else if let displayedImage = displayedImage {
                diaryImageView(uiImage: displayedImage)
            }
        }
    }
    
    private var editModeImageView: some View {
        VStack(spacing: 0) {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                if isImageLoading {
                    loadingIndicator
                } else if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    diaryImageView(uiImage: uiImage)
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        selectedImageData = nil
                                        displayedImage = nil
                                        selectedPhotoItem = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(.white)
                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                    }
                                    .padding(16)
                                }
                                Spacer()
                            }
                        )
                } else if let existingImage = displayedImage {
                    diaryImageView(uiImage: existingImage)
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        selectedImageData = nil
                                        displayedImage = nil
                                        selectedPhotoItem = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(.white)
                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                    }
                                    .padding(16)
                                }
                                Spacer()
                            }
                        )
                } else {
                    imagePickerPlaceholder
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    } else {
                        print("이미지 로딩 중 오류 발생")
                        selectedImageData = nil
                    }
                }
            }
        }
    }
    
    private func diaryImageView(uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .cornerRadius(UIConstants.cornerRadius)
            .padding()
    }
    
    private var imagePickerPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.circle")
                .font(.system(size: 50))
                .foregroundStyle(Color(GRColor.buttonColor_1))
            
            VStack(spacing: 4) {
                Text("사진 보여주기")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("사진을 추가하여 \(charDetailVM.character.name)에게 들려줄 이야기를 더 풍성하게 만들어보세요!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius, style: .continuous)
                .fill(Color(GRColor.mainColor5_1).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: UIConstants.cornerRadius, style: .continuous)
                        .stroke(Color(GRColor.mainColor5_1).opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                )
        )
        .cornerRadius(UIConstants.cornerRadius)
    }
    
    private var contentSection: some View {
        VStack(spacing: 20) {
            if currentMode == .read {
                readModeContent
            } else {
                editModeContent
            }
        }
    }
    
    private var readModeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 제목
            Text(currentPost?.postTitle ?? "")
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(nil)
                .foregroundStyle(.primary)
            
            // 구분선
            Rectangle()
                .fill(Color(GRColor.mainColor5_1).opacity(0.2))
                .frame(height: 1)
            
            // 내용
            Text(currentPost?.postBody ?? "")
                .font(.body)
                .lineSpacing(6)
                .lineLimit(nil)
                .foregroundStyle(.primary)
        }
    }
    
    // .create, .edit 모드에서의 내용 입력 섹션
    private var editModeContent: some View {
        VStack(spacing: 20) {
            // MARK: - 주제 입력
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(Color(GRColor.buttonColor_1))
                    Text("주제")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                ZStack(alignment: .topLeading) {
                    TextField("", text: $postTitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                                .fill(Color(.systemGray6))
                        )
                        .focused($isTextEditorFocused) // TextField도 동일한 FocusState 사용 가능
                    
                    if isTitlePlaceholderVisible {
                        Text("어떤 주제에 대해 이야기할까요?")
                            .foregroundStyle(Color(.placeholderText))
                            .font(.title3)
                            .padding(16)
                            .allowsHitTesting(false)
                    }
                }
            }
            
            // MARK: - 이야기 입력
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "heart.circle.fill")
                        .foregroundStyle(Color(GRColor.buttonColor_1))
                    Text("이야기")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $postBody)
                        .font(.body)
                        .lineSpacing(4)
                        .padding(12)
                        .frame(minHeight: 180)
                        .background(
                            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                                .fill(Color(.systemGray6))
                        )
                        .scrollContentBackground(.hidden)
                        .focused($isTextEditorFocused)
                    
                    if isPlaceholderVisible {
                        Text("오늘 하루 \(charDetailVM.character.name)에게 들려주고 싶은 이야기를 써보세요.\n\n어떤 일이 있었나요? 어떤 기분이었나요?\n소소한 일상도 좋아요 ✨")
                            .foregroundStyle(Color(.placeholderText))
                            .font(.body)
                            .lineSpacing(4)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }
    
    // MARK: - 저장 버튼
    private var saveButton: some View {
        Button {
            Task {
                isUploading = true
                
                do {
                    print("우측 상단 button tapped!")
                    
                    if currentMode == .create {
                        // 글쓰기 시도 (튜플 반환값 적절히 처리)
                        let (success, expReward) = writingCountVM.tryToWrite()
                        
                        if success {
                            // 글 저장
                            let _ = try await viewModel.createPost(
                                characterUUID: characterUUID,
                                postTitle: postTitle,
                                postBody: postBody,
                                imageData: selectedImageData
                            )
                            
                            // 보상 획득 가능하면 보상 추가
                            if expReward {
                                await addRewardForWriting(characterUUID: characterUUID)
                            }
                            
                            isUploading = false
                            dismiss()
                        } else {
                            isUploading = false
                            showNoWritingCountAlert = true
                            print("글쓰기 횟수가 부족합니다")
                        }
                    } else if currentMode == .edit {
                        // 수정된 ViewModel 함수 사용
                        try await viewModel.editPost(
                            postID: currentPost?.postID ?? "",
                            postTitle: postTitle,
                            postBody: postBody,
                            newImageData: selectedImageData,
                            existingImageUrl: currentPost?.postImage ?? "",
                            deleteImage: displayedImage == nil && selectedImageData == nil
                        )
                        isUploading = false
                        dismiss()
                    } else {
                        isUploading = false
                        dismiss()
                    }
                } catch {
                    isUploading = false
                    print("Error saving post: \(error)")
                }
            }
            
            if let imageData = selectedImageData {
                print("Image data size: \(imageData.count) bytes")
            } else {
                print("No image selected.")
            }
        } label: {
            HStack {
                Text(buttonTitle)
                    .padding(.trailing, 5)
            }
        }
        .disabled(currentMode != .read && (postBody.isEmpty || postTitle.isEmpty))
        .opacity(isUploading ? 0 : 1) // 업로드 중일 때 버튼 숨기기
        .overlay(
            Group {
                if isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                }
            }
        )
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    currentMode == .read ? Color(GRColor.buttonColor_2) :
                        (postBody.isEmpty || postTitle.isEmpty) ? Color.gray.opacity(0.5) : Color(GRColor.buttonColor_2)
                )
        )
        .scaleEffect((currentMode != .read && (postBody.isEmpty || postTitle.isEmpty)) ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: postBody.isEmpty || postTitle.isEmpty)
    }
    
    // MARK: - Original Methods (유지)
    
    private func setupViewforCurrentMode() {
        if currentMode == .create {
            postBody = ""
            selectedPhotoItem = nil
            selectedImageData = nil
            displayedImage = nil
            currentPost = nil
            
        } else if let postIdToLoad = postID, (currentMode == .read || currentMode == .edit) {
            Task {
                do {
                    let fetchedPost = try await viewModel.findPost(postID: postIdToLoad)
                    self.currentPost = fetchedPost
                    if let post = fetchedPost {
                        self.postBody = post.postBody
                        self.postTitle = post.postTitle
                        if !post.postImage.isEmpty {
                            loadImageFrom(urlString: post.postImage)
                        } else {
                            self.displayedImage = nil
                            self.selectedImageData = nil
                        }
                    } else {
                        print("Post not found.")
                    }
                } catch {
                    print("Error in setupViewforCurrentMode: \(error)")
                }
            }
        }
    }
    
    // MARK: - 이미지 로딩 함수
    private func loadImageFrom(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            self.displayedImage = nil
            return
        }
        isImageLoading = true // 로딩 시작
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                self.displayedImage = UIImage(data: data)
                isImageLoading = false
            } catch {
                print("Error loading image: \(error)")
                isImageLoading = false
            }
        }
        
    }
    
    //    private func handleSaveOrUpdate() {
    //        let characterUUID = currentPost?.characterUUID ?? ""
    //
    //        Task {
    //            do {
    //                if currentMode == .create {
    //                    let newPostId = try await viewModel.createPost(
    //                        characterUUID: characterUUID,
    //                        postTitle: postTitle,
    //                        postBody: postBody,
    //                        imageData: selectedImageData // 새로 선택된 이미지 데이터 전달
    //                    )
    //                    print("새 게시물 ID: \(newPostId)")
    //                } else if currentMode == .edit, let postToEdit = currentPost {
    //                    try await viewModel.editPost(
    //                        postID: postToEdit.postID,
    //                        postTitle: postTitle,
    //                        postBody: postBody,
    //                        newImageData: selectedImageData, // 새로 선택된 이미지 데이터 전달
    //                        existingImageUrl: postToEdit.postImage // 기존 이미지 URL 전달
    //                    )
    //
    //
    //                    print("게시물 수정 완료, ID: \(postToEdit.postID)")
    //                }
    //                dismiss()
    //            } catch {
    //                print("저장/수정 중 오류 발생: \(error)")
    //            }
    //        }
    //    }
    
    // MARK: - 로딩 인디케이터 뷰
    private var loadingIndicator: some View {
        ZStack {
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
        }
        .padding()
    }
    
    // MARK: - 게시물 삭제 함수
    private func deletePost() {
        guard let postID = postID else { return }
        
        Task {
            do {
                try await viewModel.deletePost(postID: postID)
                dismiss()
            } catch {
                print("게시물 삭제 중 오류 발생: \(error)")
            }
        }
    }
    
    // MARK: - 글쓰기 횟수 체크 함수
    private func checkWritingCount() {
        // userWritingCount가 있고, 글쓰기 가능 여부를 확인
        guard let count = writingCountVM.userWritingCount else { return }
        
        // dailyRewardCount를 기반으로 글쓰기 가능 여부 확인
        let canWrite = count.remainingRewards > 0
        
        if !canWrite {
            showNoWritingCountAlert = true
        }
    }
    
    // MARK: - 경험치 및 골드 추가 함수
    private func addRewardForWriting(characterUUID: String) async {
        do {
            // 고정된 보상 값
            let exp = 50
            let gold = 100
            
            // 경험치와 골드 추가 함수 호출
            try await FirebaseService.shared.addExpAndGold(
                characterID: characterUUID,
                exp: exp,
                gold: gold
            )
        } catch {
            print("⚠️ 보상 추가 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        WriteStoryView(currentMode: .edit, characterUUID: "39C50A01-C374-4455-A0B9-38EF092ECEF8")
            .environmentObject(AuthService())
    }
}
