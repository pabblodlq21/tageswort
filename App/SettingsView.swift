import SwiftUI

/// Ajustes del recordatorio diario: activar/desactivar y elegir la hora.
struct SettingsView: View {
    @ObservedObject private var notifications = NotificationService.shared
    @Environment(\.dismiss) private var dismiss

    // Hora elegida como `Date` para el DatePicker; se sincroniza con el servicio.
    @State private var time: Date = Date()
    @State private var deniedAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Recordatorio diario", isOn: Binding(
                        get: { notifications.isEnabled },
                        set: { newValue in
                            Task {
                                await notifications.setEnabled(newValue)
                                if newValue && !notifications.isEnabled {
                                    deniedAlert = true   // el permiso fue denegado
                                }
                            }
                        }
                    ))

                    if notifications.isEnabled {
                        DatePicker("Hora", selection: $time, displayedComponents: .hourAndMinute)
                            .onChange(of: time) { _, newValue in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                notifications.time = comps
                                notifications.reschedule()
                            }
                    }
                } header: {
                    Text("Notificaciones")
                } footer: {
                    Text("Recibe cada día la palabra de alemán a la hora que elijas. Puedes cambiar o desactivar esto cuando quieras.")
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
            .onAppear {
                time = Calendar.current.date(bySettingHour: notifications.hour,
                                             minute: notifications.minute,
                                             second: 0, of: Date()) ?? Date()
            }
            .alert("Permiso de notificaciones", isPresented: $deniedAlert) {
                Button("Abrir Ajustes") { openSystemSettings() }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Activa las notificaciones para Tageswort en Ajustes ▸ Notificaciones para recibir el recordatorio diario.")
            }
        }
    }

    private func openSystemSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

#Preview {
    SettingsView()
}
