# Hitster Rap

Clon casero de [HITSTER](https://hitstergame.com/) con tus propias canciones de Spotify.

## Estructura

```
data/songs.json      ← fuente única de verdad: edita aquí tus canciones
cards/index.html     ← generador de cartas para imprimir (Fase 1)
ios/                 ← app iOS escáner + reproductor (Fase 2, pendiente)
SETUP.md             ← instrucciones de compilación iOS (Fase 2, pendiente)
```

## Fase 1 — Generador de cartas

### Cómo añadir canciones

Edita `data/songs.json`. Cada entrada:

```json
{
  "id": "0005",
  "spotifyUri": "spotify:track:XXXXXXXXXXXXXXXXXXXX",
  "title": "Título",
  "artist": "Artista",
  "year": 1999
}
```

- El `spotifyUri` puede ser el URI (`spotify:track:...`) **o** la URL larga
  (`https://open.spotify.com/track/...`); el generador convierte automáticamente.
- Para obtener el URI en Spotify: botón derecho sobre la canción → *Compartir* →
  *Copiar enlace de Spotify* (URI) o *Copiar URL de Spotify* (URL).

### Cómo generar las cartas

Desde la raíz del repo:

```bash
python3 -m http.server 8080
```

Luego abre en el navegador: **http://localhost:8080/cards/**

### Cómo imprimir

1. Haz clic en **Imprimir** (o `Ctrl+P` / `Cmd+P`).
2. En el diálogo de impresión:
   - Papel: **A4**
   - Orientación: **Vertical (Portrait)**
   - Márgenes: **Ninguno** (None)
   - Activar **impresión dúplex** → voltear por el **borde largo** (Long-Edge Flip)
3. Imprime y corta por las líneas grises.

> **Nota sobre los URIs de ejemplo:** los `spotifyUri` del `songs.json` inicial son
> de ejemplo con IDs ficticios. Sustitúyelos por los tuyos antes de imprimir.
