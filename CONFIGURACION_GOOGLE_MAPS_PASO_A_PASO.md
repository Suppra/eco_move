# 🗺️ Configuración de Google Maps API - Guía Paso a Paso

## 📋 Paso 1: Crear Proyecto en Google Cloud Console

### 1.1 Acceder a Google Cloud Console
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Inicia sesión con tu cuenta de Google
3. Si es tu primera vez, acepta los términos y condiciones

### 1.2 Crear un Nuevo Proyecto
1. En la parte superior, haz clic en el selector de proyectos
2. Clic en "Nuevo Proyecto"
3. Nombra tu proyecto: `EcoMove-Maps` (o el nombre que prefieras)
4. Haz clic en "Crear"
5. Espera unos segundos hasta que se cree el proyecto
6. Selecciona el proyecto recién creado

## 📋 Paso 2: Habilitar APIs Necesarias

### 2.1 Ir a la Biblioteca de APIs
1. En el menú de la izquierda, ve a "APIs y servicios" → "Biblioteca"
2. O usa este enlace directo: [API Library](https://console.cloud.google.com/apis/library)

### 2.2 Habilitar Maps SDK for Android
1. En la barra de búsqueda, escribe: "Maps SDK for Android"
2. Haz clic en el resultado "Maps SDK for Android"
3. Clic en "HABILITAR"
4. Espera a que se habilite (puede tardar unos minutos)

### 2.3 Habilitar Geocoding API (Opcional pero Recomendado)
1. Regresa a la biblioteca de APIs
2. Busca: "Geocoding API"
3. Haz clic en "Geocoding API"
4. Clic en "HABILITAR"

## 📋 Paso 3: Crear Clave API

### 3.1 Ir a Credenciales
1. En el menú izquierdo, ve a "APIs y servicios" → "Credenciales"
2. O usa este enlace: [Credentials](https://console.cloud.google.com/apis/credentials)

### 3.2 Crear la Clave API
1. Haz clic en "+ CREAR CREDENCIALES"
2. Selecciona "Clave de API"
3. Se generará automáticamente una clave
4. **¡IMPORTANTE!** Copia inmediatamente esta clave y guárdala en un lugar seguro
5. La clave se verá algo así: `AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

## 📋 Paso 4: Configurar Restricciones de Seguridad

### 4.1 Restringir la Clave API
1. En la pantalla de la clave recién creada, haz clic en "RESTRINGIR CLAVE"
2. O ve a "Credenciales" y haz clic en el ícono de editar (lápiz) de tu clave

### 4.2 Configurar Restricciones de Aplicación
1. En "Restricciones de aplicación", selecciona "Aplicaciones de Android"
2. Haz clic en "Agregar elemento"
3. En "Nombre del paquete", ingresa: `com.example.eco_move`
4. En "Huella digital SHA-1", necesitarás obtener tu huella digital (ver siguiente paso)

### 4.3 Obtener Huella Digital SHA-1

#### ⚠️ Nota Importante para Windows
Si obtienes un error que dice "keytool no se reconoce como comando", sigue estos pasos:

#### Método 1: Usar la Ruta Completa de Keytool
```powershell
# Buscar la instalación de Java
& "C:\Program Files\Java\jdk-*\bin\keytool.exe" -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# O intenta con esta ruta alternativa:
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

#### Método 2: Agregar Java al PATH (Recomendado)
1. Busca dónde está instalado Java:
   ```powershell
   Get-ChildItem "C:\Program Files\Java" -Recurse -Name "keytool.exe"
   Get-ChildItem "C:\Program Files\Android\Android Studio" -Recurse -Name "keytool.exe"
   ```

2. Una vez que encuentres la ruta, agrégala temporalmente:
   ```powershell
   # Ejemplo si está en Android Studio:
   $env:PATH += ";C:\Program Files\Android\Android Studio\jbr\bin"
   
   # Ahora ya puedes usar keytool:
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

#### Método 3: Usar Android Studio (Más Fácil)
1. Abre Android Studio
2. Ve a "View" → "Tool Windows" → "Terminal"
3. En la terminal de Android Studio ejecuta:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

#### Método 4: Usar Gradle Task (Más Fácil)
1. Abre Android Studio
2. Ve a "View" → "Tool Windows" → "Gradle"
3. Navega a: `YourApp > Tasks > android > signingReport`
4. Doble clic en "signingReport"
5. En la consola verás las huellas digitales SHA-1

#### Para Desarrollo (Debug):
```bash
# Si ya tienes keytool en PATH o usas Android Studio Terminal:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# En Windows PowerShell con ruta completa:
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

#### ✅ Lo que debes buscar en la salida:
Busca una línea que se vea así:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

#### En macOS/Linux:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 4.4 Agregar la Huella Digital
1. Copia la huella digital SHA-1 (se ve como: `AA:BB:CC:DD:EE:FF:...`)
2. Pégala en el campo "Huella digital SHA-1"
3. Haz clic en "Agregar elemento" si necesitas más huellas (para release)

### 4.5 Configurar Restricciones de API
1. En "Restricciones de API", selecciona "Restringir clave"
2. Marca las siguientes APIs:
   - Maps SDK for Android
   - Geocoding API (si la habilitaste)
3. Haz clic en "GUARDAR"

## 📋 Paso 5: Configurar en la Aplicación

### 5.1 Agregar Clave en AndroidManifest.xml
1. Abre el archivo: `android/app/src/main/AndroidManifest.xml`
2. Busca la línea que dice: `YOUR_GOOGLE_MAPS_API_KEY_HERE`
3. Reemplázala con tu clave real:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" />
```

### 5.2 Verificar Permisos
Asegúrate de que estos permisos estén en el AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## 📋 Paso 6: Probar la Configuración

### 6.1 Compilar la Aplicación
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 6.2 Verificar en la App
1. Ejecuta la aplicación: `flutter run`
2. Ve a "Gestión de Estaciones"
3. Entra a cualquier estación
4. Deberías ver el mapa funcionando (sin marcas de agua)

## 🚨 Solución de Problemas Comunes

### Error: "This page can't load Google Maps correctly"
- **Causa**: Clave API incorrecta o restricciones mal configuradas
- **Solución**: Verifica que la clave esté bien copiada y las restricciones sean correctas

### Error: "Google Maps JavaScript API error: RefererNotAllowedMapError"
- **Causa**: La huella digital SHA-1 no coincide
- **Solución**: Verifica que la huella digital sea la correcta para tu keystore actual

### El mapa aparece gris o vacío
- **Causa**: API no habilitada o límites de facturación
- **Solución**: 
  1. Verifica que "Maps SDK for Android" esté habilitado
  2. Configura facturación en Google Cloud Console (tiene capa gratuita)

### Error de red o timeout
- **Causa**: Problemas de conectividad o firewall
- **Solución**: Verifica tu conexión a internet y permisos de red

## 💰 Información de Facturación

### Capa Gratuita
Google Maps ofrece una generosa capa gratuita:
- **28,000 cargas de mapas móviles por mes GRATIS**
- **40,000 solicitudes de geocodificación por mes GRATIS**
- Esto es suficiente para la mayoría de aplicaciones en desarrollo

### Configurar Facturación (Requerido)
1. Ve a "Facturación" en Google Cloud Console
2. Crea una cuenta de facturación
3. Vincula tu proyecto con la cuenta de facturación
4. **Nota**: No se te cobrará hasta que superes los límites gratuitos

### Establecer Límites de Uso
1. Ve a "APIs y servicios" → "Cuotas"
2. Busca "Maps SDK for Android"
3. Establece límites diarios para evitar cargos inesperados

## ✅ Lista de Verificación Final

- [ ] Proyecto creado en Google Cloud Console
- [ ] Maps SDK for Android habilitado
- [ ] Geocoding API habilitado (opcional)
- [ ] Clave API creada
- [ ] Restricciones de aplicación configuradas
- [ ] Huella digital SHA-1 agregada
- [ ] Restricciones de API configuradas
- [ ] Clave agregada en AndroidManifest.xml
- [ ] Permisos verificados
- [ ] Facturación configurada
- [ ] Aplicación compilada y probada

## 📞 Soporte Adicional

Si tienes problemas:
1. Verifica la [documentación oficial](https://developers.google.com/maps/documentation/android-sdk/get-api-key)
2. Revisa la consola de desarrolladores de Google Cloud para errores
3. Asegúrate de que tu proyecto tenga facturación habilitada
4. Verifica que las APIs estén habilitadas para tu proyecto

---

**¡Listo!** Una vez completados estos pasos, tu aplicación EcoMove tendrá mapas completamente funcionales. 🎉
