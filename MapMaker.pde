int scale=8, scroll=0, spriteSelected=0;
int tileWidth=8, tagNum=8;
int UIBlock=128;
boolean w, s, up, down, left, right, mouseClicked;

int[][] mapNums=new int[20][20];
boolean[][] tags;
PVector mapPos=new PVector(0, 0);

PImage sprites[];

Tab spriteList;
Tab map;

void setup() {
  noSmooth();
  size(2000, 1200);
  frameRate(60);
  
  PImage spriteSheet;
  spriteSheet=loadImage("map/mapTiles.png");
  
  sprites=new PImage[spriteSheet.width/tileWidth*spriteSheet.height/tileWidth];
  
  tags=new boolean[sprites.length][tagNum];
  
  for(int i=0; i<sprites.length; i++) {
    sprites[i]=spriteSheet.get(tileWidth*i%spriteSheet.width, tileWidth*floor(tileWidth*i/spriteSheet.width), tileWidth, tileWidth);
  }
  
  spriteList=new Tab(0, 0, 3*UIBlock+1, height);
  map=new Tab(3*UIBlock+1, 0, width-800, height-100);
  
  readData();
}

void draw() {
  exitButton();
  
  if(w) scroll-=10;
  if(s) scroll=-((-scroll-10)+abs(scroll+10))/2;

  background(255);
  
  mapDisplay();
  spriteList();
  
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
  if(keyCode==UP) up=true;
  if(keyCode==DOWN) down=true;
  if(keyCode==LEFT) left=true;
  if(keyCode==RIGHT) right=true;
}

void keyReleased() {
  if(key=='w') w=false;
  if(key=='s') s=false;
  if(keyCode==UP) up=false;
  if(keyCode==DOWN) down=false;
  if(keyCode==LEFT) left=false;
  if(keyCode==RIGHT) right=false;
}

void spriteList() {
  spriteList.update();
  spriteList.tab.beginDraw();
  spriteList.tab.background(255);
  spriteList.tab.noStroke();
  for(int i=0; i<sprites.length; i++) {
    int x=i%2*UIBlock;
    int y=20+(i-i%2)*(UIBlock/2)+scroll;
    if(y<height&&y+UIBlock>0) {
      spriteList.tab.image(sprites[i], x, y, UIBlock, UIBlock);
      if(spriteList.tabRect(x, y, UIBlock, UIBlock)) {
        spriteList.tab.fill(0, 10);
        spriteList.tab.rect(x, y, UIBlock, UIBlock);
        if(mousePressed) {
          spriteSelected=i;
        }
      }
      if(spriteSelected==i) {
        spriteList.tab.fill(0, 30);
        spriteList.tab.rect(x, y, UIBlock, UIBlock);
      }
    }
  }
  spriteList.tab.stroke(1);
  for(int i=0; i<tagNum; i++) {
    int x=2*UIBlock;
    int y=20+i*UIBlock;
    if(tags[spriteSelected][i]) {
      spriteList.tab.fill(128);
      spriteList.tab.rect(x, y, UIBlock, UIBlock);
    }
    if(spriteList.tabRect(x, y, UIBlock, UIBlock)) {
      spriteList.tab.fill(0, 10);
      spriteList.tab.rect(x, y, UIBlock, UIBlock);
      if(mouseClicked) {
        tags[spriteSelected][i]=!tags[spriteSelected][i];
      }
    }
  }
  spriteList.display();
}

void mapDisplay() {
  map.update();
  if(up) mapPos.y=0.5*((mapPos.y+30)-abs(mapPos.y+30));
  if(down) mapPos.y=-0.5*((-mapPos.y+30)+(scale*tileWidth*mapNums[0].length-map.tab.height+20)-abs((-mapPos.y+30)-(scale*tileWidth*mapNums[0].length-map.tab.height+20)));
  if(left) mapPos.x=0.5*((mapPos.x+30)-abs(mapPos.x+30));
  if(right) mapPos.x=-0.5*((-mapPos.x+30)+(scale*tileWidth*mapNums.length-map.tab.width)-abs((-mapPos.x+30)-(scale*tileWidth*mapNums.length-map.tab.width)));
  map.tab.beginDraw();
  String bottomRight="";
  for(int i=0; i<mapNums.length; i++) {
    for(int j=0; j<mapNums[i].length; j++) {
      int x=i*tileWidth*scale+int(mapPos.x);
      int y=20+j*tileWidth*scale+int(mapPos.y);
      map.tab.image(sprites[mapNums[i][j]], x, y, scale*tileWidth, scale*tileWidth);
      map.tab.fill(0, 0);
      map.tab.rect(x, y, scale*tileWidth, scale*tileWidth);
      if(map.tabRect(x, y, scale*tileWidth, scale*tileWidth)) {
        if(mousePressed) {
          mapNums[i][j]=spriteSelected;
        }
        bottomRight="Tile: "+mapNums[i][j]+", "+i+", "+j;
      }
    }
  }
  map.tab.textAlign(RIGHT);
  map.tab.textSize(50);
  map.tab.fill(0);
  map.tab.text(bottomRight, map.tab.width-15, map.tab.height-10);
  map.tab.endDraw();
  map.display();
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