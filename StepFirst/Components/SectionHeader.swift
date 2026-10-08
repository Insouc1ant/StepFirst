import SwiftUI

struct SectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String

    @ScaledMetric(relativeTo: .footnote) private var iconSize: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                Text(title)
                    .font(.footnoteBold)
            }
            .foregroundStyle(.secondary)
            
            Text(subtitle)
                .font(.footnoteRegular)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 12)
        }
    }
}

#Preview {
    DashboardView()
}
