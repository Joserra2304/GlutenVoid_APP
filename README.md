## Descripción del Proyecto
Gluten Void es una aplicación Android diseñada para mejorar la calidad de vida de personas con trastornos alimentarios relacionados con el gluten, como la enfermedad celíaca y la sensibilidad al gluten. Proporciona herramientas útiles para la gestión y selección de alimentos seguros, recetas y establecimientos sin gluten.

## Funcionalidades

### Vista del Usuario
1. **Navegación Principal**: Acceso directo a Recetas, Establecimientos, y Productos a través de un carrusel interactivo.
2. **Escaneo de Productos**: Permite verificar si los productos contienen gluten utilizando la cámara del dispositivo para escanear códigos de barras.
3. **Listado de Recetas**: Visualización y aportación de recetas validadas por el administrador.
4. **Mapa de Establecimientos**: Funcionalidad de geolocalización que muestra establecimientos seguros para celíacos.
5. **Perfil del Usuario**: Gestión de información personal y recetas añadidas por el usuario.

### Vista del Administrador
1. **Gestión de Usuarios**: Administración de perfiles de usuario y concesión/revocación de derechos administrativos.
2. **Gestión de Recetas**: Aprobación y administración de recetas para asegurar que no contienen gluten.
3. **Geolocalización de Establecimientos**: Añadir y gestionar información de establecimientos garantizando precisión y utilidad.

## Tecnologías Utilizadas
La aplicación utiliza Flutter para proporcionar una interfaz de usuario coherente y responsiva en Android. La interacción con datos se realiza a través de HTTP con una API interna y una API externa para detalles de productos.

## Seguridad
Implementación de JWT para autenticación, asegurando que sólo los usuarios autenticados puedan realizar operaciones específicas dentro de la aplicación.
