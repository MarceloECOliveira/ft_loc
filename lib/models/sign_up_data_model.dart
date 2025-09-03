class SignUpDataModel {
  String nome;
  String idade;
  String curso;
  String anoDeIngresso;

  SignUpDataModel({
    required this.nome,
    required this.idade,
    required this.curso,
    this.anoDeIngresso = "Não informado",
  });

  factory SignUpDataModel.fromMap(Map<String, dynamic> map) {
    return SignUpDataModel(
      nome: map['nome'] ?? 'Nome não encontrado',
      idade: map['idade'] ?? 'Idade não encontrada',
      curso: map['curso'] ?? 'Curso não encontrado',
      anoDeIngresso: map['anoDeIngresso'] ?? 'Não informado',
    );
  }

  Map<String, String> toMap() {
    Map<String, String> map = {};
    map["nome"] = nome;
    map["idade"] = idade;
    map["curso"] = curso;
    map["anoDeIngresso"] = anoDeIngresso;
    return map;
  }
}
