extension RoleConversions on String {
  String toBackendRole() {
    return switch (this) {
      'Administrador' => 'ADMIN',
      'Balcão' => 'EMPLOYEE',
      'Técnico' => 'TECHNICIAN',
      _ => 'EMPLOYEE',
    };
  }

  String toDisplayRole() {
    return switch (this) {
      'ADMIN' => 'Administrador',
      'EMPLOYEE' => 'Balcão',
      'TECHNICIAN' => 'Técnico',
      _ => 'Balcão',
    };
  }
}
