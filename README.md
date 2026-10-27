# Tageswort — Palabra de alemán del día (iOS + Widget)

App iOS nativa en SwiftUI con un **widget de pantalla de inicio** (WidgetKit) que
muestra una palabra nueva de alemán cada día. La palabra se elige de forma
determinista según la fecha, así que app y widget siempre coinciden y avanzan
una posición cada día recorriendo todo el catálogo.

> Este entorno es Linux (no hay Xcode). Aquí está todo el código; tú lo compilas
> en una Mac con Xcode (15 o superior). No se necesita cuenta de pago para probar
> en el simulador; sí necesitas cuenta de desarrollador (gratuita sirve) para
> instalarlo en tu iPhone físico.

## Archivos

```
Shared/
  Word.swift          Modelo de datos de una palabra
  WordStore.swift     Carga el catálogo y elige la palabra del día
  SpeechService.swift Pronunciación en alemán (AVSpeechSynthesizer, voz de-DE)
  NotificationService.swift  Recordatorio diario (UserNotifications)
  words.json          Catálogo (40 palabras; edítalo/amplíalo a gusto)
App/
  TageswortApp.swift  Punto de entrada de la app (reprograma recordatorios)
  ContentView.swift   Pantalla principal (palabra de hoy + próximas + audio)
  SettingsView.swift  Ajustes del recordatorio (activar + hora)
Widget/
  TageswortWidget.swift        El widget y su línea de tiempo
  TageswortWidgetBundle.swift  Bundle del widget (@main del target widget)
```

## Opción rápida: generar el proyecto con XcodeGen (recomendada)

