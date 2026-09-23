import WidgetKit
import SwiftUI
import ActivityKit

@main
struct PetWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetLiveActivity()
    }
}

struct SmallPet: View {
    let kind: String
    let state: PetAttributes.ContentState

    var body: some View {
        PetSpriteView(kind: kind, frame: state.frame)
            .frame(width: 26, height: 22)
            .scaleEffect(x: state.facingRight ? 1 : -1, y: 1)
    }
}

struct PetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetAttributes.self) { context in
            // Kilit ekrani
            PetWalkStrip(kind: context.attributes.petKind, state: context.state)
                .frame(height: 60)
                .padding(.horizontal)
                .activityBackgroundTint(Color.black.opacity(0.6))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    PetWalkStrip(kind: context.attributes.petKind, state: context.state)
                        .frame(height: 44)
                }
            } compactLeading: {
                if context.state.position < 0.5 {
                    SmallPet(kind: context.attributes.petKind, state: context.state)
                } else {
                    Text("🐾").font(.system(size: 12))
                }
            } compactTrailing: {
                if context.state.position >= 0.5 {
                    SmallPet(kind: context.attributes.petKind, state: context.state)
                } else {
                    Text("🐾").font(.system(size: 12))
                }
            } minimal: {
                SmallPet(kind: context.attributes.petKind, state: context.state)
            }
        }
    }
}
