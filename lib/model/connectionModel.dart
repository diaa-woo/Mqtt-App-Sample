class ConnectionModel{
  final String userNickName;
  final String chat;
  const ConnectionModel({required this.userNickName, required this.chat});
  factory ConnectionModel.json(Map<String, dynamic> json) => ConnectionModel(
      userNickName: json['userNickName'].toString(),
      chat: json['chat'].toString()
  );
}