class Modifier {
  
  float x, y;
  String colour;
  
  Modifier(float x, float y, String colour) {
    
    this.x = x;
    this.y = y;
    this.colour = colour;
    
  }
  
  void display() {
    
    if (colour.equals("green")) fill(0,255,0);
    else if (colour.equals("red")) fill(255,0,0);
    else if (colour.equals("blue")) fill(0,0,255);
    else if (colour.equals("orange")) fill(255,165,0);
    else fill(128);
    rect(x-8, y-8, 16, 16, 4);
    
  }
  
}
