import SwiftUI
import SwiftData

@main
struct Steps_to_UnlockApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        exportAppLogoToSharedGroup()
    }

    private func exportAppLogoToSharedGroup() {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kee.StepFirst") else {
            return
        }
        let targetURL = groupURL.appendingPathComponent("AppLogo.png")
        if !FileManager.default.fileExists(atPath: targetURL.path) {
            if let sourcePath = Bundle.main.path(forResource: "AppLogo", ofType: "png") {
                try? FileManager.default.copyItem(atPath: sourcePath, toPath: targetURL.path)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
