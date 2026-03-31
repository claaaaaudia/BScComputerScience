
class Projectile {
  Player owner;
  float x, y;
  
  Projectile(Player owner, float x, float y) {
    this.owner = owner;
    this.x = x;
    this.y = y;
  }
  
  void display() {
    fill(0);
    ellipse(x, y, 10, 10);
  }
} //<>// //<>// //<>// //<>//
