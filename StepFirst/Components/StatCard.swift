import SwiftUI


struct StatCardView: View {
    let icon: String
    let title: String
    let value: String
    let tintColor: Color
    let infoAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(tintColor)
                
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: infoAction) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

