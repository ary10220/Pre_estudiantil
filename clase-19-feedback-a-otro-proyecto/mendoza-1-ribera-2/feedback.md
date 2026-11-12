# Su feedback va en su propio repositorio

# Feedback a otro proyecto - Clase 19
- Nombre completo del evaluador: Adolfo Mendoza Ribera
- Mi grupo y caso de estudio: Sebastián Cespedes Rodas - Adolfo Mendoza Ribera
- Grupo y caso de estudio evaluado: Veterinaria
- Integrantes del proyecto evaluado: Alex Ticlla Choque - Choque Benavides Gabriel
- URL de la app y repositorio evaluado: https://github.com/AlexTiclla/segundoProyectoIHC.git
- Fecha y versión/commit probado (si está disponible): 

## Primera impresión
- **¿Qué entendí al entrar?:** Se identifica el sistema de veterinaria, pero la pantalla principal presenta demasiado espacio vacío desaprovechado y el diseño visual resulta muy simple en su esquema de colores.
- **¿Qué me confundió?:** La sección de filtros resulta confusa a la vista porque carece de textos o mensajes de guía para orientar al usuario (por ejemplo, para saber cómo seleccionar o interactuar con el tipo de cuidado).

## Funcionalidad asignada y resultado
- **Tarea indicada:** Flujo de registro para agregar mascota y uso de la pantalla principal con sus filtros.
- **Resultado:**
  - [x] La completé con ayuda: Se requirió guía/orientación durante el flujo de registro y el uso de los filtros debido a la falta de mensajes descriptivos y opciones claras de selección.
  - [ ] La completé sin ayuda
  - [ ] No pude completarla. ¿Dónde me detuve?

## Qué no funcionó
1. **Validación de fecha en el registro:**
   - **Pasos:** Intentar registrar una mascota seleccionando una fecha anterior al día actual.
   - **Resultado esperado:** El sistema no debería permitir registrar una mascota en un día anterior.
   - **Resultado observado:** El sistema permite añadirla sin validar ni restringir fechas pasadas.
2. **Ausencia de campo para el problema de la mascota:**
   - **Resultado observado:** No existe un campo para explicar qué problema de salud o motivo de atención tiene la mascota.
3. **Restricción en filtros avanzados:**
   - **Pasos:** Intentar agregar dos etiquetas del mismo tipo en los filtros avanzados.
   - **Resultado esperado:** Poder añadir múltiples etiquetas del mismo tipo para filtrar con mayor precisión.
   - **Resultado observado:** No permite seleccionar/añadir dos etiquetas del mismo tipo.
4. **Campo "cuidado":**
   - **Resultado observado:** Presenta deficiencias al no tener un estado de selección definido o un campo de detalles complementario.

## Que mejoraría y por qué
- **Registro de mascota:**
  - Agregar mensajes más descriptivos en los campos de entrada (especialmente en "cuidado").
  - En el campo de especie, implementar una lista de selección con las especies comunes y dejar la escritura manual como algo opcional para agilizar la carga.
  - En el campo "cuidado", ofrecer un menú de selección estructurado o añadir un campo exclusivo para detalles.
  - Agregar un campo explícito para registrar qué problema presenta la mascota.
- **Distribución y filtros:**
  - Reorganizar el espacio de la pantalla principal dividiéndola en dos paneles (a un lado la lista de mascotas y al otro el formulario de registro) para eliminar los espacios muertos.
  - Añadir mensajes de ayuda/guía en la zona de filtros (como en "tipo de cuidado") para que el usuario no se confunda.
  - Permitir añadir múltiples etiquetas del mismo tipo en los filtros avanzados.
- **Diseño visual:**
  - Mejorar la estética general implementando una paleta de colores más agradable y cuidada.

## Que quitaría y porque
- No quitaría ninguna funcionalidad actual; lo necesario es redistribuir el espacio desaprovechado en la pantalla principal y transformar campos de texto libre en selectores guiados con mejores validaciones.