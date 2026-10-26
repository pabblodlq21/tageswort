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
  words.json          Catálogo (40 palabras; edítalo/amplíalo a gusto)
App/
  TageswortApp.swift  Punto de entrada de la app
  ContentView.swift   Pantalla principal (palabra de hoy + próximas)
Widget/
  TageswortWidget.swift        El widget y su línea de tiempo
  TageswortWidgetBundle.swift  Bundle del widget (@main del target widget)
```

## Montaje en Xcode (paso a paso)

1. **Crea el proyecto.** Xcode → *File ▸ New ▸ Project… ▸ iOS ▸ App*.
   - Product Name: `Tageswort`
   - Interface: **SwiftUI**, Language: **Swift**
   - Borra el `ContentView.swift` y el `...App.swift` que genera Xcode.

2. **Agrega el código de la app.** Arrastra a ese target:
   - `App/TageswortApp.swift`, `App/ContentView.swift`
   - `Shared/Word.swift`, `Shared/WordStore.swift`
   - `Shared/words.json`  → al agregarlo marca **"Copy items if needed"** y
     deja activado el target de la app en *"Add to targets"*.

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

## Cómo rota la palabra

`WordStore.word(for:)` calcula los días transcurridos desde una época fija y hace
`días % cantidad_de_palabras`. El widget genera 7 entradas (una por día, a partir
de cada medianoche) y pide recarga pasada esa semana. Con 40 palabras, el ciclo
se repite cada 40 días.

## Ideas para crecer (cuando quieras)

- **Más palabras / niveles (A1, A2…):** solo amplía `words.json`.
- **Audio de pronunciación:** `AVSpeechSynthesizer` con voz `de-DE`.
- **Favoritos y racha diaria:** aquí sí conviene un **App Group** para compartir
  datos escribibles entre app y widget (`UserDefaults(suiteName:)`).
- **Marcar "ya la aprendí"** y que el algoritmo priorice las no vistas
  (repetición espaciada).
- **Notificación diaria** con la palabra del día (`UNUserNotificationCenter`).

Dime cuál de estas quieres y la agrego.
