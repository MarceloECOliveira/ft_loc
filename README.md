# FTLoc

Aplicativo de localização para a Faculdade de Tecnologia da Unicamp.

Implementado até o momento:
 - Login com email e senha
 - Login anônimo
 - Perfil de usuário
 - Mapa
 - Localização do usuário
 - Criação de rotas entre salas

## Configuração do Projeto

1. Clone o repositório.
2. Certifique-se de que tem o Flutter SDK instalado.
3. Crie um projeto Firebase e configure-o para Android.
4. Vá às definições do seu projeto Firebase, registe a sua aplicação Android e **descarregue o ficheiro `google-services.json`. Coloque-o na pasta `android/app/`**.
5. Gere o seu próprio ficheiro `lib/firebase_options.dart` usando o FlutterFire CLI e coloque-o na pasta `lib`.
6. Execute `flutter pub get` para instalar as dependências.
7. Execute `flutter run` para iniciar a aplicação.