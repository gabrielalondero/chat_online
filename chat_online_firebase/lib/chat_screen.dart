import 'dart:io';
import 'package:chat_online_firebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //sempre que a autenticação mudar, chama a função anonima com o usuario atual
    //que pode ser nulo ou usuario logado
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

//Fazendo login com o Google
  Future<User?> _getUser() async {
    //se já estiver logado, retorna o user
    if (_currentUser != null) return _currentUser;
    //senão
    try {
      //faz o sign in e, dependendo do resultado, retorna a conta da pessoa que logou
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      //pegar os dados de autenticação do google (um idtoken e um token de acesso)
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      //conexão com o firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      //login no firebase
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      //pega o usuário do firebase, através dele voce pode validar o acesso ao banco de dados
      final User? user = authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String? text, File? imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possivel fazer o login, tente novamente!'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
    //se user não for null, coloca os dados do usuário
    Map<String, dynamic> data = {
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoURL,
      'time' : Timestamp.now(),
    };

    if (imgFile != null) {
      setState(() {
        _isLoading = true;
      });

      //.child() - coloca o nome do arquivo (ou nome da pasta, colocando outro child depois com o nome do arquivo)
      UploadTask task = FirebaseStorage.instance
          .ref() //obter a referência do firebaseStorage
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString()) //nome único
          .putFile(imgFile); //envia o arquivo para o firebaseStorage
      TaskSnapshot taskSnapshot = await task; //traz informações sobre a task
      String url = await taskSnapshot.ref.getDownloadURL(); //url da foto
      data['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) {
      data['text'] = text;
    }

    //.add já cria dentro da coleção um documento e coloca os dados dentro
    FirebaseFirestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser!.displayName}'
            : 'Chat App'),
        centerTitle: true,
        elevation: 2,
        actions: [
          _currentUser != null
              ? IconButton(
                  onPressed: () {
                    //fazer logout
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Você saiu com sucesso!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.exit_to_app),
                )
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            //com o StreamBuilder, pode-se apontar para a colecção,
            //e sempre que algo mudar na coleção pode-se refazer o StreamBuilder recriando a lista
            child: StreamBuilder<QuerySnapshot>(
              //diferente do future que retorna o dado apenas uma vez,
              //o stream retorna conforme o tempo quando existir uma modificação
              //o snapshot é uma stream
              stream:
                  FirebaseFirestore.instance.collection('messages').orderBy('time').snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> docs = snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      itemCount: docs.length,
                      reverse: true, //mensagens aparecendo de baixo para cima
                      itemBuilder: (context, index) {
                        return ChatMessage(
                          data: docs[index].data() as Map<String, dynamic>,
                          mine: docs[index].get('uid') == _currentUser?.uid,
                        );
                      },
                    );
                }
              },
            ),
          ),
          //indicativo de 'carregando imagem'
          _isLoading ? const LinearProgressIndicator() : Container(),
          //passa por parâmetro a função para o TextComposer
          TextComposer(sendMessage: _sendMessage),
        ],
      ),
    );
  }
}
