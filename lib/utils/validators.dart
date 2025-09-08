class Validators {
  // Validación de nombres (solo letras y espacios)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    
    // Verificar si contiene números
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'El nombre no puede contener números';
    }
    
    // Verificar caracteres especiales no permitidos
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'El nombre no puede contener símbolos especiales';
    }
    
    // Solo permitir letras, espacios y algunos caracteres especiales del español
    final nameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'El nombre solo puede contener letras, espacios, guiones y apostrofes';
    }
    
    return null;
  }

  // Validación de email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    
    return null;
  }

  // Validación de contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    if (value.length > 50) {
      return 'La contraseña no puede exceder 50 caracteres';
    }
    
    // Al menos una letra
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra';
    }
    
    // Al menos un número
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'La contraseña debe contener al menos un número';
    }
    
    return null;
  }

  // Validación de documento de identidad
  static String? validateDocument(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El documento de identidad es obligatorio';
    }
    
    // Remover espacios y guiones
    final cleanValue = value.replaceAll(RegExp(r'[\s\-]'), '');
    
    if (cleanValue.length < 7 || cleanValue.length > 12) {
      return 'El documento debe tener entre 7 y 12 dígitos';
    }
    
    // Solo números
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'El documento solo puede contener números';
    }
    
    return null;
  }

  // Validación de teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Campo opcional
    }
    
    // Remover espacios, guiones y paréntesis
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleanValue.length < 7 || cleanValue.length > 15) {
      return 'El teléfono debe tener entre 7 y 15 dígitos';
    }
    
    // Solo números (puede empezar con +)
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleanValue)) {
      return 'El teléfono solo puede contener números y el símbolo +';
    }
    
    return null;
  }

  // Validación de capacidad numérica
  static String? validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La capacidad es obligatoria';
    }
    
    final capacity = int.tryParse(value.trim());
    if (capacity == null) {
      return 'La capacidad debe ser un número válido';
    }
    
    if (capacity <= 0) {
      return 'La capacidad debe ser mayor a 0';
    }
    
    if (capacity > 100) {
      return 'La capacidad no puede exceder 100 transportes';
    }
    
    return null;
  }

  // Validación de ubicación/dirección
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La ubicación es obligatoria';
    }
    
    if (value.trim().length < 5) {
      return 'La ubicación debe tener al menos 5 caracteres';
    }
    
    if (value.trim().length > 200) {
      return 'La ubicación no puede exceder 200 caracteres';
    }
    
    return null;
  }

  // Validación de nombre de transporte
  static String? validateTransportName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del transporte es obligatorio';
    }
    
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    
    if (value.trim().length > 30) {
      return 'El nombre no puede exceder 30 caracteres';
    }
    
    return null;
  }

  // Validación de números decimales (para características de transporte)
  static String? validateDecimalNumber(String? value, String fieldName, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Campo opcional por defecto
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName debe ser un número válido';
    }
    
    if (min != null && number < min) {
      return '$fieldName debe ser mayor o igual a $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName debe ser menor o igual a $max';
    }
    
    return null;
  }

  // Validación de confirmación de contraseña
  static String? validatePasswordConfirmation(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  // Validación de búsqueda (para filtros)
  static String? validateSearch(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // La búsqueda puede estar vacía
    }
    
    if (value.trim().length > 100) {
      return 'La búsqueda no puede exceder 100 caracteres';
    }
    
    return null;
  }
}
