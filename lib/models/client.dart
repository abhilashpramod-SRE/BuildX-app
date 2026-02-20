class Client {
  Client({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    List<String>? projects,
  }) : projects = List<String>.unmodifiable(projects ?? <String>[]);

  final String id;
  final String name;
  final String address;
  final String phone;
  final List<String> projects;

  Client copyWith({
    String? name,
    String? address,
    String? phone,
    List<String>? projects,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      projects: projects ?? this.projects,
    );
  }
}
