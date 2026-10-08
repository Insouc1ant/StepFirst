import SwiftUI

struct StatusIndicatorView: View {
    let isLocked: Bool
    let stepTarget: Int
    let timeEarned: Int
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Text(isLocked ? "Apps Locked" : "Apps Available")
                    .font(.subheadlineSemibold)
            }
            .foregroundStyle(isLocked ? Color(uiColor: .systemRed) : Color(uiColor: .systemGreen))

            Text(isLocked
                 ? "Walk \(stepTarget) steps to unlock your restricted apps for \(timeEarned) minutes."
                 : "Your restricted apps will automatically lock when this timer reaches zero.")
                .font(.footnoteRegular)
                .foregroundStyle(Color(uiColor: .systemGray))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 340, minHeight: 36, alignment: .top)
                .padding(.horizontal, 32)
        }
    }
}
