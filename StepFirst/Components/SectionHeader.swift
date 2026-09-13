import SwiftUI

struct SectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(title)
                    .font(.footnoteBold)
            }
            .foregroundStyle(.secondary)
            
            Text(subtitle)
                .font(.footnoteRegular)
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)
        }
    }
}

#Preview {
    DashboardView()
}
