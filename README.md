# 🚲 EcoMove - Sistema de Transporte Ecológico

## 📱 Descripción
EcoMove es una aplicación móvil desarrollada en Flutter que facilita el acceso a medios de transporte sostenibles como bicicletas, patinetas y scooters eléctricos. El sistema permite a los usuarios registrarse, encontrar estaciones cercanas, tomar transportes en préstamo y devolverlos en cualquier estación de la red.

## ✨ Funcionalidades Principales

### 🔐 Gestión de Usuarios
- **Registro completo** con datos básicos (nombre, correo, documento)
- **Autenticación segura** con Firebase Auth
- **Perfil de usuario** con estadísticas personalizadas

### 🗺️ Gestión de Estaciones
- **Visualización** de todas las estaciones disponibles
- **Información detallada** de ubicación y capacidad
- **Disponibilidad en tiempo real** por tipo de transporte
- **Agregar nuevas estaciones** (funcionalidad administrativa)

### 🚴‍♂️ Gestión de Transportes
- **3 tipos de transporte:** Bicicletas, Patinetas, Scooters eléctricos
- **Consulta de disponibilidad** en cada estación
- **Agregar transportes** a las estaciones
- **Estado en tiempo real** (disponible/en uso)

### 💰 Sistema de Préstamos
- **Tomar transporte** desde cualquier estación
- **Cálculo automático de costos:**
  - 🚲 Bicicleta: $1.00 base + $0.10/minuto
  - 🛹 Patineta: $1.00 base + $0.15/minuto
  - 🛴 Scooter: $1.00 base + $0.20/minuto
- **Devolución flexible** en cualquier estación
- **Pago en efectivo** al finalizar el préstamo

### 📊 Historial y Estadísticas
- **Historial completo** de préstamos por usuario
- **Préstamos activos** con tiempo transcurrido en tiempo real
- **Estadísticas personalizadas:**
  - Total de viajes realizados
  - Gasto total acumulado
  - Tiempo total de uso
  - Promedios por viaje

## 🛠️ Tecnologías Utilizadas

- **Frontend:** Flutter 3.x
- **Backend:** Firebase (Firestore + Authentication)
- **Lenguaje:** Dart
- **Base de datos:** Cloud Firestore (NoSQL)
- **Autenticación:** Firebase Auth
- **Estado:** StreamBuilder para actualizaciones en tiempo real

## 📋 Requisitos del Sistema

- Flutter SDK 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio / VS Code
- Firebase CLI (para configuración)
- Dispositivo Android/iOS o Emulador

## 🚀 Instalación y Configuración

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/eco_move.git
cd eco_move
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar Firebase
1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Agregar app Android/iOS
3. Descargar `google-services.json` (Android) o `GoogleService-Info.plist` (iOS)
4. Colocar archivos en las carpetas correspondientes
5. Habilitar Authentication y Firestore

### 4. Ejecutar la aplicación
```bash
flutter run
```

## 📱 Pantallas de la Aplicación

### 🏠 Pantalla Principal
- Dashboard con información del usuario
- Estado de préstamos activos
- Accesos rápidos a funcionalidades principales
- Información del sistema

### 🗺️ Estaciones
- Lista de todas las estaciones
- Búsqueda y filtros
- Información de disponibilidad
- Detalle de cada estación

### 🚲 Detalle de Estación
- Transportes disponibles por tipo
- Funcionalidad para tomar préstamo
- Gestión de transportes (agregar/editar)
- Información de capacidad

### 📋 Préstamos
- **Tab Activos:** Préstamos en curso con timer
- **Tab Historial:** Histórico completo de préstamos
- Funcionalidad de devolución
- Detalles de costos y duración

### 📊 Estadísticas
- Resumen de actividad del usuario
- Gráficos de uso y gastos
- Información detallada de rendimiento

## 🏗️ Arquitectura del Proyecto (MVC + Provider)

```
lib/
├── controllers/          # Controladores (Lógica de negocio)
│   ├── auth_controller.dart
│   └── transport_controller.dart
├── models/              # Modelos de datos
│   ├── user_model.dart
│   ├── station_model.dart
│   ├── transport_model.dart
│   └── loan_model.dart
├── providers/           # Providers (Estado y Modelo)
│   ├── user_provider.dart
│   └── transport_provider.dart
├── services/            # Servicios (Acceso a datos)
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── data_seeder.dart
├── screens/             # Vistas de la aplicación
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── home_tab.dart
│   ├── stations_screen.dart
│   ├── station_detail_screen.dart
│   ├── loans_screen.dart
│   └── statistics_screen.dart
└── main.dart            # Punto de entrada con MultiProvider
```

### 📐 Patrón Arquitectónico

**Modelo-Vista-Controlador (MVC) con Provider Pattern:**

#### 🔧 **Modelo (Models + Providers + Services)**
- **Models**: Definición de estructuras de datos (`UserModel`, `StationModel`, etc.)
- **Providers**: Gestión de estado global con `ChangeNotifier`
  - `UserProvider`: Estado de autenticación y préstamos del usuario
  - `TransportProvider`: Estado de estaciones y transportes
- **Services**: Acceso a datos (Firebase, APIs)
  - `AuthService`: Autenticación con Firebase Auth
  - `DatabaseService`: Operaciones con Firestore

#### 🎨 **Vista (Screens)**
- **Screens**: Widgets de interfaz de usuario
- Utilizan `Consumer<Provider>` para escuchar cambios de estado
- No contienen lógica de negocio, solo presentación

#### 🎮 **Controlador (Controllers)**
- **AuthController**: Maneja inicio/cierre de sesión y registro
- **TransportController**: Maneja operaciones de transportes y estaciones
- Coordinan entre las Vistas y el Modelo
- Manejan validaciones y navegación

### 🔄 Flujo de Datos

```
Vista → Controlador → Provider → Service → Firebase
  ↑                                           ↓
  ←←←←←← Estado actualizado ←←←←←←←←←←←←←←←←←←←←←
```

## 📊 Modelo de Datos

### Usuario
- ID, nombre, email, documento de identidad

### Estación
- ID, nombre, ubicación, capacidad total

### Transporte
- ID, tipo (bicicleta/patineta/scooter), estación actual, disponibilidad

### Préstamo
- ID, usuario, transporte, tiempo inicio/fin, estación origen/destino, costo

## 👨‍💻 Autor

**Cristian** - Proyecto de Programación Orientada a Objetos

---

📱 **¡Descarga EcoMove y contribuye a un transporte más sostenible!** 🌱
