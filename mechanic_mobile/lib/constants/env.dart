import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String serverUrl = dotenv.get("SERVER_URL");
  static String systemName = dotenv.get("SYSTEM_NAME");
  static String openRouterApiKey = dotenv.get("OPEN_ROUTER_API_KEY");
}
