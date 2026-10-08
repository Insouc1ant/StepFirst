import SwiftUI

struct HeroProgressRing: View {
    let isLocked: Bool
    let timeEarned: Int
    let stepsWalked: Int
    let stepTarget: Int

    // Grows with Dynamic Type (capped), and shrinks to fit narrow windows.
    @ScaledMetric(relativeTo: .largeTitle) private var ringDiameter: CGFloat = 280
    private let maxRingDiameter: CGFloat = 360
    
    var ringColor: Color {
        !isLocked ? .indigo : .orange
    }
    
    var progressAmount: Double {
        if !isLocked {
            return 1.0 // Unlocked? The ring is 100% full.
        } else {
            // Locked? The ring fills up as they walk!
            return min(1.0, Double(stepsWalked) / Double(stepTarget))
        }
    }
    
    var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 24)
            
            // Progress Fill
            Circle()
                .trim(from: 0.0, to: progressAmount)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progressAmount)
                .animation(.easeInOut, value: ringColor) // Smooth color transition

            // Dynamic Text inside the circle, kept within the ring's inner area
            GeometryReader { geo in
                ringContent
                    .frame(width: geo.size.width * 0.64, height: geo.size.height * 0.64)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: min(ringDiameter, maxRingDiameter))
        .padding(.horizontal, 24)
    }

    private var ringContent: some View {
        VStack(spacing: 8) {
            if !isLocked {
                // UNLOCKED STATE
                Image(systemName: "lock.open.fill")
                    .font(.title)
                    .foregroundStyle(.green)

                Text("\(timeEarned) Min")
                    .font(.largeTitleRoundedBold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                Text("Allowance Active")
                    .font(.subheadlineSemibold)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            } else {
                // LOCKED STATE
                Image(systemName: "lock.fill")
                    .font(.title)
                    .foregroundStyle(.red)

                Text("\(stepsWalked)")
                    .font(.largeTitleRoundedBold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                Text("of \(stepTarget) steps")
                    .font(.subheadlineSemibold)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
        }
        .multilineTextAlignment(.center)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}

#Preview {
    VStack(spacing: 40) {
        // Preview Unlocked State
        HeroProgressRing(isLocked: false, timeEarned: 30, stepsWalked: 0, stepTarget: 200)
        
        // Preview Locked State (Halfway done walking)
        HeroProgressRing(isLocked: true, timeEarned: 30, stepsWalked: 100, stepTarget: 200)
    }
}
