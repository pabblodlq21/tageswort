import SwiftUI

@main
struct TageswortApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Rellena la ventana de recordatorios con palabras actualizadas.
                    NotificationService.shared.reschedule()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                NotificationService.shared.reschedule()
            }
        }
    }
}
