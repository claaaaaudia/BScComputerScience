import java.util.Arrays;

class LoginInterface {

  Button registerButton, loginButton, exitButton;
  Button deleteAccountButton, logoutButton, topTenButton;
  Button joinLobbyButton;
  Button backButton;
  PImage ouro, prata, bronze;
  
  boolean showingTopTen = false;
  
  String username = "";
  String[] topTenPlayers = new String[0];
  
  InputHandler input;
  LoginClient client;
  ClientConnection conn;
  
  LoginInterface(ClientConnection conn, LoginClient client) {
    this.conn = conn;
    this.client = client;
  
    // Configura o callback para o Top Ten
    conn.setTopTenCallback(new TopTenCallback() {
        public void onTopTenReceived(String[] players) {
            updateTopTen(players);
        }
    });
  
    // Centering buttons
    int buttonWidth = 200;
    int buttonHeight = 50;
    int centerX = width / 2;
    int centerY = height / 2;
    
    registerButton = new Button("Register", width / 2 - buttonWidth / 2, height / 2 - 150, buttonWidth, buttonHeight);
    loginButton = new Button("Login", width / 2 - buttonWidth / 2, height / 2 - 80, buttonWidth, buttonHeight);
    exitButton = new Button("Exit", width / 2 - buttonWidth / 2, height / 2 - 10, buttonWidth, buttonHeight);
  
    // logged-in menu
    deleteAccountButton = new Button("Delete Account", 150, 100, 100, 40);
    logoutButton = new Button("Logout", 150, 160, 100, 40);
    topTenButton = new Button("Top Ten", 150, 220, 100, 40);
    joinLobbyButton = new Button("Join Lobby", 150, 280, 100, 40);
  
    // Back button
    backButton = new Button("Back", 150, 320, 100, 40);
    
    ouro = loadImage("ouro.png");
    prata = loadImage("prata.png");
    bronze = loadImage("bronze.png");

  }
  
  void drawLog() {
    if(conn != null){
      if (showingTopTen) {
        background(170, 203, 115); // green
        showTopTenScreen();
      } else if (conn != null && conn.isLoggedIn) {
        background(205, 233, 144); // slightly darker green
        showLoggedInMenu();
      } else {
        background(255, 212, 212); // pink
        showLoggedOutMenu();
      }
    }
  }
  
  void showLoggedOutMenu() {
    textAlign(CENTER, CENTER);
    textSize(20);
    fill(0);
    text("Welcome! Please log in or create an account.", 200, 50);
  
    registerButton.display();
    loginButton.display();
    exitButton.display();
  }
  
  void showLoggedInMenu() {
    textAlign(CENTER, CENTER);
    textSize(20);
    fill(0);
    text("Welcome, " + username + "!", 200, 50);
  
    deleteAccountButton.display();
    logoutButton.display();
    topTenButton.display();
    joinLobbyButton.display();
  }
  
  void showTopTenScreen() {
    textAlign(CENTER, CENTER);
    textSize(20);
    fill(0);
    text("Top Ten Players", width / 2, 40);
  
    textSize(16);
    fill(0);
    
        for (int i = 0; i < topTenPlayers.length; i++) {
            if (topTenPlayers[i] != null) {
                float y = 80 + i * 25;
                String playerText = (i > 2) ? (i + 1) + ". " + topTenPlayers[i] : topTenPlayers[i];
                float textWidth = textWidth(playerText);
                
                if (i < 3) {
                    float medalX = width/2 - textWidth/2 - 30;
                    
                    if (i == 0 && ouro != null) {
                        image(ouro, medalX, y - 18, 20, 20);
                    } else if (i == 1 && prata != null) {
                        image(prata, medalX, y - 18, 20, 20);
                    } else if (i == 2 && bronze != null) {
                        image(bronze, medalX, y - 18, 20, 20);
                    }
                }
                
                text(playerText, width/2, y);
            }
        }
  
    backButton.display();
  }
  
