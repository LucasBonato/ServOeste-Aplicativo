import 'package:serv_oeste/src/utils/skeleton/skeleton_generator.dart';
import 'package:serv_oeste/src/utils/skeleton/skeletonizable.dart';

class UserResponse extends Skeletonizable {
  int? id;
  String? username;
  String? role;

  UserResponse({
    this.id,
    this.username,
    this.role
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    id: json["id"],
    username: json["username"],
    role: json["role"],
  );

  @override
  void applySkeletonData() {
    id = SkeletonDataGenerator.integer();
    username = SkeletonDataGenerator.name();
    role = SkeletonDataGenerator.string(length: 5);
  }
}
