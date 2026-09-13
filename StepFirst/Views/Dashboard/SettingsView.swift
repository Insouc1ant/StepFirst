import SwiftUI
import ManagedSettings
import FamilyControls

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - ViewModel (Single Source of Truth)
    @State private var viewModel = SettingsViewModel()
    
    // MARK: - Notice Alert State
    @State private var showingNoticeAlert = false
    @State private var noticeTitle = ""
    @State private var noticeMessage = ""
    
    // MARK: - UI Layout Constants (Pure Visual styling)
    private let rowHeight: CGFloat = 56
    private let maxListHeight: CGFloat = 336 // 56 * 6 rows
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Section 1: APPS
                    SectionHeader(
                        icon: "app.shadow",
                        title: "RESTRICTED APPS",
                        subtitle: "Select apps to restrict once your allowance is reached.\nThese apps require walking to unlock."
                    )
                    .padding(.top, 36)
                    
                    Button {
                        viewModel.isPickerPresented = true
                    } label: {
                        HStack {
                            Text(!viewModel.hasValidSelection ? "Manage Locked Apps" : "\(viewModel.totalSelectionsCount) Selections Added")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tint(.indigo)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    
                    // COMBINED LIST: Categories + Individual Apps
                    if viewModel.hasValidSelection {
                        Spacer().frame(height: 16)

                        Text("Selected Items")
                            .font(.headlineSemibold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)

                        ScrollView(showsIndicators: viewModel.totalSelectionsCount > 6) {
                            VStack(spacing: 0) {
                                
                                // 1. Loop through Categories First
                                ForEach(Array(viewModel.selectedCategoryTokens.enumerated()), id: \.element) { index, token in
                                    VStack(spacing: 0) {
                                        HStack(spacing: 12) {
                                            Label(token)
                                                .labelStyle(.scaledIcon)
                                                .font(.caption)
                                                .foregroundStyle(.primary)

                                            Spacer()
                                        }
                                        .frame(height: rowHeight)
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
                                                .font(.caption)
                                                .foregroundStyle(.primary)

                                            Spacer()
                                        }
                                        .frame(height: rowHeight)
                                        .padding(.horizontal, 16)

                                        if index < viewModel.selectedApplicationTokens.count - 1 {
                                            Divider().padding(.leading, 58)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: min(CGFloat(viewModel.totalSelectionsCount) * rowHeight, maxListHeight))
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    
                    // MARK: - Section 2: STEP GOALS
                    SectionHeader(
                        icon: "figure.walk.motion",
                        title: "STEP GOALS",
                        subtitle: "Set the steps required to temporarily unlock the specific apps you chose to restrict"
                    )
                    .padding(.top, 36)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Steps")
                                .font(.bodyRegular)
                            Spacer()
                            Text("\(Int(viewModel.stepGoals))")
                                .font(.headlineSemibold)
                                .foregroundStyle(.indigo)
                        }
                        
                        Slider(value: $viewModel.stepGoals, in: 50...2000, step: 10)
                            .tint(.indigo)
                        
                        HStack {
                            Text("50")
                                .font(.captionRegular)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("2000")
                                .font(.captionRegular)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    // MARK: - Section 3: SCREEN TIME EARNED
                    SectionHeader(
                        icon: "clock.fill",
                        title: "SCREEN TIME EARNED",
                        subtitle: "Choose how much extra screen time you are rewarded with after successfully completing your step goals"
                    )
                    .padding(.top, 36)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Allowance Duration")
                                .font(.bodyRegular)
                            
                            Spacer()
                            
                            Picker("Reward Time", selection: $viewModel.timeEarned) {
                                Text("1 Minute").tag(1)
                                Text("15 Minutes").tag(15)
                                Text("30 Minutes").tag(30)
                                Text("45 Minutes").tag(45)
                                Text("1 Hour").tag(60)
                                Text("1.5 Hours").tag(90)
                                Text("2 Hours").tag(120)
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .systemIndigo))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)

            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            
            // MARK: - Modifiers
            .familyActivityPicker(
                isPresented: $viewModel.isPickerPresented,
                selection: $viewModel.selectedApps
            )
            .onChange(of: viewModel.selectedApps) { _, newSelection in
                viewModel.updateSelectedApps(newSelection)
            }
            .onAppear {
                viewModel.loadSettings()
            }
            .onDisappear {
                viewModel.saveSettings()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", systemImage: "checkmark") {
                        if let notice = viewModel.saveAndCheckNotice() {
                            noticeTitle = notice.title
                            noticeMessage = notice.message
                            showingNoticeAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .labelStyle(.iconOnly)
                    .font(.headlineSemibold)
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
            }
            .alert(noticeTitle, isPresented: $showingNoticeAlert) {
                Button("Got it", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(noticeMessage)
            }
        }
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        SettingsView()
    }
}
