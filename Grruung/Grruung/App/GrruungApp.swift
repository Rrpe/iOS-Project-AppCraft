//
//  GrruungApp.swift
//  Grruung
//
//  Created by NoelMacMini on 4/30/25.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseAppCheck // App Check 추가
import StoreKit // 유료 구매를 위해서 추가

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // ✅ AppCheck Debug Provider 먼저 지정
#if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
#endif
        
        // Firebase 초기화
        FirebaseApp.configure()
        
        // Firestore 설정
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
        
        // 로그인된 사용자가 있는지 확인하고 데이터 프리페치
        if let userID = Auth.auth().currentUser?.uid {
            Task {
                await FirebaseService.shared.preFetchInitialData(userID: userID)
            }
        }
        
        return true
    }
}

@main
struct GrruungApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService()
    // 구매 여부 확인
    @StateObject private var transactionObserver = TransactionObserver()
    // 유저 정보
    @StateObject private var userViewModel = UserViewModel()
    // 동산 정보
    @StateObject private var characterDexViewModel = CharacterDexViewModel()
    // 인벤토리 정보
    @StateObject private var userInventoryViewModel = UserInventoryViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GRAnimationMetadata.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(transactionObserver)
                .environmentObject(userViewModel)
                .environmentObject(characterDexViewModel)
                .environmentObject(userInventoryViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
