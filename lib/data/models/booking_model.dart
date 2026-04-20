/// Booking model for booking calendar and status management
class BookingModel {
  final int? bookingId;
  final int? esId;
  final int? spId;
  final int? userId;
  final String? userName;
  final String? userPhone;
  final String? userEmail;
  final String? serviceName;
  final String? status;
  final String? bookingDate;
  final String? startTime;
  final String? endTime;
  final double? amount;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const BookingModel({
    this.bookingId,
    this.esId,
    this.spId,
    this.userId,
    this.userName,
    this.userPhone,
    this.userEmail,
    this.serviceName,
    this.status,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.amount,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'] as int?,
      esId: json['esId'] as int?,
      spId: json['spId'] as int?,
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      userPhone: json['userPhone'] as String?,
      userEmail: json['userEmail'] as String?,
      serviceName: json['serviceName'] as String?,
      status: json['status'] as String?,
      bookingDate: json['bookingDate'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bookingId != null) 'bookingId': bookingId,
      if (esId != null) 'esId': esId,
      if (spId != null) 'spId': spId,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      if (userPhone != null) 'userPhone': userPhone,
      if (userEmail != null) 'userEmail': userEmail,
      if (serviceName != null) 'serviceName': serviceName,
      if (status != null) 'status': status,
      if (bookingDate != null) 'bookingDate': bookingDate,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (amount != null) 'amount': amount,
      if (notes != null) 'notes': notes,
    };
  }

  BookingModel copyWith({String? status}) {
    return BookingModel(
      bookingId: bookingId,
      esId: esId,
      spId: spId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      userEmail: userEmail,
      serviceName: serviceName,
      status: status ?? this.status,
      bookingDate: bookingDate,
      startTime: startTime,
      endTime: endTime,
      amount: amount,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
