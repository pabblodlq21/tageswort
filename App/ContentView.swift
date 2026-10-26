import SwiftUI

struct ContentView: View {
    // La palabra de hoy; es la misma que muestra el widget.
    private let word = WordStore.today

    // Previsualización de los próximos días para motivar el regreso diario.
    private var upcoming: [Word] {
        (1...5).map { offset in
            WordStore.word(for: Calendar.current.date(byAdding: .day, value: offset, to: Date())!)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    todayCard
                    upcomingSection
                }
                .padding()
            }
            .navigationTitle("Tageswort")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PALABRA DEL DÍA")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)

            Text(word.display)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(word.spanish)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))

            Divider().overlay(.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 6) {
                Text(word.example)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
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

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Próximas palabras")
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(upcoming) { w in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(w.display).font(.body.weight(.semibold))
                        Text(w.spanish).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
}

#Preview {
    ContentView()
}
