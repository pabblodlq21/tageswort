import Foundation
import UserNotifications

/// Programa un recordatorio diario con la palabra de alemán de cada día.
///
/// iOS solo deja ~64 notificaciones pendientes, así que programamos una ventana
/// de varios días por adelantado (cada una con su propia palabra) y la volvemos
/// a llenar cada vez que la app se abre. Así el texto siempre corresponde al día.
final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "tageswort.daily."

    // MARK: Preferencias persistentes

    private enum Keys {
        static let enabled = "notif.enabled"
        static let hour = "notif.hour"
        static let minute = "notif.minute"
    }

    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Keys.enabled) }
    }
    @Published var hour: Int {
        didSet { UserDefaults.standard.set(hour, forKey: Keys.hour) }
    }
    @Published var minute: Int {
        didSet { UserDefaults.standard.set(minute, forKey: Keys.minute) }
    }

    private override init() {
        let d = UserDefaults.standard
        isEnabled = d.bool(forKey: Keys.enabled)
        // Hora por defecto: 9:00.
        hour = d.object(forKey: Keys.hour) != nil ? d.integer(forKey: Keys.hour) : 9
        minute = d.object(forKey: Keys.minute) != nil ? d.integer(forKey: Keys.minute) : 0
        super.init()
    }

    /// `DateComponents` con la hora elegida, para el `DatePicker` de la UI.
    var time: DateComponents {
        get { DateComponents(hour: hour, minute: minute) }
        set {
            hour = newValue.hour ?? hour
            minute = newValue.minute ?? minute
        }
    }

    // MARK: Permisos

    /// Pide permiso de notificaciones. Devuelve si quedó autorizado.
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Estado actual de autorización.
    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: Programación

    /// Reprograma la ventana de recordatorios según las preferencias actuales.
    /// Si está desactivado, cancela todo. Llámalo al abrir la app y al cambiar ajustes.
    func reschedule(daysAhead: Int = 14, calendar: Calendar = .current) {
        cancelAll()
        guard isEnabled else { return }

        let startOfToday = calendar.startOfDay(for: Date())
        let now = Date()

        for dayOffset in 0..<daysAhead {
            guard
                let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday),
                let fireDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
            else { continue }

            // Si la hora de hoy ya pasó, no programes una fecha en el pasado.
            if fireDate <= now { continue }

            // La palabra que estará activa a la hora de la notificación.
            let word = WordStore.word(for: fireDate, calendar: calendar)

            let content = UNMutableNotificationContent()
            content.title = "Tageswort · Palabra del día"
            content.body = "\(word.display) — \(word.spanish)\n„\(word.example)“"
            content.sound = .default

            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(identifier: "\(identifierPrefix)\(dayOffset)",
                                                content: content, trigger: trigger)
            center.add(request)
        }
    }

    /// Cancela todos los recordatorios diarios programados por esta app.
    func cancelAll() {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let ids = requests.map(\.identifier).filter { $0.hasPrefix(self.identifierPrefix) }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    /// Activa (pidiendo permiso) o desactiva el recordatorio y reprograma.
    func setEnabled(_ enabled: Bool) async {
        if enabled {
            let granted = await requestAuthorization()
            await MainActor.run { self.isEnabled = granted }
            guard granted else { return }
        } else {
            await MainActor.run { self.isEnabled = false }
        }
        reschedule()
    }
}