Si tienes [Homebrew](https://brew.sh), esto arma el `.xcodeproj` ya configurado
(app + widget, archivos compartidos, esquema de URL) y te evita el montaje manual:

```sh
brew install xcodegen      # una sola vez
cd tageswort               # la carpeta del repo
xcodegen generate          # crea Tageswort.xcodeproj
open Tageswort.xcodeproj
```

Luego, para instalarlo:

- **En el simulador:** elige un iPhone en la barra superior y pulsa ▶ (no necesita
  cuenta de desarrollador).
- **En tu iPhone real:** conéctalo por cable, selecciónalo como destino. En el
  target `Tageswort` → *Signing & Capabilities* → marca **Automatically manage
  signing** y elige tu **Team** (tu Apple ID gratuito sirve). Haz lo mismo en el
  target del widget. Pulsa ▶. La primera vez, en el iPhone ve a *Ajustes ▸ General
  ▸ VPN y gestión de dispositivos* y **confía** en tu certificado de desarrollador.

> Con Apple ID gratuito, la app instalada en el iPhone caduca a los **7 días** (la
> vuelves a instalar con ▶). No usamos App Groups, así que funciona sin cuenta de
> pago. Si el identificador `com.pabblodlq21.tageswort` ya está tomado, cámbialo en
> `project.yml` y regenera.

## Montaje en Xcode (paso a paso, alternativa manual)

1. **Crea el proyecto.** Xcode → *File ▸ New ▸ Project… ▸ iOS ▸ App*.
   - Product Name: `Tageswort`
   - Interface: **SwiftUI**, Language: **Swift**
   - Borra el `ContentView.swift` y el `...App.swift` que genera Xcode.

2. **Agrega el código de la app.** Arrastra a ese target:
   - `App/TageswortApp.swift`, `App/ContentView.swift`, `App/SettingsView.swift`
   - `Shared/Word.swift`, `Shared/WordStore.swift`, `Shared/SpeechService.swift`,
     `Shared/NotificationService.swift`
   - `Shared/words.json`  → al agregarlo marca **"Copy items if needed"** y
     deja activado el target de la app en *"Add to targets"*.
   > `SpeechService.swift` y `NotificationService.swift` solo los necesita el
   > target de la **app** (el widget no reproduce audio ni programa avisos; al
   > tocarlo abre la app y esta pronuncia).

3. **Agrega el target del widget.** *File ▸ New ▸ Target… ▸ Widget Extension*.
   - Product Name: `TageswortWidget`
   - **Desmarca** "Include Configuration App Intent" (usamos widget estático).
   - Xcode crea archivos de ejemplo: **bórralos** y en su lugar agrega:
     - `Widget/TageswortWidget.swift`, `Widget/TageswortWidgetBundle.swift`
     - `Shared/Word.swift`, `Shared/WordStore.swift`  (los **mismos** archivos;
       en el inspector de la derecha marca **Target Membership** = app **y** widget)
     - `Shared/words.json`  (igual: Target Membership en app **y** widget)

   > Clave: `Word.swift`, `WordStore.swift` y `words.json` deben pertenecer a
   > **ambos** targets. Así el widget y la app usan el mismo catálogo y la misma
   > lógica, sin necesitar App Group (los datos son estáticos).

4. **Compila y corre** el esquema `Tageswort` en el simulador. Para ver el widget:
   deja la app instalada, ve a la pantalla de inicio del simulador, mantén
   presionado → **+** (arriba a la izquierda) → busca "Palabra del día" → agrégalo.

## Audio de pronunciación (tocar el widget para escuchar)

La app pronuncia en alemán con la voz del sistema `de-DE`. En la pantalla
principal hay un botón de altavoz junto a la palabra y junto a la frase de
ejemplo. Además, **tocar el widget** abre la app y pronuncia la palabra del día.

Para que el toque del widget funcione, registra el esquema de URL `tageswort` en
el target de la **app**:

1. Selecciona el proyecto → target `Tageswort` → pestaña **Info**.
2. Despliega **URL Types** y pulsa **+**.
3. En **URL Schemes** escribe `tageswort` (Identifier puede ser el bundle id).

> El widget abre `tageswort://speak`; `ContentView` lo recibe en `.onOpenURL` y
> llama a `SpeechService`. Si no registras el esquema, el widget simplemente
> abrirá la app sin pronunciar, y los botones de altavoz dentro de la app seguirán
> funcionando igual.

La voz alemana viene instalada en iOS; si en un dispositivo no se oye, el usuario
puede descargarla en *Ajustes ▸ Accesibilidad ▸ Contenido hablado ▸ Voces ▸ Alemán*.

## Widget en la pantalla de bloqueo (siempre a la vista)

El mismo widget soporta las familias *accessory* de la pantalla de bloqueo, sin
configuración extra en Xcode (es el mismo target):

- **Rectangular** (debajo del reloj): palabra + traducción.
- **En línea** (junto al reloj): `der Hund · el perro`.
- **Circular**: la palabra alemana con un ícono de libro.

Para añadirlo en el iPhone: bloquea la pantalla → mantén pulsado → **Personalizar**
→ *Pantalla bloqueada* → toca una zona de widgets → elige **Tageswort**.

> La pantalla de bloqueo pinta estos widgets en **monocromo translúcido**, así que
> ahí no se ve el degradado morado (eso es solo en la pantalla de inicio). Por eso
> el código usa una vista distinta por familia: `.accessoryRectangular`,
> `.accessoryInline` y `.accessoryCircular`, además de `.systemSmall` y
> `.systemMedium`. Al tocar cualquiera se abre la app y pronuncia la palabra.

## Recordatorio diario (notificación)

Toca el **engrane** (arriba a la derecha) para abrir *Ajustes* y activar el
**recordatorio diario**; elige la hora con el selector. La primera vez, iOS pide
permiso de notificaciones. Cada día, a la hora elegida, llega una notificación con
la palabra de ese día.

- No requiere ninguna *capability* ni configuración extra en Xcode: las
  notificaciones **locales** funcionan tal cual. (Solo necesitarías una *capability*
  si en el futuro quisieras notificaciones *push* desde un servidor.)
- Como iOS limita las notificaciones pendientes, la app programa una ventana de 14
  días (cada día con su palabra) y la **reprograma al abrirse**, para que el texto
  siempre corresponda al día correcto. Mantén el hábito de abrir la app de vez en
  cuando para refrescar la ventana.
- Para probar en el simulador: activa el recordatorio con una hora 1–2 minutos en el
  futuro y deja la app en segundo plano.

## Cómo rota la palabra (cada 2 horas)

La palabra cambia cada **2 horas**, en franjas alineadas a la medianoche local
(00:00, 02:00, 04:00, … 22:00) — 12 franjas por día. `WordStore.word(for:)`
calcula un índice de franja global (`días × 12 + hora/2`) y hace
`índice % cantidad_de_palabras`, así que app y widget siempre coinciden.

El widget genera 12 entradas (una por franja, 24 h de cobertura) alineadas al
inicio de cada franja y pide recarga al terminar el día. La app usa un
`TimelineView` que recalcula cada minuto, de modo que la palabra cambia sola al
entrar una nueva franja mientras la app está abierta.

Para cambiar el intervalo, edita `slotHours` en `Shared/WordStore.swift` (p. ej.
`1` para cada hora, `3` para cada 3 horas). El resto se ajusta solo.

> Nota de iOS: WidgetKit no refresca al segundo exacto; el sistema puede
> adelantar o retrasar unos minutos la actualización según la batería y el uso.
> Las entradas pre-generadas hacen que el cambio sea lo más puntual posible.

## Ideas para crecer (cuando quieras)

- **Más palabras / niveles (A1, A2…):** solo amplía `words.json`.
- ~~**Audio de pronunciación:** `AVSpeechSynthesizer` con voz `de-DE`.~~ ✅ hecho.
- **Favoritos y racha diaria:** aquí sí conviene un **App Group** para compartir
  datos escribibles entre app y widget (`UserDefaults(suiteName:)`).
- **Marcar "ya la aprendí"** y que el algoritmo priorice las no vistas
  (repetición espaciada).
- ~~**Notificación diaria** con la palabra del día (`UNUserNotificationCenter`).~~ ✅ hecho.

Dime cuál de estas quieres y la agrego.
