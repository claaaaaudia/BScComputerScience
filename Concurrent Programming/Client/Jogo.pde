ClientConnection connection;
GameInterface gameInterface;
LobbyInterface lobbyInterface;
InputHandler inputHandler;
LoginClient loginClient;
LoginInterface loginInterface;

void setup() {
  size(850, 900);
  pixelDensity(displayDensity()); 
  smooth();
    try {
        String serverIP = "localhost";
        int serverPort = 4567; 
        
        connection = new ClientConnection(serverIP, serverPort);
        inputHandler = new InputHandler(connection);
        gameInterface = new GameInterface(connection, inputHandler);
        loginClient = new LoginClient(connection);
        loginInterface = new LoginInterface(connection, loginClient);
    } catch (IOException e) {
        println("Failed to connect to server: " + e.getMessage());
        exit();
    }
}

void draw() {
   background(255);
   
  if (connection.inLobby) {
    lobbyInterface.drawL();
  } else if (connection.inGame) {
    gameInterface.drawG();
  } else {
    loginInterface.drawLog();
  }
}

void keyPressed() {
  if (connection.inLobby) {
    if (key == 'q' || key == 'Q') {
      println("Leaving the lobby...");
      connection.sendCommand("leave:" + connection.player1.username);
    }
  } else if (connection.inGame) {
    inputHandler.handleKeyPressed(keyCode);    
  }
}

void keyReleased(){
  if (connection.inGame) {
    inputHandler.handleKeyReleased(keyCode);
  }
}

void mousePressed() {
  if (connection.inGame) {
    gameInterface.inputHandler.handleMouseClick(); 
  } else if (connection.inLobby) {
    lobbyInterface.mousePressed();
  } else {
    loginInterface.mousePressedLog(); 
  }
}
