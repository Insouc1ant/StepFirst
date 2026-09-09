import SwiftUI
import FamilyControls
import ManagedSettings

struct LockedAppsView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var isPickerPresented = false
    @State private var isRequestingPermission = false
    @State private var selectedApps = FamilyActivitySelection()
    private let rowHeight: CGFloat = 56
    private let maxListHeight: CGFloat = 280

    private var selectedCategoryTokens: [ActivityCategoryToken] {
        Array(selectedApps.categoryTokens)
    }

    private var selectedApplicationTokens: [ApplicationToken] {
        Array(selectedApps.applicationTokens)
    }

    private var totalSelectionsCount: Int {
        selectedCategoryTokens.count + selectedApplicationTokens.count
    }

    private var hasValidSelection: Bool {
        totalSelectionsCount > 0
    }

    private var selectedCategoriesListHeight: CGFloat {
        min(CGFloat(selectedCategoryTokens.count) * rowHeight, maxListHeight)
    }

    private var selectedAppsListHeight: CGFloat {
        min(CGFloat(selectedApplicationTokens.count) * rowHeight, maxListHeight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Which apps distract\nyou?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.top, 60)
                .padding(.leading, 16)
            
            Spacer().frame(height: 32)
            
            SectionHeader(
                icon: "app.shadow",
                title: "RESTRICTED APPS",
                subtitle: "Select apps to restrict once your allowance is reached.\nThese apps require walking to unlock."
            )
            .padding(.top, 12)
            .padding(.leading, 16)
            
            Spacer().frame(height: 8)
            
            Button {
                requestPermissionsAndShowPicker()
            } label: {
                HStack(spacing: 16) {
                    Text(hasValidSelection ? "\(totalSelectionsCount) Selections Added" : "Select Apps to Restrict")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .tint(.indigo)
                    
                    Spacer()
                    
                    if isRequestingPermission {
                        ProgressView()
                            .tint(.indigo)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(uiColor: .tertiaryLabel))
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(isRequestingPermission)
            .padding(.horizontal, 16)

            // 📦 COMBINED LIST: Categories + Individual Apps
        if hasValidSelection {
            Spacer().frame(height: 20)

            Text("Selected Items")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            ScrollView(showsIndicators: totalSelectionsCount > 4) {
                VStack(spacing: 0) {
                    
                    // 1. Loop through Categories First
                    ForEach(Array(selectedCategoryTokens.enumerated()), id: \.element) { index, token in
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                // Use Apple's magic Label for Categories too!
                                Label(token)
                                    .labelStyle(.titleAndIcon)
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                Spacer()
                            }
                            .frame(height: rowHeight)
                            .padding(.horizontal, 16)

                            // Show divider unless it's the absolute last item in the combined list
                            if index < selectedCategoryTokens.count - 1 || !selectedApplicationTokens.isEmpty {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                    
                    // 2. Loop through Individual Apps Second
                    ForEach(Array(selectedApplicationTokens.enumerated()), id: \.element) { index, token in
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Label(token)
                                    .labelStyle(.titleAndIcon)
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                Spacer()
                            }
                            .frame(height: rowHeight)
                            .padding(.horizontal, 16)

                            if index < selectedApplicationTokens.count - 1 {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                }
            }
            // Dynamically size the box based on total items
            .frame(height: min(CGFloat(totalSelectionsCount) * rowHeight, maxListHeight))
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }

            Spacer()
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())

        .safeAreaInset(edge: .bottom) {
            NavigationLink(destination: SetPlanView()) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.indigo)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .disabled(!hasValidSelection)
        }
        
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $selectedApps
        )

        .onChange(of: selectedApps) { oldValue, newValue in
            // Don't block them yet! Just save them for when the timer hits zero.
            ScreenTimeManager.shared.saveSelection(newValue)
        }
    }
    
    // MARK: - Logic
    
    private func requestPermissionsAndShowPicker() {
        Task {
            do {
                // 1. Request permission (Pop-up will only show the first time)
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                
                // 2. If granted, slide up the native picker sheet
                isPickerPresented = true
            } catch {
                print("Permission denied: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    LockedAppsView()
}
