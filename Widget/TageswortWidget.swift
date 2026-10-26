import WidgetKit
import SwiftUI

/// Una entrada de la línea de tiempo: la palabra que se muestra a partir de `date`.
struct WordEntry: TimelineEntry {
    let date: Date
    let word: Word
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), word: WordStore.current)
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        completion(WordEntry(date: Date(), word: WordStore.current))
    }

    /// Genera una entrada por cada franja de 2 h de las próximas 24 h, alineadas al
    /// inicio de cada franja. Así el widget rota solo cada 2 h aunque el sistema
    /// tarde en pedir una recarga.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let calendar = Calendar.current
        let start = WordStore.slotStart(for: Date(), calendar: calendar)
        let slotCount = WordStore.slotsPerDay   // 12 franjas = 24 h de cobertura

        var entries: [WordEntry] = []
        for i in 0..<slotCount {
            guard let slot = calendar.date(byAdding: .hour, value: i * WordStore.slotHours, to: start)
            else { continue }
            entries.append(WordEntry(date: slot, word: WordStore.word(for: slot, calendar: calendar)))
        }

        // Tras cubrir el día, pedir una nueva línea de tiempo.
        let refresh = calendar.date(byAdding: .hour, value: slotCount * WordStore.slotHours, to: start) ?? Date()
        completion(Timeline(entries: entries, policy: .after(refresh)))
    }
}

struct TageswortWidgetEntryView: View {
    var entry: WordEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ALEMÁN · CADA 2 H")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
                .tracking(1)

            Text(entry.word.display)
                .font(.system(size: family == .systemSmall ? 20 : 26,
                               weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
                .lineLimit(2)

            Text(entry.word.spanish)
                .font(.system(size: family == .systemSmall ? 13 : 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)

            if family != .systemSmall {
                Spacer(minLength: 2)
                Text(entry.word.example)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(entry.word.exampleTranslation)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            LinearGradient(colors: [Color.indigo, Color.purple],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        // Al tocar el widget se abre la app y pronuncia la palabra del día.
        .widgetURL(URL(string: "tageswort://speak"))
    }
}

struct TageswortWidget: Widget {
    let kind: String = "TageswortWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TageswortWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Palabra de alemán")
        .description("Aprende una palabra nueva de alemán cada 2 horas.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    TageswortWidget()
} timeline: {
    WordEntry(date: .now, word: WordStore.current)
}
