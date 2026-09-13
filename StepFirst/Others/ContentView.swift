import SwiftUI

struct ContentView: View {
    @AppStorage(StorageKey.hasCompletedOnboarding) var hasCompletedOnboarding: Bool = false
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                DashboardView()
            } else {
                NavigationStack {
                    LockedAppsView()
                }
            }

            if isShowingSplash {
                Image("SplashScreen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.35)) {
                    isShowingSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
