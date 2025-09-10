extension RoleConversions on String {
  String toBackendRole() {
    return switch (this) {
      'Administrador' => 'ADMIN',
      'Funcionário' => 'EMPLOYEE',
      'Técnico' => 'TECHNICIAN',
      _ => 'EMPLOYEE',
    };
  }

  String toDisplayRole() {
    return switch (this) {
      'ADMIN' => 'Administrador',
      'EMPLOYEE' => 'Funcionário',
      'TECHNICIAN' => 'Técnico',
      _ => 'Funcionário',
    };
  }
}
