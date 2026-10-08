import SwiftUI
import FamilyControls
import ManagedSettings

struct LockedAppsView: View {
    // MARK: - Flow ViewModel (Created here, passed to SetPlanView)
    @State private var viewModel = OnboardingViewModel()
    
    // MARK: - UI Layout Constants
    @ScaledMetric(relativeTo: .footnote) private var rowHeight: CGFloat = 56
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Which apps distract you?")
                    .font(.largeTitleBold)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 60)
                    .padding(.horizontal, 16)

                Spacer().frame(height: 32)

                if viewModel.stepAvailability != .available {
                    StepAvailabilityNotice(availability: viewModel.stepAvailability)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }

                SectionHeader(
                    icon: "app.shadow",
                    title: "RESTRICTED APPS",
                    subtitle: "Select apps to restrict once your allowance is reached. These apps require walking to unlock."
                )
                .padding(.top, 12)
                .padding(.horizontal, 16)

                Spacer().frame(height: 8)

                Button {
                    viewModel.requestPermissionsAndShowPicker()
                } label: {
                    HStack(spacing: 16) {
                        Text(viewModel.hasValidSelection ? "\(viewModel.totalSelectionsCount) Selections Added" : "Select Apps to Restrict")
                            .font(.bodyRegular)
                            .foregroundStyle(.primary)
                            .tint(.indigo)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if viewModel.isRequestingPermission {
                            ProgressView()
                                .tint(.indigo)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.headlineSemibold)
                                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(viewModel.isRequestingPermission)
                .padding(.horizontal, 16)

                // 📦 COMBINED LIST: Categories + Individual Apps
                if viewModel.hasValidSelection {
                    Spacer().frame(height: 20)

                    Text("Selected Items")
                        .font(.headlineSemibold)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {

                        // 1. Loop through Categories First
                        ForEach(Array(viewModel.selectedCategoryTokens.enumerated()), id: \.element) { index, token in
                            VStack(spacing: 0) {
                                HStack(spacing: 12) {
                                    Label(token)
                                        .labelStyle(.scaledIcon)
                                        .font(.footnoteRegular)
                                        .foregroundStyle(.primary)

                                    Spacer()
                                }
                                .frame(minHeight: rowHeight)
                                .padding(.horizontal, 16)

                                if index < viewModel.selectedCategoryTokens.count - 1 || !viewModel.selectedApplicationTokens.isEmpty {
                                    Divider().padding(.leading, 58)
                                }
                            }
                        }

                        // 2. Loop through Individual Apps Second
                        ForEach(Array(viewModel.selectedApplicationTokens.enumerated()), id: \.element) { index, token in
                            VStack(spacing: 0) {
                                HStack(spacing: 12) {
                                    Label(token)
                                        .labelStyle(.scaledIcon)
                                        .font(.footnoteRegular)
                                        .foregroundStyle(.primary)

                                    Spacer()
                                }
                                .frame(minHeight: rowHeight)
                                .padding(.horizontal, 16)

                                if index < viewModel.selectedApplicationTokens.count - 1 {
                                    Divider().padding(.leading, 58)
                                }
                            }
                        }
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .readableWidth()
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            viewModel.refreshStepAvailability()
        }

        .safeAreaInset(edge: .bottom) {
            NavigationLink(destination: SetPlanView(viewModel: viewModel)) {
                Text("Continue")
                    .font(.headlineSemibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.indigo)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .disabled(!viewModel.hasValidSelection)
            .readableWidth()
            .padding(.top, 12)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
        
        .familyActivityPicker(
            isPresented: $viewModel.isPickerPresented,
            selection: $viewModel.selectedApps
        )
        .onChange(of: viewModel.selectedApps) { _, newSelection in
            viewModel.updateSelectedApps(newSelection)
        }
    }
}

#Preview {
    LockedAppsView()
}
