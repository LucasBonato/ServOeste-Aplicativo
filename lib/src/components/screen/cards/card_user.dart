import 'package:flutter/material.dart';
import 'package:serv_oeste/features/user/domain/entities/user_response.dart';
import 'package:serv_oeste/src/utils/formatters/formatters.dart';

class UserCard extends StatelessWidget {
  final UserResponse user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDeleteButton;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = user.role == 'ADMIN';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double titleSize = Formatters.getResponsiveFontSize(constraints.maxWidth, min: 16, max: 20, factor: 0.04);
            final double subtitleSize = Formatters.getResponsiveFontSize(constraints.maxWidth, min: 14, max: 16, factor: 0.03);
            final double iconSize = Formatters.getResponsiveFontSize(constraints.maxWidth, min: 20, max: 24, factor: 0.045);

            return Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.red[50] : Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: isAdmin ? Colors.red[700] : Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.username!,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: isAdmin ? Colors.red[800] : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.getRoleDisplayName(user.role ?? ""),
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue[700],
                        size: iconSize,
                      ),
                      onPressed: onEdit,
                      tooltip: 'Editar usuário',
                    ),
                    if (showDeleteButton && !isAdmin)
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: iconSize,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Excluir usuário',
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
