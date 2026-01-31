import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

Future<void> handleWebSocketConnection(String url) async {
  final wsUrl = Uri.parse(url);
  final channel = WebSocketChannel.connect(wsUrl);

  // Ensure the WebSocket connection is ready before proceeding
  await channel.ready;

  // Listen to the WebSocket stream
  channel.stream.listen((message) {
      showLog('Received message: $message');

    // Send a response back to the server
    channel.sink.add('received!');

    // Close the connection with a status code
    channel.sink.close(status.goingAway);
  });
}

Future<void> handleWebSocketConnection1(
    String url, Function(String) onMessageReceived) async {
  final wsUrl = Uri.parse(url);
  final channel = WebSocketChannel.connect(wsUrl);

  await channel.ready;

  channel.stream.listen((message) {
    onMessageReceived(message);

    // Optionally respond to the server
  //  channel.sink.add('Message received!');

    // Optionally close the connection
    // channel.sink.close(status.goingAway);
  });
}