import 'package:flutter_dotenv/flutter_dotenv.dart';

//Base URL
String urlBase = dotenv.env['BASE_URL'].toString();

//Auth URL
String urlLogin = dotenv.env['URL_LOGIN'].toString();
String urlPerfile = dotenv.env['URL_PERFILE'].toString();

//Solicitudes URL
String urlSolicitudes = dotenv.env['URL_SOLICITUDES'].toString();
String urlSolictudesEstado = dotenv.env['URL_SOLICITUDES_ESTADO'].toString();

//Usuario URL
String urlUsuario = dotenv.env['URL_USUARIO'].toString();
