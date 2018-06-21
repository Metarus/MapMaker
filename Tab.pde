class Tab {
  PVector pos=new PVector();
  PGraphics tab;
  boolean dragging;
  Tab(float posX, float posY, int w, int h) {
    pos.x=posX;
    pos.y=posY;
    tab=createGraphics(w, h);
  }
  void update() {
    if(cursorRect(pos.x, pos.y, tab.width, 20)) {
      dragging=true;
    }
    if(!mousePressed) {
      dragging=false;
    }
    if(dragging) {
      pos.x+=mouseX-pmouseX;
      pos.y+=mouseY-pmouseY;
    }
  }
  void display() {
    tab.beginDraw();
    tab.fill(100, 100, 255);
    tab.rect(0, 0, tab.width, 20);
    tab.fill(0, 0);
    tab.stroke(55);
    tab.rect(1, 1, tab.width-2, tab.height-2);
    tab.endDraw();
    image(tab, pos.x, pos.y);
  }
  boolean tabRect(float x, float y, float w, float h) {
    if(mouseX>x+pos.x&&mouseX<x+w+pos.x&&mouseY>y+pos.y&&mouseY<y+h+pos.y&&cursorRect(pos.x, pos.y+20, tab.width, tab.height-20)) {
      return true;
    } else return false;
  }
}