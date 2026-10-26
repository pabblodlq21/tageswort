import Foundation

/// Una palabra de alemán con su artículo, traducciones y un ejemplo de uso.
struct Word: Codable, Identifiable, Hashable {
    let id: Int
    let german: String
    /// Artículo definido: "der", "die", "das". Nil para palabras sin artículo (verbos, adjetivos...).
    let article: String?
    let spanish: String
    let english: String
    let example: String
    let exampleTranslation: String

    /// Forma completa para mostrar: "das Haus" o solo "lernen" si no tiene artículo.
    var display: String {
        if let article, !article.isEmpty {
            return "\(article) \(german)"
        }
        return german
    }
}
