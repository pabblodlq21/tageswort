import SwiftUI

struct ContentView: View {
    @StateObject private var speech = SpeechService.shared
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            // TimelineView recalcula cada minuto, así la palabra cambia sola al
            // entrar una nueva franja de 2 h, igual que el widget.
            TimelineView(.periodic(from: .now, by: 60)) { context in
                let now = context.date
                let word = WordStore.word(for: now)

                ScrollView {
                    VStack(spacing: 24) {
                        todayCard(word: word, now: now)
                        upcomingSection(now: now)
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Tageswort")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Ajustes")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        // Al abrir desde el widget (tageswort://speak) se pronuncia la palabra actual.
        .onOpenURL { url in
            if url.host == "speak" || url.absoluteString.contains("speak") {
                speech.speakGerman(WordStore.current.display)
            }
        }
    }

    private func todayCard(word: Word, now: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("PALABRA AHORA")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.85))
                    .tracking(1.5)
                Spacer()
                Text("Cambia \(nextChangeText(now: now))")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(word.display)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                speakerButton(for: word.display, size: 30)
            }

            Text(word.spanish)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))

            Divider().overlay(.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 10) {
                    Text(word.example)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    speakerButton(for: word.example, size: 20)
                }
                Text(word.exampleTranslation)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            LinearGradient(colors: [Color.indigo, Color.purple],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }

    /// Botón de altavoz que pronuncia `text` en alemán.
    private func speakerButton(for text: String, size: CGFloat) -> some View {
        Button {
            speech.speakGerman(text)
        } label: {
            Image(systemName: speech.isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(.white)
                .symbolEffect(.variableColor.iterative, isActive: speech.isSpeaking)
                .padding(8)
                .background(.white.opacity(0.18), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Pronunciar en alemán")
    }

    private func upcomingSection(now: Date) -> some View {
        // Próximas 4 franjas de 2 h con su hora de inicio.
        let slots: [(date: Date, word: Word)] = (1...4).compactMap { i in
            guard let d = Calendar.current.date(byAdding: .hour,
                                                value: i * WordStore.slotHours,
                                                to: WordStore.slotStart(for: now)) else { return nil }
            return (d, WordStore.word(for: d))
        }

        return VStack(alignment: .leading, spacing: 12) {
            Text("Próximas palabras")
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(slots, id: \.date) { slot in
                HStack {
                    Text(slot.date, format: .dateTime.hour().minute())
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 64, alignment: .leading)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(slot.word.display).font(.body.weight(.semibold))
                        Text(slot.word.spanish).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    /// Texto relativo de cuándo cambia la palabra, p. ej. "en 1 h 23 min".
    private func nextChangeText(now: Date) -> String {
        let next = WordStore.nextSlotStart(after: now)
        let minutes = max(0, Int(next.timeIntervalSince(now) / 60))
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return "en \(h) h \(m) min" }
        return "en \(m) min"
    }
}

#Preview {
    ContentView()
}
