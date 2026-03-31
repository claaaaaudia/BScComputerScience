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
