//
//  ContentView.swift
//  TimerApp
//
//  Created by KimJunsoo on 1/24/25.
//

import SwiftUI
import MusicKit
import AVFoundation

struct ContentView: View {
    
    @State private var timeRemaining: Int = 60 // 기본값 초 단위
    @State private var isRunning: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var timeSet = ["1분", "2분", "3분", "5분", "10분", "15분", "30분", "60분",
                   "작업", "휴식", "점심시간"]
    @State var selectedTimeSet = ""
    @State var lastTimeSet: Int = 60
    @State var totalTime: Int = 60
    
    @State private var audioPlayer: AVAudioPlayer? // 오디오 플레이어
    @State private var musicPlayer = ApplicationMusicPlayer.shared // AppleMusicKit 플레이어
    
    @State private var isEndTimeSoundEnabled: Bool = true // 종료 사운드 토글 상태
    @State private var isAlwaysOnTop: Bool = true         // 윈도우 레벨 토글 상태
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Text("\(String(format: "%02d", timeRemaining / 60)):\(String(format: "%02d", timeRemaining % 60))")
                    .font(.system(size: 50, weight: .bold))
                
                // 종료 시간 표시
                if !selectedTimeSet.isEmpty {
                    Text("종료 시간: \(EndTime())")
                        .font(.system(size: 15))
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    isRunning.toggle()
                }, label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding()
                })
                Button(action: {
                    timeRemaining = lastTimeSet
                    isRunning = false
                }, label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding()
                })
            }
            
            Spacer()
            
            Form {
                VStack {
                    Picker(selection: $selectedTimeSet, label: Text("")) {
                        Section {
                            ForEach(["1분", "2분", "3분", "5분", "10분", "15분", "30분", "60분"], id: \.self) { new in
                                Text(new).tag(new)
                            }
                        }
                    }
                    .frame(width: 200)
                    
                    HStack {
                        Picker(selection: $selectedTimeSet, label: Text("")) {
                            Section {
                                ForEach(["수업", "휴식", "식사"], id: \.self) { new  in
                                    Text(new).tag(new)
                                }
                            }
                        }
                        .padding(.top, 10)
                        .frame(width: 100)
                    }
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedTimeSet) { old, new in
                if let timeInMinutes = Int(new.replacingOccurrences(of: "분", with: "")) {
                    timeRemaining = timeInMinutes * 60 // 분 -> 초 변환
                    lastTimeSet = timeInMinutes * 60
                } else if new == "수업" {
                    timeRemaining = 3000
                    lastTimeSet = 3000
                } else if new == "휴식" {
                    timeRemaining = 600
                    lastTimeSet = 600
                } else if new == "식사" {
                    timeRemaining = 4200
                    lastTimeSet = 4200
                }
            }
            Spacer()
//            Test
            
        }
        .frame(minWidth: 300, minHeight: 300)
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Menu {
                    Toggle("타이머 종료 사운드 활성화", isOn: $isEndTimeSoundEnabled)
                    Toggle("항상 위에 고정", isOn: $isAlwaysOnTop)
                        .onChange(of: isAlwaysOnTop) {
                            AlwaysOnTop()
                        }
                } label: {
                    Label("설정", systemImage: "gearshape")
                }
            }
        }
        .onReceive(timer) { _ in
            //            print("timer tick \(t)")
            if isRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                isRunning = false
                if isEndTimeSoundEnabled {
                    EndTimeSound()
                    //playCustomAppleMusic() // 애플 뮤직 연동
                }
                timeRemaining = lastTimeSet
            } else {
                // ignore
            }
        }
        .onAppear {
            AlwaysOnTop()
        }
    }
    
    
    
    // 화면 최상위에 나오게
    func AlwaysOnTop() {
        if let window = NSApplication.shared.windows.first {
            window.level = isAlwaysOnTop ? .floating : .normal
            //window.level = .normal   // 기본
        }
    }
    
    // 종료 시간 계산
    func EndTime() -> String {
        let currentTime = Date() // 현재 시간
        let endTime = currentTime.addingTimeInterval(TimeInterval(timeRemaining)) // 종료 시간 계산
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium // .short 시간만 표시 (예: 10:30 PM)
        return formatter.string(from: endTime)
    }
    
    // 타이머 종료 사운드
    func EndTimeSound() {
        guard audioPlayer?.isPlaying != true else {
            return // 이미 재생 중이라면 실행하지 않음
        }
        
        guard let soundPath = Bundle.main.path(forResource: "기상나팔", ofType: "mp3") else {
            print("사운드 파일을 찾을 수 없습니다.")
            return
        }
        
        let soundURL = URL(fileURLWithPath: soundPath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = 0 // -1은 무한 반복
            audioPlayer?.play()
        } catch {
            print("사운드 재생 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    // Apple Music 권한 요청
    func requestAppleMusicAuthorization() {
        Task {
            do {
                let status = await MusicAuthorization.request()
                if status == .authorized {
                    print("Apple Music 권한 허용됨")
                } else {
                    print("Apple Music 권한 거부됨")
                }
            }
        }
    }
    
    // Apple Music 재생 - 어떻게 쓰는지 ?
    func playCustomAppleMusic() {
        Task {
            do {
                // 특정 곡 검색 (곡 이름과 아티스트를 바꿔서 사용)
                let searchRequest = MusicCatalogSearchRequest(term: "노래 제목", types: [Song.self])
                let response = try await searchRequest.response()
                if let song = response.songs.first {
                    try await musicPlayer.queue.insert(song, position: .tail)
                    try await musicPlayer.play()
                } else {
                    print("노래를 찾을 수 없습니다.")
                }
            } catch {
                print("Apple Music 재생 오류: \(error)")
            }
        }
    }
    
    var Test: some View {
        // 테스트용 버튼
        Button(action: {
            timeRemaining = 5 // 10초 설정
            isRunning = true // 즉시 타이머 시작
        }) {
            Text("테스트")
                .font(.title2)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}
