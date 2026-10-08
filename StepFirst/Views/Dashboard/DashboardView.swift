import SwiftUI
import FamilyControls

struct DashboardView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - ViewModel (Single Source of Truth for this Screen)
    @State private var viewModel = DashboardViewModel()
    
    // MARK: - Pure UI State (Only controls modals/alerts)
    @State private var showingSettings = false
    @State private var showingInfoAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @ScaledMetric(relativeTo: .largeTitle) private var settingsIconSize: CGFloat = 32

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                stepAvailabilitySection
                progressSection
                statusSection
                cardsSection
            }
            .padding(.bottom, 24)
            .readableWidth()
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert(alertTitle, isPresented: $showingInfoAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: showingSettings) { _, isShowing in
            if !isShowing {
                viewModel.refreshDashboard()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refreshDashboard()
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .center) {
            Text("Dashboard")
                .font(.largeTitleBold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer()

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(settingsIconSize, 44), height: min(settingsIconSize, 44))
                    .foregroundStyle(Color(uiColor: .systemGray2))
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel("Settings")
        }
        .padding(.top, 24)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private var stepAvailabilitySection: some View {
        if !viewModel.canCountSteps {
            StepAvailabilityNotice(availability: viewModel.stepAvailability)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
        }
    }

    private var progressSection: some View {
        HeroProgressRing(
            isLocked: viewModel.lockStatus,
            timeEarned: viewModel.currentAllowanceMinutes,
            stepsWalked: viewModel.currentSteps,
            stepTarget: viewModel.stepTarget
        )
        .padding(.vertical, 24)
    }

    private var statusSection: some View {
        StatusIndicatorView(
            isLocked: viewModel.lockStatus,
            stepTarget: viewModel.stepTarget,
            timeEarned: viewModel.timeEarned
        )
        .padding(.vertical, 16)
    }

    private var cardsSection: some View {
        VStack(spacing: 16) {
            // Restricted Apps Card
            if viewModel.hasRestrictedApps {
                restrictedAppsCard
            }
            
            // Steps Today Card
            StatCardView(
                icon: "figure.walk.motion",
                title: "Steps Today",
                value: "\(viewModel.liveSteps)",
                tintColor: .orange
            ) {
                alertTitle = "Steps Today"
                alertMessage = "Your total physical steps recorded today. Resets everyday at midnight."
                showingInfoAlert = true
            }
        }
        .padding(.horizontal, 24)
    }

    private var restrictedAppsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "app.shadow")
                    .foregroundStyle(.indigo)
                Text("Restricted Apps")
                    .font(.footnoteSemibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    alertTitle = "Restricted Apps"
                    alertMessage = "These are the apps and categories that will automatically lock when your timer reaches zero."
                    showingInfoAlert = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.bodyRegular)
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .accessibilityLabel("About Restricted Apps")
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(viewModel.selectedCategoryTokens.enumerated()), id: \.element) { _, token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.3)
                            .frame(width: 38, height: 38)
                    }
                    
                    ForEach(Array(viewModel.selectedApplicationTokens.enumerated()), id: \.element) { _, token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.3)
                            .frame(width: 38, height: 38)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .frame(height: 58)
            .padding(.bottom, 8)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    DashboardView()
}
