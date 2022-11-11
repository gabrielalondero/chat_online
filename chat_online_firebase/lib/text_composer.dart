import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({super.key, required this.sendMessage});

  final Function({String text, File imgFile}) sendMessage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _sendController = TextEditingController();
  bool _isComposing = false;

  //craindo foco para o TextField
  final _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              XFile? imgFile =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              //se a pessoa não tirar a foto(null), retorna
              if (imgFile == null) return;
              //transforma XFile em File
              File fileSend = File(imgFile.path);
              //ao pressionar, chama a função sendMessage (função recebida por parâmetro) passando a foto;
              widget.sendMessage(imgFile: fileSend);
            },
            icon: const Icon(Icons.photo_camera),
          ),
          Expanded(
            child: TextField(
              focusNode: _focus,
              controller: _sendController,
              //collapsed para o campo ficar expremido na parte de baixo
              decoration: const InputDecoration.collapsed(
                  hintText: "Enviar uma mensagem"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              //ao submeter, chama a função sendMessage (função recebida por parâmetro) passando o texto;
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  widget.sendMessage(text: text);
                  _reset();
                } else {
                  //quando clicar e o campo estiver vazio, vai focar o campo vazio
                  FocusScope.of(context).requestFocus(_focus);
                }
              },
            ),
          ),
          IconButton(
            //se estiver com texto no campo, vai ter uma função, senão, vai ter nulo(desabilita o botão)
            onPressed: _isComposing
                ? () {
                    FocusScope.of(context).requestFocus(_focus);
                    widget.sendMessage(text: _sendController.text);
                    _reset();
                  }
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _reset() {
    _sendController.clear();
    setState(() {
      _isComposing = false;
    });
  }
}
