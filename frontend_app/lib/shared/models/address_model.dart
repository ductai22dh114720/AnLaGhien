import 'package:equatable/equatable.dart';

class Province extends Equatable {
  final int id;
  final String name;

  const Province({required this.id, required this.name});

  // factory Province.fromJson(Map<String, dynamic> json) {
  //   return Province(id: json['id'], name: json['name']);
  // }
  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['code'], // Sửa id thành code
      name: json['name'],
    );
  }
  @override
  List<Object?> get props => [id]; // <-- So sánh các đối tượng Province dựa trên id
}

class District extends Equatable {
  final int id;
  final String name;

  const District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(id: json['id'], name: json['name']);
  }

  @override
  List<Object?> get props => [id]; // <-- So sánh các đối tượng District dựa trên id
}

class Ward extends Equatable {
  final int id;
  final String name;

  const Ward({required this.id, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(id: json['id'], name: json['name']);
  }

  @override
  List<Object?> get props => [id]; // <-- So sánh các đối tượng Ward dựa trên id
}
