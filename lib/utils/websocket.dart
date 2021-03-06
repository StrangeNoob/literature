import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Global variable, the whole class
/// is accessible by this global variable
WebSocket socket = new WebSocket();

class WebSocket {
  static final WebSocket _socketController = new WebSocket._internal();

  /// Reuse the same instance of websockets,
  /// Called when Line 6 is called.
  factory WebSocket() {
    return _socketController;
  }

  WebSocket._internal();
  

  // WebSocket channel
  IO.Socket _channel;

  // Is connection on?
  bool _isOn = false;

  // Listeners to various events
  ObserverList<Function> _listeners = new ObserverList<Function>();

  /// ==========
  /// Initialise communication
  /// ==========
  initCommunication() {
    // reset previous communication, if any
    // reset();

    // Initiate communication
    _channel = IO.io('http://127.0.0.1:3000', <String, dynamic>{
      'transports': ['websocket'],
        // 'extraHeaders': {'foo': 'bar'} // optional
    });
    _channel.connect();
    _isOn = true;
    _channel.on('connect', (_) {
      print('connected');
      _channel.emit('msg', 'test');
    });

    listenForEvents(_channel);
  }

  // Resets communication
  reset() {
    if (_channel != null) {
      _channel.destroy();
      _isOn = false;
    }
  }

  // Sends a message to the server
  send(String message, String data) {
    if (_isOn == true) {
      _channel.emit(message, data);
    }
  }

   /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(Function callback){
    _listeners.add(callback);
  }
  removeListener(Function callback){
    _listeners.remove(callback);
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  listenForEvents(IO.Socket socket) {
    // On event Create game
    socket.on("created", (data) {
      Map messageRecieved = json.decode(data);
      Map message = new Map();
      message["data"] = messageRecieved["data"];
      message["action"] = messageRecieved["action"];
      message["name"] = messageRecieved["name"];
      _listeners.forEach((Function callback) {
        callback(message);
      });
    });
    // On event join Game
    socket.on("joined", (data) {
      Map messageRecieved = json.decode(data);
      Map message = new Map();
      message["data"] = messageRecieved["data"];
      message["action"] = messageRecieved["action"];
      _listeners.forEach((Function callback) {
        callback(message);
      });
    });
    // Waiting clients also need to move 
    // to the start game page
    socket.on("game_started", (data) {
      Map messageRecieved = json.decode(data);
      Map message = new Map();
      message["action"] = messageRecieved["action"];
      _listeners.forEach((Function callback) {
        callback(message);
      });
    });
    // On event getting initial cards
    socket.on("opening_hand", (data) {
      Map messageRecieved = json.decode(data);
      Map message = new Map();
      message["data"] = messageRecieved["data"];
      message["action"] = messageRecieved["action"];
      _listeners.forEach((Function callback) {
        callback(message);
      });
    });
  }
}
