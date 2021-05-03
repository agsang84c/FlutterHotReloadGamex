import "dart:io";
import "dart:convert";

class GameClient
{
    WebSocket _socket;
    GameServer _server;
    bool _isReady = false;
    bool _isReadyToStart;

    GameClient(GameServer server, WebSocket socket)
    {
        _socket = socket;
        _server = server;
        _socket.listen(_dataReceived, onDone: _onDisconnected);
        _socket.pingInterval = const Duration(seconds: 5);
    }

    _onDisconnected()
    {
        print("${this.runtimeType} disconnected! ${_socket.closeCode}");
        _server.onClientDisconnected(this);
    }

    void _dataReceived(message)
    {
        print("Just received ====:\n $message");
        try
        {
            var jsonMsg = json.decode(message);
            String msg = jsonMsg['message'];
            
            switch(msg)
            {
                case "ready":
                    _isReady = jsonMsg['payload'];
                    print("PLAYER READY? ${_isReady}");
                    _server.onClientReadyChanged();
                    break;
                case "startGame":
                    print("READY TO START");
                    _server.onClientStartChanged(this);
                    break;
                default:
                    print("MESSAGE: $jsonMsg");
                    break;
            }
        }
        on FormatException catch(e)
        {
            print("Wrong Message Formatting, not JSON: ${message}");
            print(e);
        }
    }

    gameOver()
    {
        _socket.add(GameServer.formatJSONMessage("gameOver", true));
    }

    get isReady => _isReady;

    set readyList(List<bool> readyPlayers)
    {
        _socket.add(GameServer.formatJSONMessage("playerList", readyPlayers));
    }

}

class GameServer
{
    List<GameClient> _clients = new List<GameClient>();

    GameServer()
    {
        connect();
    }

    static String formatJSONMessage<T>(String msg, T payload)
    {
        return json.encode({
            "message": msg,
            "payload": payload
        });
    }

    void connect()
    {
        HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080)
            .then((server) async
            {
                print("Serving at ${server.address}, ${server.port}");
                await for(var request in server)
                {
                    if(WebSocketTransformer.isUpgradeRequest(request))
                    {
                        WebSocketTransformer.upgrade(request).then(_handleWebSocket);
                    }
                    else
                    {
                        // Simple request
                        request.response
                            ..headers.contentType = new ContentType("text", "plain", charset: "utf-8")
                            ..write("Hello, world")
                            ..close();   
                    }
                }
        });
    }

    onClientDisconnected(GameClient client)
    {
        this._clients.remove(client);
        onClientReadyChanged();
    }

    onClientReadyChanged()
    {
        int l = _clients.length;
        List<bool> readyList = new List(l);
        for(int i = 0; i < l; i++)
        {
            readyList[i] = _clients[i].isReady;
        }

        for(var gc in _clients)
        {
            gc.readyList = readyList;
        }
    }

    onClientStartChanged(GameClient client)
    {
        /*
            iterate all the clients. 
            If everyone is ready, call game start
        */
    }

    onGameStart()
    {
        // tell every client the game has started and what their commands are...
        // build list of command id to possible values
        /* foreach(client)
        {
            client.assignCommands(commands.randomSelection());
        } */
    }

    onGameOver()
    {
        for(var gc in _clients)
        {
            gc.gameOver();
        }
    }

    _handleWebSocket(WebSocket socket)
    {
        print("ADD WEBCLIENT! ${this._clients.length}");
        GameClient client = new GameClient(this, socket);
        _clients.add(client);
        onClientReadyChanged();
    }
}