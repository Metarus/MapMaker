int scale=15, scroll=0, spriteSelected=0;
int tileWidth=8, tagNum=8;
int UIBlock=128;
boolean w, s, mouseClicked;

int[][] mapNums=new int[28][18];
boolean[][] tags;

PImage sprites[];

void setup() {
  fullScreen(P2D);
  
  PImage spriteSheet;
  spriteSheet=loadImage("map/mapTiles.png");
  
  sprites=new PImage[spriteSheet.width/tileWidth*spriteSheet.height/tileWidth];
  
  tags=new boolean[sprites.length][tagNum];
  
  for(int i=0; i<sprites.length; i++) {
    sprites[i]=spriteSheet.get(tileWidth*i%spriteSheet.width, tileWidth*floor(i/spriteSheet.width), tileWidth, tileWidth);
  }
  
  readData();
}

void draw() {
  exitButton();
  
  if(w) scroll-=10;
  if(s) scroll+=10;

  background(255);
  
  spriteList();
  tagList();
  mapDisplay();
  
  fill(255, 0, 0);
  rect(width-90, 0, 90, 50);
  
  mouseClicked=false;
}

boolean cursorRect(float x, float y, float w, float h) {
  if(mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+h) {
    return true;
  } else return false;
}

void mouseClicked() {
  mouseClicked=true;
}

void keyPressed() {
  if(key=='w') w=true;
  if(key=='s') s=true;
}

void keyReleased() {
  if(key=='w') w=false;
  if(key=='s') s=false;
}

void spriteList() {
  for(int i=0; i<sprites.length; i++) {
    noStroke();
    int x=i%2*UIBlock;
    int y=(i-i%2)*64+scroll;
    image(sprites[i], x, y, UIBlock, UIBlock);
    if(cursorRect(x, y, UIBlock, UIBlock)) {
      fill(0, 10);
      rect(x, y, UIBlock, UIBlock);
      if(mousePressed) {
        spriteSelected=i;
      }
    }
    if(spriteSelected==i) {
      fill(0, 30);
      rect(x, y, UIBlock, UIBlock);
    }
    stroke(1);
  }
}

void tagList() {
  for(int i=0; i<tagNum; i++) {
    int x=2*UIBlock;
    int y=i*UIBlock;
    if(tags[spriteSelected][i]) {
      fill(128);
      rect(x, y, UIBlock, UIBlock);
    }
    if(cursorRect(x, y, UIBlock, UIBlock)) {
      fill(0, 10);
      rect(x, y, UIBlock, UIBlock);
      if(mouseClicked) {
        tags[spriteSelected][i]=!tags[spriteSelected][i];
      }
    }
  }
}

void mapDisplay() {
  for(int i=0; i<mapNums.length; i++) {
    for(int j=0; j<mapNums[i].length; j++) {
      int x=500+i*tileWidth*scale;
      int y=j*tileWidth*scale;
      image(sprites[mapNums[i][j]], x, y, scale*tileWidth, scale*tileWidth);
      fill(0, 0);
      rect(x, y, scale*tileWidth, scale*tileWidth);
      if(cursorRect(x, y, scale*tileWidth, scale*tileWidth)) {
        if(mousePressed) {
          mapNums[i][j]=spriteSelected;
        }
      }
    }
  }
}

void exitButton() {
  if(cursorRect(width-90, 0, 90, 50)&&mousePressed) {
    writeData();
    exit();
  }
}

void writeData() {
  PrintWriter writer1=createWriter("map/map.txt");
    String write1="";
    for(int i=0; i<mapNums.length; i++) {
      for(int j=0; j<mapNums[i].length; j++) {
        write1+=mapNums[i][j]+",";
      }
      write1+=".";
    }
    writer1.print(write1);
    writer1.flush();
    writer1.close();
    
    PrintWriter writer2=createWriter("map/tags.txt");
    String write2="";
    for(int i=0; i<tags.length; i++) {
      for(int j=0; j<tags[i].length; j++) {
        if(tags[i][j]) {
          write2+="1,";
        } else write2+="0,";
      }
      write2+=".";
    }
    writer2.print(write2);
    writer2.flush();
    writer2.close();
}

void readData() {
  String str1[]=loadStrings("map/map.txt");
  if(str1.length!=0) {
    str1=split(str1[0], '.');
    String strings1[][]=new String[str1.length][];
    for(int i=0; i<str1.length-1; i++) {
      strings1[i]=split(str1[i],',');
      for(int j=0; j<strings1[i].length-1; j++) {
        mapNums[i][j]=int(strings1[i][j]);
      }
    }
  }
  
  String str2[]=loadStrings("map/tags.txt");
  if(str2.length!=0) {
    str2=split(str2[0], '.');
    String strings2[][]=new String[str2.length][];
    for(int i=0; i<str2.length-1; i++) {
      strings2[i]=split(str2[i],',');
      for(int j=0; j<strings2[i].length-1; j++) {
        tags[i][j]=boolean(int(strings2[i][j]));
      }
    }
  }
}