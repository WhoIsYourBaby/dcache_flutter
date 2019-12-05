/// The cache policy
enum DCachePolicy {
  // Use cache data first, if the cache data does not exist, then make the request
  cacheFirst,
  // Make request first, if the request returns an error, the cache is used
  refreshFirst,
  // Just make request, and the response will be cached.
  justRefresh,
}

/// Every request can make its own DCacheOptions.
/// The DCacheOptions will be passed over extra
class DCacheOptions {
  Duration age;
  DCachePolicy policy;

  DCacheOptions({
    this.age,
    this.policy,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'age': age?.inMilliseconds,
        'policy': policy?.index,
      };

  factory DCacheOptions.fromJson(Map<String, dynamic> json) => DCacheOptions(
        age: json['age'] == null
            ? null
            : Duration(milliseconds: json['age'] as int),
        policy: json['policy'] == null
            ? null
            : DCachePolicy.values[json['policy'] as int],
      );

  DCacheOptions merge(DCacheOptions anothoer) {
    final old = this.toJson();
    final ano = anothoer.toJson();
    ano.removeWhere((key, value) {
      return value == null;
    });
    final entries = ano.entries;
    old.addEntries(entries);
    return DCacheOptions.fromJson(old);
  }
}