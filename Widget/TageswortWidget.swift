import WidgetKit
import SwiftUI

/// Una entrada de la línea de tiempo: la palabra que se muestra a partir de `date`.
struct WordEntry: TimelineEntry {
    let date: Date
    let word: Word
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), word: WordStore.today)
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        completion(WordEntry(date: Date(), word: WordStore.today))
    }

    /// Genera una entrada por día para los próximos 7 días, cada una a partir de su medianoche.
    /// Así el widget rota solo aunque el sistema tarde en pedir una recarga.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        var entries: [WordEntry] = []
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) else { continue }
            entries.append(WordEntry(date: day, word: WordStore.word(for: day, calendar: calendar)))
        }

        // Tras el último día, pedir una nueva línea de tiempo.
        let refresh = calendar.date(byAdding: .day, value: 7, to: startOfToday) ?? Date()
        completion(Timeline(entries: entries, policy: .after(refresh)))
    }
}

struct TageswortWidgetEntryView: View {
    var entry: WordEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ALEMÁN DEL DÍA")
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
        .configurationDisplayName("Palabra del día")
        .description("Aprende una palabra nueva de alemán cada día.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    TageswortWidget()
} timeline: {
    WordEntry(date: .now, word: WordStore.today)
}
