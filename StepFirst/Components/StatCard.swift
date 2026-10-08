import SwiftUI


struct StatCardView: View {
    let icon: String
    let title: String
    let value: String
    let tintColor: Color
    let infoAction: () -> Void

    @ScaledMetric(relativeTo: .footnote) private var iconSize: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(tintColor)
                
                Text(title)
                    .font(.footnoteSemibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: infoAction) {
                    Image(systemName: "info.circle")
                        .font(.bodyRegular)
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .accessibilityLabel("About \(title)")
            }
            
            Text(value)
                .font(.titleRoundedBold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

