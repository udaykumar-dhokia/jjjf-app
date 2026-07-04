class MatrimonialAccessRequest {
  final String id;
  final String requesterId;
  final String targetId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Minimal info about the other person in the request
  final String? otherPersonName;
  final String? otherPersonGotra;

  MatrimonialAccessRequest({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.otherPersonName,
    this.otherPersonGotra,
  });

  factory MatrimonialAccessRequest.fromJson(Map<String, dynamic> json, {bool isSent = true}) {
    // If isSent, the 'target' details are provided.
    // If !isSent (received), the 'requester' details are provided.
    final userNode = isSent ? json['target'] : json['requester'];
    
    return MatrimonialAccessRequest(
      id: json['id'] ?? '',
      requesterId: json['requesterId'] ?? '',
      targetId: json['targetId'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      otherPersonName: userNode != null ? userNode['firstName'] : null,
      otherPersonGotra: userNode != null ? userNode['gotra'] : null,
    );
  }
}
