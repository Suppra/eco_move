class AuthErrorMessages {
  static String getLoginErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico. ¿Deseas registrarte?';
      case 'wrong-password':
        return 'Contraseña incorrecta. Verifica tus credenciales e intenta nuevamente.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta al soporte técnico.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta nuevamente en unos minutos.';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas son incorrectas o han expirado.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      default:
        return 'Error al iniciar sesión: $errorCode';
    }
  }

  static String getRegisterErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico. ¿Deseas iniciar sesión?';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'operation-not-allowed':
        return 'El registro con correo y contraseña no está habilitado.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres con letras y números.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      default:
        return 'Error al registrar usuario: $errorCode';
    }
  }

  static String getPasswordResetErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'too-many-requests':
        return 'Demasiadas solicitudes. Intenta nuevamente en unos minutos.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      default:
        return 'Error al enviar correo de recuperación: $errorCode';
    }
  }

  static String getGenericErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'permission-denied':
        return 'No tienes permisos para realizar esta acción.';
      case 'unavailable':
        return 'El servicio no está disponible. Intenta más tarde.';
      case 'deadline-exceeded':
        return 'La operación tardó demasiado. Intenta nuevamente.';
      case 'not-found':
        return 'El recurso solicitado no fue encontrado.';
      case 'already-exists':
        return 'El recurso ya existe en el sistema.';
      case 'invalid-argument':
        return 'Los datos proporcionados no son válidos.';
      case 'resource-exhausted':
        return 'Se ha excedido el límite de uso. Intenta más tarde.';
      case 'failed-precondition':
        return 'No se cumplen las condiciones necesarias para esta operación.';
      case 'aborted':
        return 'La operación fue cancelada. Intenta nuevamente.';
      case 'out-of-range':
        return 'Los datos están fuera del rango permitido.';
      case 'unimplemented':
        return 'Esta funcionalidad no está implementada.';
      case 'internal':
        return 'Error interno del servidor. Intenta más tarde.';
      case 'data-loss':
        return 'Se detectó pérdida de datos. Contacta al soporte técnico.';
      case 'unauthenticated':
        return 'Necesitas iniciar sesión para acceder a esta función.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      default:
        return 'Error desconocido: $errorCode';
    }
  }
}
