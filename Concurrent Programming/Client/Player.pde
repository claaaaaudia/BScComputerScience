class Player {
  float x, y;         //posição
  float vx, vy;       //velocidade
  float dir;          //direção em radianos
  float radius = 20;  //raio
  
  String username;    //user
  color playerColor;  //cor
  int score = 0;      //pontuação
  
  ArrayList<Modifier> active_mods = new ArrayList<Modifier>();

  Player(){
    this.username = "";
    this.x = 0;
    this.y = 0;
    this.dir = 0;
    this.playerColor = 0;
  }

  void makePlayer(String username, float startX, float startY, float dir, int score){
    this.username = username;
    this.x = startX;
    this.y = startY;
    this.dir = dir;
    this.score = score;
  }
  
  void updatePosition(float newX, float newY, float newDir, int newScore) {
    this.x = newX;
    this.y = newY;
    this.dir = newDir;
    this.score = newScore;
  }
  
  void display() {
    println("Displaying player: " + username + " at (" + x + ", " + y + ") with color " + playerColor);
    fill(playerColor);
    ellipse(this.x, this.y, this.radius * 2, this.radius * 2);
    line(this.x, this.y, this.x + cos(this.dir) * this.radius, this.y + sin(this.dir) * this.radius);
  }
  
  void addModifier(Modifier mod){
    this.active_mods.add(mod);
  }
  
}
