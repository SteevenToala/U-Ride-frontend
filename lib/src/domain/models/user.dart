import 'package:indriver_clone_flutter/src/data/api/ApiConfig.dart';
import 'package:indriver_clone_flutter/src/domain/models/Role.dart';

class User {
    int? id;
    String name;
    String lastname;
    String? email;
    String? phone;
    String? password;
    String? image;
    String? career;
    String? referenceZone;
    String? notificationToken;
    DateTime? createdAt;
    DateTime? updatedAt;
    List<Role>? roles;

    User({
        this.id,
        required this.name,
        required this.lastname,
        this.email,
        this.phone,
        this.image,
        this.career,
        this.referenceZone,
        this.password,
        this.notificationToken,
        this.createdAt,
        this.updatedAt,
        this.roles,
    });

    factory User.fromJson(Map<String, dynamic> json) {
        String? imagePath = json["image"];
        if (imagePath != null && imagePath.startsWith('/uploads/')) {
            imagePath = 'http://${ApiConfig.API_PROJECT}$imagePath';
        }
        
        return User(
            id: json["id"],
            name: json["name"],
            lastname: json["lastname"],
            email: json["email"],
            phone: json["phone"],
            career: json["career"],
            referenceZone: json["reference_zone"],
            image: imagePath,
            password: json['password'],
            notificationToken: json["notification_token"],
            roles: json["roles"] != null ? List<Role>.from(json["roles"].map((x) => Role.fromJson(x))) : [],
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "lastname": lastname,
        "email": email,
        "phone": phone,
        "career": career,
        "reference_zone": referenceZone,
        "image": image,
        'password': password,
        "notification_token": notificationToken,
        "roles": roles != null ? List<dynamic>.from(roles!.map((x) => x.toJson())) : [],
    };
}