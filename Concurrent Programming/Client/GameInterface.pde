class GameInterface {
    ClientConnection connection;
    InputHandler inputHandler;

    GameInterface(ClientConnection connection, InputHandler inputHandler) {
        this.connection = connection;
        this.inputHandler = inputHandler;
    }

    void drawG() {
        // Draw background
        drawGradientBackground();

        // Draw arena border
        noFill();
        stroke(255);
        strokeWeight(2);
        rect(20, 20, width - 40, height - 40);

        // Draw players
        if (connection.player1 != null) {
            connection.player1.display();
        }
        if (connection.opponent != null) {
            connection.opponent.display();
        }

        // Draw projectiles
        for (Projectile p : connection.projectiles) {
            p.display();
        }

        // Draw modifiers
        for (Modifier m : connection.modifiers) {
            m.display();
        }

        // Draw scores
        drawScores();
    }

    void drawGradientBackground() {
        for (int i = 0; i < height; i++) {
            float inter = map(i, 0, height, 0, 1);
            color c = lerpColor(color(255, 182, 193), color(152, 251, 152), inter); // Pastel pink to pastel green
            stroke(c);
            line(0, i, width, i);
        }
    }

    void drawScores() {
        fill(255);
        textSize(20);
        textAlign(LEFT, TOP);
        if (connection.player1 != null) {
            text(connection.player1.username + ": " + connection.player1.score, 30, 30);
        }
        if (connection.opponent != null) {
            textAlign(RIGHT, TOP);
            text(connection.opponent.username + ": " + connection.opponent.score, width - 30, 30);
        }
    }

    void drawMatchResults(String result) {
        background(0);
        fill(255);
        textSize(32);
        textAlign(CENTER, CENTER);
        text(result, width / 2, height / 2);
    }
}
