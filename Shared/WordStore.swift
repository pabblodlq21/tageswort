import Foundation

/// Carga el catálogo de palabras y elige, de forma determinista, la palabra de
/// cada franja horaria. La palabra cambia cada `slotHours` horas (por defecto, 2),
/// alineada a la medianoche local (00:00, 02:00, 04:00, …).
///
/// La misma fecha/hora siempre devuelve la misma palabra (en la app y en el widget),
/// recorriendo todo el catálogo en bucle.
enum WordStore {

    /// Cada cuántas horas cambia la palabra.
    static let slotHours = 2
    /// Número de franjas por día (24 / slotHours).
    static var slotsPerDay: Int { 24 / slotHours }

    /// Catálogo cargado una sola vez desde `words.json` incluido en el bundle del target.
    static let all: [Word] = {
        guard
            let url = Bundle.main.url(forResource: "words", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let words = try? JSONDecoder().decode([Word].self, from: data),
            !words.isEmpty
        else {
            return [Word(id: 0, german: "Wort", article: "das", spanish: "la palabra",
                         english: "the word", example: "Das ist ein neues Wort.",
                         exampleTranslation: "Esta es una palabra nueva.")]
        }
        return words
    }()

    /// Índice de franja global: días transcurridos * franjas por día + franja del día.
    private static func slotIndex(for date: Date, calendar: Calendar = .current) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        let epoch = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
        let days = calendar.dateComponents([.day], from: epoch, to: startOfDay).day ?? 0
        let hour = calendar.component(.hour, from: date)
        return days * slotsPerDay + (hour / slotHours)
    }

    /// Palabra correspondiente a una fecha/hora dada.
    static func word(for date: Date, calendar: Calendar = .current) -> Word {
        let count = all.count
        guard count > 0 else {
            return all.first ?? Word(id: 0, german: "Wort", article: "das",
                                     spanish: "la palabra", english: "the word",
                                     example: "Das ist ein Wort.", exampleTranslation: "Esto es una palabra.")
        }
        let index = ((slotIndex(for: date, calendar: calendar) % count) + count) % count
        return all[index]
    }

    /// Palabra de la franja actual.
    static var current: Word { word(for: Date()) }

    /// Inicio de la franja de 2 h que contiene a `date` (p. ej. 14:37 → 14:00).
    static func slotStart(for date: Date, calendar: Calendar = .current) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let hour = calendar.component(.hour, from: date)
        let slotStartHour = (hour / slotHours) * slotHours
        return calendar.date(bySettingHour: slotStartHour, minute: 0, second: 0, of: startOfDay) ?? date
    }

    /// Inicio de la siguiente franja (cuándo cambiará la palabra).
    static func nextSlotStart(after date: Date, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .hour, value: slotHours, to: slotStart(for: date, calendar: calendar)) ?? date
    }
}
