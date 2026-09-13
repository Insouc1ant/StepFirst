import SwiftUI

struct HeroProgressRing: View {
    let isLocked: Bool
    let timeEarned: Int
    let stepsWalked: Int
    let stepTarget: Int
    
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

            // Dynamic Text inside the circle
            VStack(spacing: 8) {
                if !isLocked {
                    // UNLOCKED STATE
                    Image(systemName: "lock.open.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    
                    Text("\(timeEarned) Min")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    
                    Text("Allowance Active")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    // LOCKED STATE
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                    
                    Text("\(stepsWalked)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    
                    Text("of \(stepTarget) steps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 280, height: 280)
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
