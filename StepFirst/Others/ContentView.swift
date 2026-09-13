import SwiftUI

struct ContentView: View {
    @AppStorage(StorageKey.hasCompletedOnboarding) var hasCompletedOnboarding: Bool = false

    var body: some View {
        if hasCompletedOnboarding {
            DashboardView()
        } else {
            NavigationStack {
                LockedAppsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
