import SwiftUI

/// "Allowance Duration" label plus its menu picker.
/// Sits side by side as before, and stacks at accessibility text sizes so the picker never breaks apart.
struct AllowanceDurationRow: View {
    @Binding var timeEarned: Int
    var cornerRadius: CGFloat = 10

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) {
                label
                picker
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack {
                label
                Spacer(minLength: 8)
                picker
                    .fixedSize()
            }
        }
    }

    private var label: some View {
        Text("Allowance Duration")
            .font(.bodyRegular)
    }

    private var picker: some View {
        Picker("Reward Time", selection: $timeEarned) {
            Text("5 Minutes").tag(5)
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
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
