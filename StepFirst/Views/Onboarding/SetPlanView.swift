import SwiftUI

struct SetPlanView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Received Flow ViewModel
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Set Your Plan!")
                .font(.largeTitleBold)
                .padding(.top, 12)
                .padding(.bottom, 28)
            
            // MARK: STEP GOALS
            SectionHeader(
                icon: "figure.walk.motion",
                title: "STEP GOALS",
                subtitle: "Set the steps required to temporarily unlock the specific apps you chose to restrict"
            )
            
            StepGoalCard(stepGoals: $viewModel.stepGoals)
                .padding(.bottom, 28)
            
            // MARK: SCREEN TIME EARNED
            SectionHeader(
                icon: "clock.fill",
                title: "SCREEN TIME EARNED",
                subtitle: "Choose how much extra screen time you are rewarded with after successfully completing your step goals"
            )

            ScreenTimeEarnedCard(timeEarned: $viewModel.timeEarned)
                .padding(.bottom, 28)

            Spacer()

            Button {
                viewModel.completeOnboarding()
            } label: {
                Text("Start Plan")
                    .font(.headlineSemibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.indigo)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                            .font(.headlineSemibold)
                        Text("Back")
                            .font(.bodyRegular)
                    }
                    .foregroundStyle(.indigo)
                }
            }
        }
    }
}

// MARK: - Isolated Slider Card
struct StepGoalCard: View {
    @Binding var stepGoals: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Steps")
                    .font(.bodyRegular)
                Spacer()
                Text("\(Int(stepGoals))")
                    .font(.headlineSemibold)
                    .foregroundStyle(.indigo)
            }
            
            Slider(value: $stepGoals, in: 50...2000, step: 10)
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
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Isolated Screen Time Card
struct ScreenTimeEarnedCard: View {
    @Binding var timeEarned: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Allowance Duration")
                    .font(.bodyRegular)
                
                Spacer()
                
                Picker("Reward Time", selection: $timeEarned) {
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
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    SetPlanView(viewModel: OnboardingViewModel())
}
