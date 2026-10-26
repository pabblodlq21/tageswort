import Foundation

/// Carga el catálogo de palabras y elige, de forma determinista, la palabra del día.
///
/// La misma fecha siempre devuelve la misma palabra (en la app y en el widget),
/// y la palabra avanza una posición cada día, recorriendo todo el catálogo en bucle.
enum WordStore {

    /// Catálogo cargado una sola vez desde `words.json` incluido en el bundle del target.
    static let all: [Word] = {
        guard
            let url = Bundle.main.url(forResource: "words", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let words = try? JSONDecoder().decode([Word].self, from: data),
            !words.isEmpty
        else {
            // Fallback para que la UI nunca quede vacía si falta el recurso.
            return [Word(id: 0, german: "Wort", article: "das", spanish: "la palabra",
                         english: "the word", example: "Das ist ein neues Wort.",
                         exampleTranslation: "Esta es una palabra nueva.")]
        }
        return words
    }()

    /// Número de días transcurridos desde una época fija, en la zona horaria actual.
    private static func dayIndex(for date: Date, calendar: Calendar = .current) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        let epoch = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
        let days = calendar.dateComponents([.day], from: epoch, to: startOfDay).day ?? 0
        return days
    }

    /// Palabra correspondiente a una fecha dada.
    static func word(for date: Date, calendar: Calendar = .current) -> Word {
        let count = all.count
        guard count > 0 else {
            return all.first ?? Word(id: 0, german: "Wort", article: "das",
                                     spanish: "la palabra", english: "the word",
                                     example: "Das ist ein Wort.", exampleTranslation: "Esto es una palabra.")
        }
        let index = ((dayIndex(for: date, calendar: calendar) % count) + count) % count
        return all[index]
    }

    /// Palabra de hoy.
    static var today: Word { word(for: Date()) }
}
