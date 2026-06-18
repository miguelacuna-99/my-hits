# SETUP — Hitster Rap iOS

Requisitos previos:
- Mac con Xcode 15 o superior
- iPhone con iOS 16 o superior
- Cuenta de Apple Developer (gratuita sirve para instalar en tu propio iPhone)
- Cuenta de Spotify **Premium**
- App de Spotify instalada en el iPhone

---

## Paso 1 — Registrar la app en Spotify

1. Ve a [developer.spotify.com/dashboard](https://developer.spotify.com/dashboard) e inicia sesión.
2. Pulsa **Create app**.
3. Rellena:
   - **App name:** Hitster Rap (o el que prefieras)
   - **App description:** Juego de cartas personal
   - **Redirect URIs:** `hitsterrap://spotify-callback` → pulsa **Add**
   - **APIs used:** marca **iOS**
4. Acepta los términos y pulsa **Save**.
5. En la pantalla de tu app, copia el **Client ID** (cadena de 32 caracteres).

---

## Paso 2 — Crear el proyecto en Xcode

1. Abre Xcode → **File → New → Project**.
2. Selecciona **iOS → App** → Next.
3. Rellena:
   - **Product Name:** HitsterRap
   - **Organization Identifier:** `com.TUNOMBRE` (lo que quieras, p. ej. `com.miguel`)
   - **Bundle Identifier** resultante: `com.TUNOMBRE.HitsterRap`
     *(Anota este Bundle Identifier; lo necesitarás en el Dashboard de Spotify si Spotify lo requiere.)*
   - **Interface:** SwiftUI
   - **Language:** Swift
4. Cuando Xcode pregunte dónde guardar el proyecto, navega hasta la carpeta **`ios/`** del repo y pulsa **Create**.
   Esto crea la siguiente estructura (que el workflow de CI espera):
   ```
   ios/HitsterRap/HitsterRap.xcodeproj   ← proyecto
   ios/HitsterRap/HitsterRap/             ← grupo de fuentes (plantilla)
   ```
5. En el proyecto, selecciona el target **HitsterRap** → pestaña **General** → **Deployment Info** → cambia el **iOS Deployment Target** a **16.0**.

---

## Paso 3 — Añadir el SDK de Spotify

### Opción A — Swift Package Manager (recomendada)

1. En Xcode: **File → Add Package Dependencies…**
2. En el campo de búsqueda pega:
   ```
   https://github.com/spotify/ios-sdk
   ```
3. Selecciona la versión más reciente → **Add Package**.
4. Marca el producto **SpotifyiOS** → **Add to target: HitsterRap**.

### Opción B — XCFramework manual (si SPM da problemas)

1. Ve a [github.com/spotify/ios-sdk/releases](https://github.com/spotify/ios-sdk/releases).
2. Descarga el `.zip` de la última release y extrae `SpotifyiOS.xcframework`.
3. Arrastra `SpotifyiOS.xcframework` al panel izquierdo de Xcode, dentro del target.
4. En **General → Frameworks, Libraries, and Embedded Content** asegúrate de que aparece como **Embed & Sign**.

---

## Paso 4 — Añadir los ficheros fuente

1. En Xcode elimina los ficheros de plantilla que ha creado (`HitsterRapApp.swift` y `ContentView.swift` dentro del grupo `HitsterRap`).
2. Arrastra los 5 ficheros de `ios/HitsterRap/` al grupo **HitsterRap** en el navegador de Xcode:
   - `HitsterRapApp.swift`
   - `SpotifyManager.swift`
   - `ContentView.swift`
   - `ScannerView.swift`
   - `PlayerView.swift`
3. Cuando Xcode pregunte, marca **Copy items if needed** y asegúrate de que el target **HitsterRap** está marcado.
   Los ficheros quedan en `ios/HitsterRap/HitsterRap/`, que es la ruta que usa el workflow de CI.

---

## Paso 5 — Configurar el Client ID

Abre `SpotifyManager.swift` y reemplaza:

```swift
private let clientID = "YOUR_CLIENT_ID"
```

con tu Client ID real del paso 1, por ejemplo:

```swift
private let clientID = "a1b2c3d4e5f6..."
```

---

## Paso 6 — Configurar Info.plist y URL Scheme

### Permiso de cámara

En `Info.plist` (o en **Target → Info → Custom iOS Target Properties**), añade:

| Key | Type | Value |
|-----|------|-------|
| `NSCameraUsageDescription` | String | `Necesario para escanear los códigos QR de las cartas.` |

### URL Scheme (redirect de Spotify)

1. Selecciona el target → pestaña **Info** → sección **URL Types** → pulsa **+**.
2. Rellena:
   - **Identifier:** `com.TUNOMBRE.HitsterRap`
   - **URL Schemes:** `hitsterrap`

### Consultar si Spotify está instalado

En `Info.plist`, añade:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>spotify</string>
</array>
```

---

## Paso 7 — Compilar e instalar en tu iPhone

1. Conecta el iPhone al Mac por cable.
2. En la barra superior de Xcode, selecciona tu iPhone como destino (en lugar de Simulator).
3. La primera vez, Xcode pedirá que firmes el código:
   - **Target → Signing & Capabilities** → marca **Automatically manage signing**.
   - **Team:** selecciona tu Apple ID (añádelo en Xcode → Settings → Accounts si no aparece).
4. Pulsa **▶ Run** (o `Cmd+R`).
5. En el iPhone, ve a **Ajustes → General → VPN y gestión de dispositivos** y confía en tu certificado de desarrollador.

---

## Flujo de uso

1. Abre la app → aparece la cámara.
2. Apunta a la carta con el QR.
3. La primera vez, la app abre Spotify para autorizar → acepta.
4. Spotify empieza a reproducir la canción automáticamente y vuelves a la app.
5. La pantalla muestra el estado de reproducción (sin título ni artista — sin trampas).
6. Pulsa **Siguiente carta** para pausar y escanear la siguiente.

> **Nota:** Las siguientes cartas de la misma sesión no necesitan re-abrir Spotify.
> Solo la primera carta de cada sesión abre Spotify para autorizar.

---

## Paso 8 — CI: compilar el IPA sin firmar con GitHub Actions

El workflow `.github/workflows/build-unsigned-ipa.yml` compila la app automáticamente en cada push a `main` y también se puede lanzar a mano desde la pestaña **Actions** del repo.

**Referencia del workflow:**

| Campo | Valor |
|-------|-------|
| Proyecto (`-project`) | `ios/HitsterRap/HitsterRap.xcodeproj` |
| Scheme (`-scheme`) | `HitsterRap` |
| SDK | `iphoneos` (dispositivo real) |
| Firma | `CODE_SIGNING_ALLOWED=NO` (sin firmar) |
| Artifact | `HitsterRap-unsigned.ipa` (disponible 30 días) |

**Pasos para usar el IPA:**

1. Ve a la pestaña **Actions** del repo en GitHub.
2. Selecciona el run más reciente de **Build Unsigned IPA**.
3. Descarga el artifact `HitsterRap-unsigned-ipa`.
4. Instálalo en tu iPhone con **[Sideloadly](https://sideloadly.io/)** (firma local con tu Apple ID).

> **Importante:** el `.xcodeproj` debe estar commiteado en el repo para que el CI pueda compilar.
> Tras crear el proyecto en Xcode (paso 2), haz `git add ios/HitsterRap/HitsterRap.xcodeproj` y commitea.
> El fichero `ios/HitsterRap/HitsterRap.xcodeproj/project.xcworkspace/xcuserdata/` puede ignorarse
> (datos locales de usuario); todo lo demás del `.xcodeproj` debe estar en git.

---

## Notas importantes

- **Spotify Premium es obligatorio.** La reproducción vía App Remote no funciona con cuenta gratuita.
- **La app de Spotify debe estar instalada** en el mismo iPhone.
- Si la sesión se interrumpe durante más de ~60 minutos, es posible que sea necesario volver a autorizar escaneando cualquier carta.
- El SDK de Spotify NO muestra título, artista ni año en la app — se mantiene la experiencia del juego.
