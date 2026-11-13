# Clase 22 Patrones oscuros
Integrantes:
- Sebastian Cespedes Rodas
- Adolfo Mendoza Ribera

Modalidad: sin IA

## 1. Patrón encontrado
Tipo (de los seis): 5 — salir cuesta más que entrar.

Dónde: `lib/pantallas/pantalla_movimientos.dart:355` (AppBar) y `servidor/servidor.js:228`. Se puede cerrar sesión con un toque, pero no existe ninguna forma de eliminar la cuenta ni los datos.

Por qué es un patrón oscuro: registrarse e iniciar sesión es directo, y cerrar sesión está a la vista; en cambio, eliminar la cuenta no aparece en ninguna pantalla y el servidor no tiene un endpoint para hacerlo. El usuario no ve que sus datos financieros quedan guardados indefinidamente y no puede ejercer control sobre ellos. Esto beneficia al sistema, que conserva usuarios y datos para retención, y perjudica al usuario, que no puede irse con sus datos ni hacer que se borren.

## 2. Antes
En la pantalla de movimientos solo se ofrece “Cerrar sesión”; no hay una opción para eliminar la cuenta.

![Antes: la AppBar solo permite cerrar sesión, no eliminar la cuenta](clase-22/antes.png)

Fragmento de código del antes:

```dart
// lib/pantallas/pantalla_movimientos.dart (AppBar)
IconButton(
  tooltip: 'Cerrar sesión',
  icon: const Icon(Icons.logout, color: Colores.verdeOscuro),
  onPressed: _cerrarSesion,
),
// No existe una opción "Eliminar cuenta".
```

```js
// servidor/servidor.js
app.post('/logout', exigirSesion, async (req, res) => {
  await prisma.sesion.deleteMany({ where: { token: req.token } });
  res.json({ mensaje: 'Sesión cerrada' });
});
// No existe DELETE /cuenta.
```

## 3. Después
Pendiente: captura y fragmento de código del después.

## 4. Principio aplicado
Pendiente.

## 5. Prueba
Pendiente.

## 6. Otros que encontramos
Pendiente.
