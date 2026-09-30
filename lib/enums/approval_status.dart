enum ApprovalStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  none('none');

  final String value;
  const ApprovalStatus(this.value);

  static ApprovalStatus fromValue(String? val) {
    return ApprovalStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => ApprovalStatus.none,
    );
  }

  bool get isPending => this == ApprovalStatus.pending;
  bool get isApproved => this == ApprovalStatus.approved;
  bool get isRejected => this == ApprovalStatus.rejected;
}
