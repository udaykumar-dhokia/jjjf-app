class NewsModel {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final bool isShokSandesh;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.isShokSandesh = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      isShokSandesh: json['isShokSandesh'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'images': images,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'isShokSandesh': isShokSandesh,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NewsModel.dummy() {
    return NewsModel(
      id: 'dummy',
      title: 'This is a dummy title',
      description: 'This is a dummy description that is slightly longer to show how the skeleton handles multiple lines of text in the UI.',
      images: ['https://api.dicebear.com/10.x/glass/png?seed=dummy'],
      userId: 'dummy_user',
      userName: 'Dummy User',
      isShokSandesh: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
