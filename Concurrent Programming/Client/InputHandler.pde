class InputHandler {
  ClientConnection client;
  boolean upPressed, downPressed, leftPressed, rightPressed;
  
  InputHandler(ClientConnection client) {
    this.client = client;
  }
  
  void handleKeyPressed(int code) {
    switch (code) {
      case UP:
        upPressed = true;
        break;
      case DOWN:
        downPressed = true;
        break;
      case LEFT:
        leftPressed = true;
        break;
      case RIGHT:
        rightPressed = true;
        break;
    }
    if (upPressed && leftPressed){
      client.sendCommand("move:up#left");
    } else if (upPressed && rightPressed){
      client.sendCommand("move:up#right");
    } else if (downPressed && leftPressed){
      client.sendCommand("move:down#left");
    } else if (downPressed && rightPressed){
      client.sendCommand("move:up#right");
    } else if (upPressed){
      client.sendCommand("move:up");
    } else if (downPressed){
      client.sendCommand("move:down");
    } else if (leftPressed){
      client.sendCommand("move:left");
    } else if (rightPressed){
      client.sendCommand("move:right");
    } 
  }
  
  void handleKeyReleased(int code) {
    switch (code) {
      case UP:
        upPressed = false;
        break;
      case DOWN:
        downPressed = false;
        break;
      case LEFT:
        leftPressed = false;
        break;
      case RIGHT:
        rightPressed = false;
        break;
    }
    if (!upPressed && !downPressed && !leftPressed && !rightPressed) {
      client.sendCommand("move:stop");
    }
  }
  
  void handleMouseClick() {
    client.sendCommand("shoot:" + mouseX + "," + mouseY);
  }
  
}
