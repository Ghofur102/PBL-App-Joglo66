enum NotificationType {
  cancelRequest('cancel_request'),
  rescheduleRequest('reschedule_request'),
  cancelInfo('cancel_info'),
  rescheduleInfo('reschedule_info'),
  cancelApproved('cancel_approved'),
  cancelRejected('cancel_rejected'),
  rescheduleApproved('reschedule_approved'),
  rescheduleRejected('reschedule_rejected'),
  cancelByAdmin('cancel_by_admin'),
  rescheduleByAdmin('reschedule_by_admin'),
  unknown('unknown');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromValue(String? val) {
    return NotificationType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => NotificationType.unknown,
    );
  }

  bool get isCancel =>
      this == NotificationType.cancelRequest ||
      this == NotificationType.cancelInfo ||
      this == NotificationType.cancelApproved ||
      this == NotificationType.cancelRejected ||
      this == NotificationType.cancelByAdmin;

  bool get isReschedule =>
      this == NotificationType.rescheduleRequest ||
      this == NotificationType.rescheduleInfo ||
      this == NotificationType.rescheduleApproved ||
      this == NotificationType.rescheduleRejected ||
      this == NotificationType.rescheduleByAdmin;

  bool get isActionableRequest =>
      this == NotificationType.cancelRequest ||
      this == NotificationType.rescheduleRequest;
}
