# SETUP — Hitster Rap iOS

Requisitos previos:
- iPhone con iOS 16 o superior
- Cuenta de Apple Developer (gratuita sirve para instalar en tu propio iPhone)
- Cuenta de Spotify **Premium**
- App de Spotify instalada en el iPhone
- **No necesitas Mac ni Xcode.** El proyecto iOS se genera automáticamente en CI.

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

## Paso 2 — El proyecto Xcode se genera automáticamente (XcodeGen)

**No commiteas ningún `.xcodeproj`.** El fichero `project.yml` de la raíz del repo describe
completamente la app: target, bundle ID, deployment target, fuentes Swift, Info.plist
(permisos de cámara, URL scheme `hitsterrap://`, consulta de Spotify), y la dependencia
del SDK de Spotify via Swift Package Manager.

El workflow de CI ejecuta `xcodegen generate` antes de compilar, lo que crea
`HitsterRap.xcodeproj` en la raíz del runner. Este fichero **nunca se sube a git**
(está en `.gitignore`).

| Qué define `project.yml` | Valor |
|---------------------------|-------|
| Scheme generado | **HitsterRap** |
| Bundle ID | `com.miguel.HitsterRap` |
| Deployment target | iOS 16.0 |
| SDK de Spotify | `github.com/spotify/ios-sdk` v5.0.1 via SPM |
| URL scheme | `hitsterrap` (redirect de autenticación Spotify) |
| Permiso de cámara | `NSCameraUsageDescription` en Info.plist generado |

Si necesitas cambiar el Bundle ID (por ejemplo, para firmarlo con tu Apple ID),
edita la línea `PRODUCT_BUNDLE_IDENTIFIER` en `project.yml` y haz push.

---

## Paso 3 — Configurar el Client ID de Spotify

Edita `ios/HitsterRap/SpotifyManager.swift` y reemplaza:

```swift
private let clientID = "YOUR_CLIENT_ID"
```

con el Client ID que copiaste en el paso 1:

```swift
private let clientID = "a1b2c3d4e5f6..."
```

Commitea el cambio y haz push a `main`. El CI compilará la app con tu Client ID.

---

## Paso 4 — Obtener el IPA e instalarlo en el iPhone

El workflow `.github/workflows/build-unsigned-ipa.yml` compila la app en GitHub Actions
cada vez que haces push a `main`, y también se puede lanzar a mano.

**Pasos:**

1. Ve a la pestaña **Actions** del repo en GitHub.
2. Selecciona el run más reciente de **Build Unsigned IPA** y espera a que termine (~10 min).
3. Descarga el artifact **HitsterRap-unsigned-ipa** (un `.zip` con el `.ipa` dentro).
4. Instálalo en tu iPhone con **[Sideloadly](https://sideloadly.io/)**:
   - Conecta el iPhone al PC por cable.
   - Abre Sideloadly, arrastra el `.ipa` y pulsa Start.
   - Sideloadly firma la app con tu Apple ID (gratuito) y la instala.
5. En el iPhone: **Ajustes → General → VPN y gestión de dispositivos** → confía en tu certificado.

**Referencia del workflow de CI:**

| Campo | Valor |
|-------|-------|
| Proyecto | generado por `xcodegen generate` → `HitsterRap.xcodeproj` |
| Scheme (`-scheme`) | `HitsterRap` |
| SDK | `iphoneos` (dispositivo real) |
| Firma | `CODE_SIGNING_ALLOWED=NO` (Sideloadly firma localmente) |
| Artifact | `HitsterRap-unsigned.ipa` · disponible 30 días |

---

## Flujo de uso

1. Abre la app → aparece la cámara.
2. Apunta a la carta con el QR.
3. La primera vez, la app abre Spotify para autorizar → acepta.
4. Spotify empieza a reproducir la canción automáticamente y vuelves a la app.
5. La pantalla muestra el estado de reproducción (sin título ni artista — sin trampas).
6. Pulsa **Siguiente carta** para pausar y escanear la siguiente.

> Las siguientes cartas de la misma sesión no reabren Spotify.
> Solo la primera carta de cada sesión requiere autorización.

---

## Notas importantes

- **Spotify Premium es obligatorio.** La reproducción vía App Remote no funciona con cuenta gratuita.
- **La app de Spotify debe estar instalada** en el mismo iPhone.
- Si la sesión se interrumpe más de ~60 minutos, puede ser necesario volver a autorizar escaneando cualquier carta.
- El SDK de Spotify no expone título, artista ni año a la app — la experiencia del juego está garantizada.
- Si Sideloadly expira (los certificados gratuitos duran 7 días), simplemente repite el paso 4.
