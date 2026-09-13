import SwiftUI

struct StatusIndicatorView: View {
    let isLocked: Bool
    let stepTarget: Int
    let timeEarned: Int
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Text(isLocked ? "Apps Locked" : "Apps Available")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(isLocked ? Color(uiColor: .systemRed) : Color(uiColor: .systemGreen))

            Text(isLocked
                 ? "Walk \(stepTarget) steps to unlock your restricted apps\nfor \(timeEarned) minutes."
                 : "Your restricted apps will automatically lock when\nthis timer reaches zero.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color(uiColor: .systemGray))
                .multilineTextAlignment(.center)
                .frame(height: 36, alignment: .top)
                .padding(.horizontal, 32)
        }
    }
}
