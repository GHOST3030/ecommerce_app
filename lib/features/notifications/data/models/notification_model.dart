class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.orderId,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? orderId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:        json['id']         as String,
      userId:    json['user_id']    as String,
      title:     json['title']      as String,
      body:      json['body']       as String? ?? '',
      type:      json['type']       as String,
      isRead:    json['is_read']    as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      orderId:   json['order_id']   as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':         id,
        'user_id':    userId,
        'title':      title,
        'body':       body,
        'type':       type,
        'is_read':    isRead,
        'created_at': createdAt.toIso8601String(),
        'order_id':   orderId,
      };
}
