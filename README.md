# Chat Online Usando Firebase
 - Possui autenticação do login pelo Google.
 - Foi utilizado o Firebase para o backend.
 - Armazena no banco de dados as mensagens que são trocadas dentro do app.
 - Somente permite enviar mensagens se estiver logado.
 - Pode enviar mensagens de texto ou imagens.
 - Dependências utilizadas: 
     - `cloud_firestore` para acessar o firestore do firebase 
     - `image_picker` para pegar a imagem da camera (pode mudar o código para pegar uma imagem da galeria)
     - `google_sign_in` para fazer o login com o google
     - `firebase_storage` para armazenar as imagens
     - `firebase_auth` para fazer a autenticação com o firebase

