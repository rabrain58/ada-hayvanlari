import SwiftUI
import ActivityKit
import UIKit

struct Pet: Identifiable {
    let id: String
    let name: String
}

struct ContentView: View {
    let pets = [Pet(id: "cat", name: "Kedi"), Pet(id: "dog", name: "Köpek"), Pet(id: "bunny", name: "Tavşan")]

    @State private var selected = "cat"
    @State private var activity: Activity<PetAttributes>?
    @State private var state = PetAttributes.ContentState(position: 0.2, facingRight: true, frame: 0)
    @State private var timer: Timer?
    @State private var bgTask: UIBackgroundTaskIdentifier = .invalid
    @State private var message = ""
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 24) {
            Text("Ada Hayvanları").font(.title.bold())

            HStack(spacing: 14) {
                ForEach(pets) { pet in
                    Button { selected = pet.id } label: {
                        VStack(spacing: 6) {
                            PetSpriteView(kind: pet.id, frame: 0).frame(width: 64, height: 54)
                            Text(pet.name).font(.caption)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selected == pet.id ? Color.accentColor.opacity(0.25) : Color.gray.opacity(0.12))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(activity != nil)
                }
            }

            if activity == nil {
                Button("Başlat") { start() }
                    .buttonStyle(.borderedProminent).controlSize(.large)
            } else {
                Button("Durdur", role: .destructive) { stop() }
                    .buttonStyle(.bordered).controlSize(.large)
            }

            Text(message)
                .font(.footnote).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            if let existing = Activity<PetAttributes>.activities.first {
                activity = existing
                selected = existing.attributes.petKind
                startTimer()
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                bgTask = UIApplication.shared.beginBackgroundTask {
                    UIApplication.shared.endBackgroundTask(bgTask)
                    bgTask = .invalid
                }
            } else if phase == .active, bgTask != .invalid {
                UIApplication.shared.endBackgroundTask(bgTask)
                bgTask = .invalid
            }
        }
    }

    func start() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            message = "Canlı Etkinlikler kapalı. Ayarlar > Ada Hayvanları bölümünden açın."
            return
        }
        do {
            let content = ActivityContent(state: state, staleDate: nil)
            activity = try Activity.request(attributes: PetAttributes(petKind: selected), content: content)
            message = "Hayvan Dynamic Island'da! Uygulama açıkken yürür."
            startTimer()
        } catch {
            message = "Başlatılamadı: \(error.localizedDescription)"
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        let current = activity
        activity = nil
        message = ""
        Task { await current?.end(nil, dismissalPolicy: .immediate) }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in tick() }
    }

    func tick() {
        var s = state
        let step = 0.08
        s.position += s.facingRight ? step : -step
        if s.position >= 1 { s.position = 1; s.facingRight = false }
        if s.position <= 0 { s.position = 0; s.facingRight = true }
        s.frame = (s.frame == 0) ? 1 : 0
        state = s
        let current = activity
        Task { await current?.update(ActivityContent(state: s, staleDate: nil)) }
    }
}
