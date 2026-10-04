# Sistema visual · Presupuesto Estudiantil · v0.2

> **v0.2 (04/10/2026):** se cambia la Paleta B Índigo (v0.1) por la **Paleta C Petróleo**, se agregan los tonos "suave" de ingreso, gasto, aviso y error, y el estilo `Tipografia.monto` (Manrope con números tabulares) para la lista de movimientos. Espaciado y tamaños no cambian.

Todo lo visual de la app sale de la carpeta `app/lib/comun/tema/`. Las pantallas **no escriben colores, tamaños de letra ni espacios a mano**: los importan de ahí.

| Archivo | Qué tiene |
|---|---|
| `comun/tema/colores.dart` | La paleta C Petróleo |
| `comun/tema/tipografia.dart` | Los estilos de texto (clase `Tipografia`) |
| `comun/tema/espaciado.dart` | Los espacios, todos múltiplos de 8 |
| `comun/tema/tema.dart` | `crearTema()`: arma el `ThemeData` que usa `main.dart` |

## 1. Colores (Paleta C Petróleo)

| Constante | Hexa | Para qué se usa |
|---|---|---|
| `colorMarca` | `#0F5F6E` | Botón principal, botón +, enlaces, borde del campo activo |
| `colorMarcaPresionado` | `#0B4852` | Botón principal mientras se presiona |
| `colorMarcaSuave` | `#E0EEF0` | Fondos de resaltado (ícono de la bienvenida) |
| `colorTexto` | `#1C2426` | Títulos y texto principal |
| `colorTextoSecundario` | `#5A6668` | Subtítulos, ayudas, íconos dentro de los campos |
| `colorPlaceholder` | `#6D7775` | Texto de ejemplo dentro de los campos |
| `colorFondo` | `#F4F4F0` | Fondo de todas las pantallas |
| `colorSuperficie` | `#FFFFFF` | Relleno de campos, tarjetas y diálogos |
| `colorBorde` | `#E2E1DA` | Borde de campos y tarjetas |
| `colorDeshabilitado` | `#ECECE7` | Botón mientras carga |
| `colorIngreso` / `colorIngresoSuave` | `#1B7F46` / `#E2F3E8` | Montos de ingreso / su fondo |
| `colorGasto` / `colorGastoSuave` | `#C9442F` / `#FBE9E5` | Montos de gasto ("− Bs 25.00") / su fondo |
| `colorAviso` / `colorAvisoSuave` | `#A3620A` / `#FBF0DA` | Avisos (presupuesto por agotarse) / su fondo |
| `colorError` / `colorErrorSuave` | `#B42318` / `#FCE8E6` | Texto y borde de error / su fondo |

## 2. Tipografía

Manrope para títulos y montos, Plus Jakarta Sans para todo lo demás (paquete `google_fonts`).
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
| `Tipografia.monto` | Manrope (números tabulares) | 16 | 700 | 24 | Montos de la lista: todos los dígitos miden lo mismo y quedan alineados |

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

- **`CampoTexto`** (`comun/widgets/campo_texto.dart`): etiqueta arriba, campo de 48 de alto con radio 12, borde `colorBorde` (2px `colorMarca` al escribir). Con error, el borde pasa a `colorError` y el mensaje aparece debajo. Las contraseñas tienen un ojo para mostrar u ocultar.
- **`BotonPrincipal`** (`comun/widgets/boton_principal.dart`): ancho completo, 48 de alto, radio 12. Mientras espera al servidor muestra un indicador + "Ingresando…" / "Guardando…" y no se puede tocar.
- **`BotonSecundario`** (`comun/widgets/boton_secundario.dart`): mismo tamaño que el principal, fondo blanco con borde `colorBorde` y texto `colorMarca`. Para la acción alternativa ("Ya tengo cuenta", "Cerrar sesión").
- Los enlaces (`TextButton`) tienen 48 de alto mínimo para que sean fáciles de tocar con el dedo.
