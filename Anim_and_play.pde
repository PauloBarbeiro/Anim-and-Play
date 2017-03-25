import fullscreen.*;
import japplemenubar.*;

import codeanticode.gsvideo.*;
import proxml.*;



GSCapture capVideo; // --------------- Captura de video

FullScreen fs;      // --------------- FullScreen


int thresholdLevel = 50;
PImage movement;                  // Imagem que guardara o movimento
PImage exibir;

int numPixels;
int[] previousFrame;

BixoMaker maker;                 //--- BIXOMAKER
BixoPlay player;                 //--- BIXOPLAYER
proxml.XMLElement xmlFile;
XMLInOut xmlInOut;
int qtdBixos;


// CALCULOS PARA CINEMATICA
//int loc_x0, loc_x1;
//float tmp_0, tmp_1 = 0.000;
//float deltaTime;
//float vel_x;


// objetos para teste
//PImage img;
//int cellsize = 10;
//int columns, rows;
//int margem = 20;

//GUI
Botao bt_captura;
Botao bt_criarBixo;
Botao bt_brincar;
Botao bt_voltar;


void setup()
{

  //size( 640, 480);
  size( 800, 600);
  //size(1024,768);
  //size(screen.width, screen.height);
  //println("Screen: "+screen.width+" X "+screen.height);
  colorMode(RGB); 
  ellipseMode(CENTER);
  
    
  //----------------------------------------- GSCapture
  capVideo = new GSCapture(this, 320,240, 24);
  //opencv.allocate(320,240);
  numPixels = capVideo.width * capVideo.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  //loadPixels();
  movement = new PImage(320, 240);
  
  //----------------------------------------- BIXOPLAYER
  player = new BixoPlay();
  
  //----------------------------------------- BIXOMAKER
  xmlInOut = new XMLInOut(this);
  try{
    xmlInOut.loadElement("dados0.xml");
    println("Carregou XML com sucesso.");
  }
  catch(Exception e){
    println("ERRO: Ao carregar XML -> dados || "+e);
    xmlEvent(new proxml.XMLElement("dados"));
  }
  maker = new BixoMaker(); 
  
  // ---------------------------------------- GUI
  bt_captura = new Botao(int(width*0.05), int(height*0.9) , 150,30 , 'f', "Criar Bixos");
  bt_criarBixo = new Botao( int(width*0.3), int(height*0.9) , 150,30, 'm', "Concluir");
  bt_brincar = new Botao ( int(width*0.5), int(height*0.9), 150,30, 'c', "Cancelar" );
  bt_voltar = new Botao(int(width*0.715), int(height*0.52) , 200,30 , 'v' , "Apagar último");
  
  // ---------------------------------------- FullScreen
  fs = new FullScreen(this);
  fs.setShortcutsEnabled(true);
  //fs.enter();

}


//---------------------------------------------------
void draw(){

  //background(200);
  //startDT();
  
  
  if( capVideo.available() == true){
    captureAction(false); // Captura, Diferenca, Remember
    captureBlobs(false); // FastBlur, Deteccao, Desenho
    
    if(!maker.ativado){
      renderVideoCapture();
    }
    if(player.canRun){
      player.run();
    } 
  }
  
  // GUI
  bt_captura.run();
    
  if(maker.ativado){
    bt_criarBixo.run();
    maker.run();
    bt_brincar.run();
  }
  
  //println("DT: "+getDeltaTime());
  //println("-----------------------");

}//draw


// =================================================
// CONTEÚDO A SER EXIBIDO
// =================================================

void xmlEvent(proxml.XMLElement element){
  println("Disparado evento do XML");
  xmlFile = element;
  readXMLFile();
}

void readXMLFile(){
  xmlFile.printElementTree(" ");
  proxml.XMLElement monstro;
  proxml.XMLElement imagens;
  
  //config
  try{
    //monstros = xmlFile.getChild(0);
    qtdBixos = xmlFile.getIntAttribute("qtd");
    println("qtd monstros: "+qtdBixos);
  }
  catch(Exception e){
    //monstros = null;
    qtdBixos = 0;
    println("Monstros não possui \"filhos\"! ");
  }
  
    for(int i=0 ; i<xmlFile.countChildren() ; i++){
      println("----- "+i);
      monstro = xmlFile.getChild(i);
      imagens = monstro.getChild(0);
      //mascara = monstro.getChild(1);
      println(imagens.getAttribute("lista"));
      if(imagens.getAttribute("lista").length() > 6){
        player.instanciaNovoBixo(imagens.getAttribute("lista"));
      }
      //println(mascara.firstChild());
    }
    
    player.canRun = true;
  //}//if
  
}//readXMLFile
// =================================================
// CApture Tasks
// =================================================

void captureAction(boolean output){
  capVideo.read();

  movement = capVideo.get();
  
  movement.loadPixels(); // Make its pixels[] array available

    // DETECTA DIFERENÇA ENTRE FRAMES
    int movementSum = 0; // Amount of movement in the frame
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      color currColor = movement.pixels[i];
      color prevColor = previousFrame[i];
      // Extract the red, green, and blue components from current pixel
      int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract red, green, and blue components from previous pixel
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      // Add these differences to the running tally
      movementSum += diffR + diffG + diffB;
      // Render the difference image to the screen
      movement.pixels[i] = color(diffR, diffG, diffB);
      // The following line is much faster, but more confusing to read
      //pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
      // Save the current color into the 'previous' buffer
      previousFrame[i] = currColor;
    }
    // To prevent flicker from frames that are all black (no movement),
    // only update the screen if the image has changed.
    if (movementSum > 0) {
      movement.updatePixels();
      //println(movementSum); // Print the total amount of movement to the console
    }
  
  
  if (output) image( movement, 0, 0 );
}

void captureBlobs(boolean output){
  fastblur(movement, 10);//2
}

void renderVideoCapture(){
  exibir = capVideo.get();
  exibir.resize(width, height);
  image(exibir, 0,0);
}


// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img,int radius)
{
 if (radius<1){
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
  int vmin[] = new int[max(w,h)];
  int vmax[] = new int[max(w,h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++){
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++){
    rsum=gsum=bsum=0;
    for(i=-radius;i<=radius;i++){
      p=pix[yi+min(wm,max(i,0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++){

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if(y==0){
        vmin[x]=min(x+radius+1,wm);
        vmax[x]=max(x-radius,0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++){
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for(i=-radius;i<=radius;i++){
      yi=max(0,yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++){
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if(x==0){
        vmin[y]=min(y+radius+1,hm)*w;
        vmax[y]=max(y-radius,0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }

}

void mouseReleased(){
  //println("clique");
  
  //inicia Maker
  if(bt_captura.clique(mouseX, mouseY)){ 
    player.canRun = false;
    maker.ativar(); 
  }
  else if(bt_criarBixo.clique(mouseX, mouseY)){
    maker.concluirBixo();
    player.reloadData();
  }
  else if(bt_brincar.clique(mouseX, mouseY)){
    println("--- BT BRINCAR ---");
    //maker.concluirBixo();
    maker.desativar();
    player.canRun = true;
  }
  else if(bt_voltar.clique(mouseX, mouseY)){
    println("Voltar");
    if(maker.ativado){
      maker.apagar(1);
    }
  }
  
  //
  maker.clique(mouseX, mouseY);
  
}

void keyPressed(){
  bt_captura.pressed(key);
  if(key == 'c'){
    //maker.salvaListaImagens();
    player.canRun = true;
  }
}


