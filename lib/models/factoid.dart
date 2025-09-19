class Factoid {
  final String fact;

  Factoid({required this.fact});

  factory Factoid.fromJson(Map<String, dynamic> json) {
    return Factoid(
      fact: json['fact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fact': fact,
    };
  }
}
