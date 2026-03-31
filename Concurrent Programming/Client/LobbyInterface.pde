public class LobbyInterface{
    Button backButton;
    LoginClient loginClient;
    String username;
    ClientConnection conn;
    
    color backgroundColor = color(30,30,40);
    color textColor = color(255);

    LobbyInterface(String username, ClientConnection conn, LoginClient loginClient) {
        this.username = username;
        this.conn = conn;
        this.loginClient = loginClient;
        this.backButton = new Button("Go back to Menu", width/2 - 100, height - 100, 200, 50);
    }

    void drawL() {
        
        drawGradientBackground();
        
        textAlign(CENTER, CENTER);
        fill(textColor);
        textSize(32);
        text("Waiting for match to start...", width / 2, height / 3 - 15);
        
        drawLoadingAnimation(width/2, height/2);
        
        backButton.display();
        
        updateCursor();
    }
    
    void drawGradientBackground() {
        
        for (int i = 0; i < height; i++) {
            float inter = map(i, 0, height, 0, 1);
            color c = lerpColor(color(20, 25, 35), color(40, 45, 60), inter);
            stroke(c);
            line(0, i, width, i);
        }
    }
    
    void drawLoadingAnimation(float x, float y) {
        float size = 100;
        float angle = frameCount * 0.05;
        
        pushMatrix();
        translate(x, y);
        noFill();
        stroke(150, 150, 255);
        strokeWeight(4);
        ellipse(0, 0, size, size);
        
        for (int i = 0; i < 3; i++) {
            float dotAngle = angle + i * TWO_PI/3;
            float dotX = cos(dotAngle) * size/2;
            float dotY = sin(dotAngle) * size/2;
            fill(200, 200, 255);
            noStroke();
            ellipse(dotX, dotY, 15, 15);
        }
        popMatrix();
    }
    
    void updateCursor() {
        if (backButton.isHovered(mouseX, mouseY)) {
            cursor(HAND);
        } else {
            cursor(ARROW);
        }
    }
    
    void mousePressed() {
        if (backButton.isClicked(mouseX, mouseY)) {
            leaveLobby();
        }
    }
    
    void leaveLobby() {
        println("Leaving lobby...");
        String result = loginClient.leaveLobby(username);
        println(result);
    }
}