  void mousePressedLog() {
    if (showingTopTen) {
      if (backButton.isClicked(mouseX, mouseY)) {
        showingTopTen = false;
      }
      return;
    }
  
    if (!conn.isLoggedIn) {
      if (registerButton.isClicked(mouseX, mouseY)) {
        username = prompt("Enter Username:");
        String password = prompt("Enter Password:");
        if (username == null || password == null) {
          println("Registration cancelled.");
          return;
        }
        try {
          String result = client.createAccount(username, password);
          println(result);
        } catch (IOException e) {
          println("Error creating account: " + e.getMessage());
        }
      } else if (loginButton.isClicked(mouseX, mouseY)) {
        username = prompt("Enter Username:");
        String password = prompt("Enter Password:");
        if (username == null || password == null) {
          println("Login cancelled.");
          return;
        }
        try {
          String result = client.login(username, password);
          println(result);
        } catch (IOException e) {
          println("Error during login: " + e.getMessage());
        }
      } else if (exitButton.isClicked(mouseX, mouseY)) {
        exit();
      }
    } else {
      if (deleteAccountButton.isClicked(mouseX, mouseY)) {
        String password = prompt("Confirm your password:");
        try {
          String result = client.deleteAccount(username, password);
          println(result);
          if (result.equals("Account deletion command sent.")) {
            conn.isLoggedIn = false;
          }
        } catch (IOException e) {
          println("Error deleting account: " + e.getMessage());
        }
      } else if (logoutButton.isClicked(mouseX, mouseY)) {
        try {
          String result = client.logout(username);
          println(result);
          if (result.equals("Logout command sent.")) {
            conn.isLoggedIn = false;
          }
        } catch (IOException e) {
          println("Error during logout: " + e.getMessage());
        }
      } else if (topTenButton.isClicked(mouseX, mouseY)) {
        try {
          client.getTopTen();
        } catch (IOException e) {
          println("Error fetching top ten players: " + e.getMessage());
        }
      } else if (joinLobbyButton.isClicked(mouseX, mouseY)) {
        String result = client.joinLobby(username);
        println(result);
        if (result.equals("Lobby join request sent.")) {
          input = new InputHandler(client.getClient());
          lobbyInterface = new LobbyInterface(username, client.getClient(),client);
          connection.inLobby = true;
        }
      }
    }
  }
  
  String prompt(String label) {
    return javax.swing.JOptionPane.showInputDialog(label);
  }
  
    void drawGradientBackground() {
        
        for (int i = 0; i < height; i++) {
            float inter = map(i, 0, height, 0, 1);
            color c = lerpColor(color(20, 25, 35), color(40, 45, 60), inter);
            stroke(c);
            line(0, i, width, i);
        }
    }
    
    void updateTopTen(String[] players) {
        this.topTenPlayers = players;
        this.showingTopTen = true;
        redraw();
    }

  
  class Button {
    String label;
    int x, y, w, h;
    color bgColor, hoverBgColor;
    color textColor = color(33);
    boolean hovered = false;
  
    Button(String label, int x, int y, int w, int h) {
      this.label = label;
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.bgColor = color(220, 220, 221); // light grey
      this.hoverBgColor = color(197, 195, 198); // light but slightly darker grey
    }
  
    void display() {
      hovered = isHovered(mouseX, mouseY);
  
      // Shadow
      noStroke();
      fill(0, 30);  // light shadow
      rect(x + 3, y + 3, w, h, 12);
  
      // Button background
      fill(hovered ? hoverBgColor : bgColor);
      stroke(100);
      strokeWeight(1.2);
      rect(x, y, w, h, 12);
  
      // Text
      fill(textColor);
      textAlign(CENTER, CENTER);
      textSize(16);
      text(label, x + w / 2, y + h / 2 - 1);
    }
  
    boolean isHovered(int mouseX, int mouseY) {
      return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
    }
  
    boolean isClicked(int mouseX, int mouseY) {
      return isHovered(mouseX, mouseY);
    }
  }
}
