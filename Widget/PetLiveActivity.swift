import WidgetKit
import SwiftUI
import ActivityKit

@main
struct PetWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetLiveActivity()
        TestWidget()
    }
}

func petEmoji(_ kind: String) -> String {
    switch kind {
    case "dog": return "🐕"
    case "bunny": return "🐇"
    default: return "🐈"
    }
}

struct EmojiPet: View {
    let kind: String
    let state: PetAttributes.ContentState
    var size: CGFloat = 18

    var body: some View {
        Text(petEmoji(kind))
            .font(.system(size: size))
            .scaleEffect(x: state.facingRight ? -1 : 1, y: 1)
            .offset(y: state.frame == 0 ? 0 : -2)
    }
}

struct EmojiWalkStrip: View {
    let kind: String
    let state: PetAttributes.ContentState
    var size: CGFloat = 30

    var body: some View {
        GeometryReader { geo in
            EmojiPet(kind: kind, state: state, size: size)
                .frame(width: size + 6, height: size + 6)
                .offset(x: max(0, geo.size.width - size - 6) * CGFloat(state.position),
                        y: max(0, geo.size.height - size - 6) / 2)
        }
    }
}

struct PetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetAttributes.self) { context in
            EmojiWalkStrip(kind: context.attributes.petKind, state: context.state)
                .frame(height: 60)
                .padding(.horizontal)
                .activityBackgroundTint(Color.black.opacity(0.6))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    EmojiWalkStrip(kind: context.attributes.petKind, state: context.state)
                        .frame(height: 44)
                }
            } compactLeading: {
                if context.state.position < 0.5 {
                    EmojiPet(kind: context.attributes.petKind, state: context.state)
                } else {
                    Text("🐾").font(.system(size: 12))
                }
            } compactTrailing: {
                if context.state.position >= 0.5 {
                    EmojiPet(kind: context.attributes.petKind, state: context.state)
                } else {
                    Text("🐾").font(.system(size: 12))
                }
            } minimal: {
                Text(petEmoji(context.attributes.petKind)).font(.system(size: 14))
            }
        }
    }
}

// Ana ekran test widget'i
struct TestEntry: TimelineEntry { let date: Date }

struct TestProvider: TimelineProvider {
    func placeholder(in context: Context) -> TestEntry { TestEntry(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (TestEntry) -> Void) {
        completion(TestEntry(date: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<TestEntry>) -> Void) {
        completion(Timeline(entries: [TestEntry(date: Date())], policy: .never))
    }
}

extension View {
    @ViewBuilder func testBackground() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(Color.orange, for: .widget)
        } else {
            self.background(Color.orange)
        }
    }
}

struct TestWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TestWidget", provider: TestProvider()) { _ in
            VStack(spacing: 4) {
                Text("🐈🐕🐇").font(.title)
                Text("Eklenti çalışıyor!").font(.caption).bold()
            }
            .testBackground()
        }
        .configurationDisplayName("Ada Hayvanları Test")
        .supportedFamilies([.systemSmall])
    }
}
