int scale=8, scroll=0, spriteSelected=0;
int tileWidth=8, tagNum=8;
int UIBlock=128;
boolean w, s, up, down, left, right, plus, minus, mouseClicked;
boolean isDragging;

String[] toolList={"brush", "line", "fill"};
int toolSelected=0;
int lineX, lineY;
boolean linePressed, lineReset;
int brushSize=1;

int[][] mapNums=new int[64][64];
boolean[][] tags;
PVector mapPos=new PVector(0, 0);

PImage sprites[];

Tab spriteList;
Tab map;
Tab tools;

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
  tools=new Tab(3*UIBlock+1+width-800, 0, 300, height-100);
  
  readData();
}

void draw() {
  exitButton();
  
  if(w) scroll-=10;
  if(s) scroll=-((-scroll-10)+abs(scroll+10))/2;

  background(255);
  
  mapDisplay();
  spriteList();
  tools();
  
  fill(255, 0, 0);
  rect(width-90, 0, 90, 50);
  
  mouseClicked=false;
}

boolean cursorRect(float x, float y, float w, float h) {
  if(mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+h) {
    return true;
  } else return false;
}

void mouseReleased() {
  if(lineReset) {
    linePressed=false;
    lineReset=false;
  }
}

void mouseClicked() {
  mouseClicked=true;
}

void keyPressed() {
  if(key=='w') w=true;
  if(key=='s') s=true;
  if(key=='-') minus=true;
  if(key=='=') plus=true;
  if(keyCode==UP) up=true;
  if(keyCode==DOWN) down=true;
  if(keyCode==LEFT) left=true;
  if(keyCode==RIGHT) right=true;
}

void keyReleased() {
  if(key=='w') w=false;
  if(key=='s') s=false;
  if(key=='-') minus=false;
  if(key=='=') plus=false;
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
        if(mousePressed&&!isDragging) {
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
  if(plus) scale++;
  if(minus) scale--;
  if(up) mapPos.y=0.5*((mapPos.y+30)-abs(mapPos.y+30));
  if(down) mapPos.y=-0.5*((-mapPos.y+30)+(scale*tileWidth*mapNums[0].length-map.tab.height+20)-abs((-mapPos.y+30)-(scale*tileWidth*mapNums[0].length-map.tab.height+20)));
  if(left) mapPos.x=0.5*((mapPos.x+30)-abs(mapPos.x+30));
  if(right) mapPos.x=-0.5*((-mapPos.x+30)+(scale*tileWidth*mapNums.length-map.tab.width)-abs((-mapPos.x+30)-(scale*tileWidth*mapNums.length-map.tab.width)));
  map.tab.beginDraw();
  map.tab.background(255);
  String bottomRight="";
  for(int i=0; i<mapNums.length; i++) {
    for(int j=0; j<mapNums[i].length; j++) {
      int x=i*tileWidth*scale+int(mapPos.x);
      int y=20+j*tileWidth*scale+int(mapPos.y);
      map.tab.image(sprites[mapNums[i][j]], x, y, scale*tileWidth, scale*tileWidth);
      map.tab.fill(0, 0);
      map.tab.rect(x, y, scale*tileWidth, scale*tileWidth);
      if(map.tabRect(x, y, scale*tileWidth, scale*tileWidth)) {
        if(mousePressed&&!isDragging) {
          toolOnBlock(i, j);
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

void tools() {
  tools.update();
  tools.tab.beginDraw();
  tools.tab.background(255);
  if(mousePressed) {
    for(int i=0; i<toolList.length; i++) {
      if(tools.tabRect(0, i*150+20, 150, 150)) {
        toolSelected=i;
      }
    }
  }
  for(int i=0; i<toolList.length; i++) {
    if(toolSelected==i) {
      tools.tab.fill(200);
    } else tools.tab.fill(255);
    tools.tab.rect(0, 150*i+20, 150, 150);
    tools.tab.textAlign(CENTER);
    tools.tab.textSize(30);
    tools.tab.fill(0);
    tools.tab.text(toolList[i], 75, 100+150*i);
  }
  tools.tab.endDraw();
  tools.display();
}

void toolOnBlock(int x, int y) {
  switch (toolSelected) {
    case 0:
      brushTool(x, y);
      break;
    case 1:
      lineTool(x, y);
      break;
    case 2:
      fillTool(x, y);
      break;
  }
}

void brushTool(int x, int y) {
  mapNums[x][y]=spriteSelected;
}

void lineTool(int x, int y) {
  if(!linePressed) {
    lineX=x;
    lineY=y;
    linePressed=true;
  }
  if(linePressed&&lineX!=x||lineY!=y) {
    float totalDist=dist(x, y, lineX, lineY);
    PVector movement=new PVector((lineX-x)/totalDist, (lineY-y)/totalDist);
    for(int i=0; i<totalDist+0.2; i++) {
      mapNums[round(x+movement.x*i)][round(y+movement.y*i)]=spriteSelected;
    }
    lineReset=true;
  }
}

void fillTool(int x, int y) {
  int prevBlock=mapNums[x][y];
  mapNums[x][y]=spriteSelected;
  for(int i=0; i<4; i++) {
    int tempX=0, tempY=0;
    switch(i) {
      case 1:
        tempX=x-1;
        tempY=y;
        break;
      case 0:
        tempX=x+1;
        tempY=y;
        break;
      case 2:
        tempX=x;
        tempY=y-1;
        break;
      case 3:
        tempX=x;
        tempY=y+1;
        break;
    }
    if(tempX>=0&&tempX<=mapNums.length-1&&tempY>=0&&tempY<=mapNums.length-1) {
      if(mapNums[tempX][tempY]==prevBlock&&mapNums[tempX][tempY]!=spriteSelected) {
        fillTool(tempX, tempY);
      }
    }
  }
}

void exitButton() {
  if(cursorRect(width-90, 0, 90, 50)&&mousePressed&&!isDragging) {
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