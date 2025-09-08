# Configuración de Google Maps API

## Pasos para configurar Google Maps en EcoMove

### 1. Crear un proyecto en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita las siguientes APIs:
   - Maps SDK for Android
   - Geocoding API (opcional, para mejores funciones de búsqueda)

### 2. Obtener la clave API

1. Ve a "APIs y servicios" > "Credenciales"
2. Clic en "Crear credenciales" > "Clave de API"
3. Copia la clave generada

### 3. Configurar la clave en Android

1. Abre el archivo `android/app/src/main/AndroidManifest.xml`
2. Busca la línea que contiene `YOUR_GOOGLE_MAPS_API_KEY_HERE`
3. Reemplaza `YOUR_GOOGLE_MAPS_API_KEY_HERE` con tu clave real:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_CLAVE_API_AQUI" />
```

### 4. Configurar restricciones de seguridad (Recomendado)

En Google Cloud Console:
1. Ve a "APIs y servicios" > "Credenciales"
2. Clic en tu clave API
3. En "Restricciones de aplicación", selecciona "Aplicaciones de Android"
4. Agrega el nombre del paquete: `com.example.eco_move`
5. Agrega la huella digital SHA-1 de tu certificado

### 5. Obtener la huella digital SHA-1

Para desarrollo (debug):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Para producción, usa tu keystore de firma.

### 6. Funciones disponibles

Con Google Maps configurado, podrás usar:
- ✅ Visualización de mapas en el detalle de estaciones
- ✅ Selección de ubicación con GPS
- ✅ Búsqueda de direcciones y conversión a coordenadas
- ✅ Marcadores en el mapa para ubicaciones de estaciones

### ⚠️ Nota importante

- Las funciones de ubicación funcionarán sin Google Maps API
- Los mapas visuales requieren la configuración de la API
- Sin la API configurada, verás un mapa vacío o con marcas de agua

### 🔒 Buenas prácticas de seguridad

1. **Nunca** incluyas tu clave API en el control de versiones público
2. Configura restricciones apropiadas en Google Cloud Console
3. Considera usar diferentes claves para desarrollo y producción
4. Monitorea el uso de tu API regularmente

### 💰 Costos

Google Maps tiene una capa gratuita que incluye:
- 28,000 cargas de mapas por mes gratis
- 40,000 solicitudes de geocodificación por mes gratis

Para la mayoría de aplicaciones pequeñas, esto es suficiente.
