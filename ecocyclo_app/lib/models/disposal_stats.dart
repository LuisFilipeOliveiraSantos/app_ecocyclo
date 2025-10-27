class DisposalStats {
  final int inProgress;
  final int finished;

  DisposalStats({required this.inProgress, required this.finished});

  factory DisposalStats.fromJson(Map<String, dynamic> json) {
    return DisposalStats(
      inProgress: json['in_progress'] ?? 0,
      finished: json['finished'] ?? 0,
    );
  }
}
