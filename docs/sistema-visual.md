# Sistema visual · Presupuesto Estudiantil

Todo lo visual de la app sale de la carpeta `app/lib/tema/`. Las pantallas **no escriben colores, tamaños de letra ni espacios a mano**: los importan de ahí.

| Archivo | Qué tiene |
|---|---|
| `tema/colores.dart` | La paleta B Índigo |
| `tema/tipografia.dart` | Los estilos de texto (clase `Tipografia`) |
| `tema/espaciado.dart` | Los espacios, todos múltiplos de 8 |
| `tema/tema.dart` | `crearTema()`: arma el `ThemeData` que usa `main.dart` |

## 1. Colores (Paleta B Índigo)

| Constante | Hexa | Para qué se usa |
|---|---|---|
| `colorMarca` | `#4338CA` | Botón principal, enlaces, borde del campo activo |
| `colorMarcaPresionado` | `#3730A3` | Botón principal mientras se presiona |
| `colorMarcaSuave` | `#ECEBFB` | Fondos de resaltado |
| `colorTexto` | `#1B1B2E` | Títulos y texto principal |
| `colorTextoSecundario` | `#5A5A70` | Subtítulos, ayudas, ícono del ojo |
| `colorPlaceholder` | `#6E6E83` | Texto de ejemplo dentro de los campos |
| `colorFondo` | `#F5F5F8` | Fondo de todas las pantallas |
| `colorSuperficie` | `#FFFFFF` | Relleno de campos y diálogos |
| `colorBorde` | `#E2E2EC` | Borde de los campos |
| `colorDeshabilitado` | `#EDEDF3` | Botón mientras carga |
| `colorIngreso` | `#15803D` | Montos de ingreso |
| `colorGasto` | `#CC4133` | Montos de gasto |
| `colorAviso` | `#A15C07` | Avisos (presupuesto por agotarse) |
| `colorError` | `#B91C1C` | Texto y borde de error |

`colorSuperficie` (blanco) se agregó a la paleta para el relleno de los campos.

## 2. Tipografía

Manrope para títulos y Plus Jakarta Sans para todo lo demás (paquete `google_fonts`).
El **alto de línea** también cae en la retícula de 8: cada línea mide 16, 24 o 32.

| Estilo | Fuente | Tamaño | Peso | Alto de línea | Dónde |
|---|---|---|---|---|---|
| `Tipografia.titulo` | Manrope | 24 | 700 | 32 | Título de cada pantalla |
| `Tipografia.cuerpo` | Plus Jakarta Sans | 16 | 400 | 24 | Texto de los campos |
| `Tipografia.subtitulo` | Plus Jakarta Sans | 16 | 400 | 24 | Bajada del título (color secundario) |
| `Tipografia.etiqueta` | Plus Jakarta Sans | 14 | 600 | 16 | Etiqueta arriba del campo, enlaces |
| `Tipografia.boton` | Plus Jakarta Sans | 16 | 600 | 24 | Texto del botón principal |
| `Tipografia.ayuda` | Plus Jakarta Sans | 12 | 400 | 16 | Texto de ayuda debajo del campo |
| `Tipografia.error` | Plus Jakarta Sans | 12 | 400 | 16 | Mensaje de error debajo del campo (rojo) |

## 3. Espaciado: todo múltiplo de 8

| Constante | Valor | Dónde se usa |
|---|---|---|
| `espacio8` | 8 | Etiqueta ↔ campo · campo ↔ error/ayuda · título ↔ subtítulo · ícono ↔ texto del botón |
| `espacio16` | 16 | Margen lateral (`margenLateral`) · entre un campo y el siguiente · padding interno del campo · botón ↔ enlace de abajo |
| `espacio24` | 24 | Subtítulo ↔ primer campo · margen inferior de la pantalla |
| `espacio32` | 32 | Último campo ↔ botón principal |
| `espacio48` | 48 | Alto de campos y botones (`alturaControl`) · margen superior del Login |

**Única excepción:** `radioControl = 12`, el redondeo de las esquinas de campos y botones. Es un radio, no un espacio, así que no rompe la retícula.

### Cómo se ve en una pantalla (Registro)

```
 ┌─────────────────────────────────┐
 │← (AppBar)                       │
 │                          8      │
 │16 Crear cuenta            ─┐    │
 │                          8 │    │
 │   Con tu cuenta vas a...  ─┘    │
 │                          24     │
 │   Nombre                        │
 │                          8      │
 │   [ campo · 48 de alto  ]       │
 │                          16     │
 │   Correo                        │
 │                          8      │
 │   [ campo               ]       │
 │                          16     │
 │   Contraseña                    │
 │                          8      │
 │   [ campo            👁 ]       │
 │                          8      │
 │   Mínimo 6 caracteres  (ayuda)  │
 │                          16     │
 │   Repetir contraseña  ...       │
 │                          32     │
 │   [   Crear cuenta · 48   ]  16 │
 └─────────────────────────────────┘
```

## 4. Componentes

- **`CampoTexto`** (`widgets/campo_texto.dart`): etiqueta arriba, campo de 48 de alto con radio 12, borde `colorBorde` (2px `colorMarca` al escribir). Con error, el borde pasa a `colorError` y el mensaje aparece debajo. Las contraseñas tienen un ojo para mostrar u ocultar.
- **`BotonPrincipal`** (`widgets/boton_principal.dart`): ancho completo, 48 de alto, radio 12. Mientras espera al servidor muestra un indicador + "Ingresando…" / "Guardando…" y no se puede tocar.
- **`BotonSecundario`** (`widgets/boton_secundario.dart`): mismo tamaño que el principal, fondo blanco con borde `colorBorde` y texto `colorMarca`. Para la acción alternativa ("Ya tengo cuenta", "Cerrar sesión").
- Los enlaces (`TextButton`) tienen 48 de alto mínimo para que sean fáciles de tocar con el dedo.
