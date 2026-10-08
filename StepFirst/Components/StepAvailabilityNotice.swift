import SwiftUI

/// Explains why steps can't be counted and what that means for locking.
struct StepAvailabilityNotice: View {
    let availability: StepAvailability
    @Environment(\.openURL) private var openURL

    var body: some View {
        if availability != .available {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadlineSemibold)
                    .foregroundStyle(.orange)

                Text(message)
                    .font(.footnoteRegular)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if availability == .denied {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .font(.subheadlineSemibold)
                    .buttonStyle(.bordered)
                    .tint(.indigo)
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityElement(children: .contain)
        }
    }

    private var title: String {
        availability == .denied ? "Motion & Fitness Access Is Off" : "Step Counting Isn't Available"
    }

    private var message: String {
        if availability == .denied {
            return "StepFirst needs Motion & Fitness access to count your steps. Your apps won't be locked until access is turned on."
        }
        return "This device can't count steps. StepFirst needs an iPhone with motion tracking, so your apps won't be locked on this device."
    }
}

#Preview {
    VStack(spacing: 16) {
        StepAvailabilityNotice(availability: .unsupported)
        StepAvailabilityNotice(availability: .denied)
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
