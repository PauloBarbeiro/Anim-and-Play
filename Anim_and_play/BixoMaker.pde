class BixoMaker{

  PImage camView;
  PImage tmp_image;

  PImage img_gabarito;
  
  ArrayList imagens;
  ArrayList lista_imagens_names;
  ArrayList lista_imagens_masks;
  
  //boolean imgok = false;

  int camViewX;
  int camViewY;

  int lista_posX = 10;
  int lista_posY = 10;
  
  //bixo preview
  int timer = 5;
  int timer_interval;
  long previous_time;
  int muleta = -1;
  
  boolean ativado = false;
  color cor_tmp;
  int seq_tmp;
  
  PFont font;
  

  BixoMaker(){
    this.camViewX = (width/2)-(capVideo.width/2);
    this.camViewY = (height/2)-(capVideo.height/2);
    this.imagens = new ArrayList();
    this.lista_imagens_names = new ArrayList();
    this.lista_imagens_masks = new ArrayList();
    
    this.seq_tmp = 0;
    
    //preview bixo
    this.timer_interval = 1000/timer;
    //println("Intervalo para tempo: "+this.timer_interval);
    this.previous_time = millis();
    
    this.font = loadFont("Purisa-18.vlw");
    
    //Gabarito
    //this.img_gabarito = createImage(capVideo.width, capVideo.height, RGB);
    
  }//constructor

  public void ativar(){  
    this.ativado = true;  
  }

  public void desativar(){  
    println("desativar ---");
    this.ativado = false;  
    this.clearMaker();
  }

  public void run(){
        
    if(this.ativado){
      this.exibeCamView();
      this.exibeListaImagens();
      this.previewBixo();
    }
    
  }//run

  private void exibeCamView(){
    
      
    camView = capVideo.get();
    camView.filter(POSTERIZE,2);
    camView.filter(ERODE);
    //camView.filter(THRESHOLD);

    image(camView, this.camViewX, this.camViewY);
    if(this.img_gabarito != null){
      //tint(0,100,40, 50);
      image(this.img_gabarito, this.camViewX, this.camViewY);
      //noTint();
    }

  }

  public void clique(int x_, int y_){
    //Captura de imagem
    if( ativado && (x_ > this.camViewX) && (x_ < (this.camViewX+this.camView.width)) &&
      (y_ > this.camViewY) && (y_ < (this.camViewY+this.camView.height))){
      //println("clicou na foto");
      this.iniciaSequencia();
    }
    
    //criar Bixo
    
  }
  
  public void cliqueInicia(int x_, int y_){
    //break;  
  }

  // ---------------------------------------------- ROTINA de TRATAMENTO
  private void iniciaSequencia(){
    //limpa gabarito
    if(this.img_gabarito != null){
      //println("limpar gabarito");
      this.img_gabarito.resize(80,60);
      this.img_gabarito.loadPixels();
      for(int i=0 ; i<(this.img_gabarito.width*this.img_gabarito.height) ; i++){
        this.img_gabarito.pixels[i] = color(0,0,0,0);
      }
      this.img_gabarito.updatePixels();
      this.img_gabarito = null;
    }
    
    tmp_image = camView.get();   //captura
    //tmp_image.filter(THRESHOLD); //threshold
    //println("tmp_image size antes: "+tmp_image.width+" x "+tmp_image.height);
    tmp_image.resize(80,60);//160,120
    //println("tmp_image size depois: "+tmp_image.width+" x "+tmp_image.height);
    tmp_image.loadPixels();      //loadPixels
    //println(tmp_image.pixels.length +" ----------------");
    //this.avaliaDimensoesDoSimbolo(tmp_image);
    this.imagens.add( tmp_image.get() );
    this.insertAlpha( (PImage) imagens.get(imagens.size() -1) );
    
    //gabarito
    //this.img_gabarito = ((PImage) imagens.get(imagens.size() -1)).get();
    //this.img_gabarito.resize(camView.width, camView.height);
    
  }

  void avaliaDimensoesDoSimbolo(PImage img){
    //println("Avalia Dimensões do símbolo ---- ");
    //println("Imagem: "+img.width);
    int len = (img.width * img.height);
    //println("qtd de pixels: "+len);

    //println("Resultado Ax : "+ capturaPrimeiroPontoX(img) );
    //println("Resultado Ay : "+ capturaPrimeiroPontoY(img) );
    //println("Resultado Bx : "+ capturaUltimoPontoX(img) );
    //println("Resultado Bx : "+ capturaUltimoPontoY(img) );
    int[] p1 = {
      capturaPrimeiroPontoX(img),capturaPrimeiroPontoY(img)    };
    int[] p2 = {
      capturaUltimoPontoX(img),capturaUltimoPontoY(img)    };

    println("pontos: ("+p1[0]+","+p1[1]+") / ("+p2[0]+","+p2[1]+")");

    this.setRecorte(p1, p2);
    this.insertAlpha( (PImage) imagens.get(imagens.size() -1) );
  }

  private void setRecorte(int[] p1, int[] p2){
    println("SetRecorte ----");
    imagens.add( tmp_image.get(p1[0],p1[1], (p2[0]-p1[0]), (p2[1]-p1[1])) );
    //imagens.add(teste);
  }

  int capturaPrimeiroPontoY(PImage img){
    int len = (img.width * img.height);
    int ponto_y = 0;

    //captura o Y do primeiro ponto -----------------------
    for(int i=0 ; i<len ; i++){
      cor_tmp = img.pixels[i];
      if( (brightness(cor_tmp)/255) < 0.5){
        //println("brilho "+i+": "+brightness(cor_tmp));
        //println("Ponto do topo -> X:  "+(i%img.width)+" Y: "+(i/img.width));
        ponto_y = (i/img.width);
        break;
      }
      //println("pixel "+i+": "+red(cor_tmp)+","+green(cor_tmp)+","+blue(cor_tmp));
      //println(i);
    }

    return ponto_y;
  }

  int capturaPrimeiroPontoX(PImage img){
    int len = (img.width * img.height);
    int ponto_x = img.width;

    //captura o X do primeiro ponto ------------------------
    for(int i=0 ; i<len ; i++){
      cor_tmp = img.pixels[i];
      if( (brightness(cor_tmp)/255) < 0.5){
        //println("Ponto do topo -> X:  "+(i%img.width));
        if( (i%img.width) < ponto_x ) ponto_x = (i%img.width);
      }
      //println("pixel "+i+": "+red(cor_tmp)+","+green(cor_tmp)+","+blue(cor_tmp));
      //println(i);
    }

    return ponto_x;
  }

  int capturaUltimoPontoY(PImage img){
    int len = (img.width * img.height);
    int ponto_y = 0;

    //captura o Y do primeiro ponto -----------------------
    for(int i=0 ; i<len ; i++){
      cor_tmp = img.pixels[i];
      if( (brightness(cor_tmp)/255) < 0.5){
        //println("brilho "+i+": "+brightness(cor_tmp));
        //println("Ponto do topo -> X:  "+(i%img.width)+" Y: "+(i/img.width));
        ponto_y = (i/img.width);
      }
      //println("pixel "+i+": "+red(cor_tmp)+","+green(cor_tmp)+","+blue(cor_tmp));
      //println(i);
    }

    return ponto_y;
  }

  int capturaUltimoPontoX(PImage img){
    int len = (img.width * img.height);
    int ponto_x = 0;

    //captura o X do primeiro ponto ------------------------
    for(int i=0 ; i<len ; i++){
      cor_tmp = img.pixels[i];
      if( (brightness(cor_tmp)/255) < 0.5){
        //println("Ponto do topo -> X:  "+(i%img.width));
        if( (i%img.width) > ponto_x ) ponto_x = (i%img.width);
      }
      //println("pixel "+i+": "+red(cor_tmp)+","+green(cor_tmp)+","+blue(cor_tmp));
      //println(i);
    }

    return ponto_x;
  }

  // --------------------------------------------- InsertAlpha
  private void insertAlpha(PImage img){
    println(" Insert Alpha --- "+img);
    
    //variáveis para utilização
    int len = (img.width * img.height);
    int[] arr = new int[len];
    //String[] arr_mask = new String[len];
    //color new_color;
    
    //loop pela imagem-----------------
    //para criar a mascara, percorre os pixels
    //gera numero 0 para opaco
    //e numero 255 para transparente
    for(int i=0 ; i<len ; i++){
      cor_tmp = img.pixels[i];
      
      if( (brightness(cor_tmp)/255) > 0.95){
        arr[i] = 0;
       // arr_mask[i] = str(0);
      }
      else{
        arr[i] = 255;
        //arr_mask[i] = str(255);
      }
    }//for
    
    //aplica mascara
    img.mask(arr);
    
    // armazena informações para uso posterior no XML
    // nomes das imagens para salvar no diretório
    lista_imagens_names.add(new String("bixo-"+qtdBixos+"-seq-"+this.seq_tmp+".png"));
    // lista das mascaras para salvamento
//    String maskFinalString = "";
//    for(int i=0 ; i<arr.length ; i++){
//      if(i == arr.length){ maskFinalString += arr[i]; }
//      else {  maskFinalString += arr[i]+",";}
//    }
    //lista_imagens_masks.add( new String(maskFinalString) );
    
    this.seq_tmp++;
    //img.updatePixels();
    //imgTeste = img;
    //imgTeste.mask(arr);
    //imgok = true;
    //String img_name = "data/teste-"+qtdBixos+".png";
    //img.save(img_name);
    //this.salvaDadosNoXML(arr_mask, img_name);
    
    //Constroi imagem de gabarito
    this.img_gabarito = createImage(img.width, img.height, ARGB);
    this.img_gabarito.loadPixels();
    for(int i=0 ; i<len ; i++){
      if(arr[i] == 0)  this.img_gabarito.pixels[i] = color(0,200,0,0);
      else this.img_gabarito.pixels[i] = color(0,200,0,75);
    }
    this.img_gabarito.updatePixels();
    //this.img_gabarito.mask(arr);
    this.img_gabarito.resize(camView.width, camView.height);
    
  }//insertAlpha
  
  public void concluirBixo(){
    if(this.imagens.size() > 1){
      this.salvarImagensNoDiretorio();
      this.salvarDadosNoXML();
    }
    this.desativar();
  }
  
  
  private void salvarImagensNoDiretorio(){
    //println("Salvar imagens no diretório.");
    //println("qtd imagens: "+imagens.size());
    //println("qtd imagens names: "+lista_imagens_names.size());
    //println("qtd imagens names: "+lista_imagens_masks.size());
    //println("loop -------");
    
    for(int i=0 ; i<imagens.size() ; i++){
      //println(i);
      //println("Nome: "+(String) lista_imagens_names.get(i));
      //println("Mascara: "+(String) lista_imagens_masks.get(i));
      PImage tmp = (PImage) imagens.get(i);
      tmp.save( "data/"+(String) lista_imagens_names.get(i) );
      //println("-------");
    }//for
    
    //println("Finalizado o salvamento. ------- ");
    
  }//salvarImagensNoDiretorio
  
  private void salvarDadosNoXML(){
    /*
    qtdBixos++;
    
    xmlFile.addAttribute("qtd",qtdBixos);
    //println("ok");
    
    proxml.XMLElement monstro = new proxml.XMLElement("monstro");
    
    //preparar sequencia de imagens
    String listaFinal = "";
    for(int i=0 ; i<lista_imagens_names.size() ; i++){
      listaFinal += ( (String) lista_imagens_names.get(i)+",");
    }//for
    println(listaFinal);
    
    proxml.XMLElement imagens = new proxml.XMLElement("imagens");
    imagens.addAttribute("lista", listaFinal);
    monstro.addChild(imagens);
    
    xmlFile.addChild(monstro);
  
    xmlInOut.saveElement(xmlFile,"dados0.xml");    
    
    
    //*/
  }

  private void clearMaker(){
    println("--- clearMaker");
    if(this.imagens != null){
      println("imagens ! null");
      this.imagens.clear();
      this.lista_imagens_names.clear();
      if(this.img_gabarito != null){
        //println("limpar gabarito");
        this.img_gabarito.resize(80,60);
        this.img_gabarito.loadPixels();
        for(int i=0 ; i<(this.img_gabarito.width*this.img_gabarito.height) ; i++){
          this.img_gabarito.pixels[i] = color(0,0,0,0);
        }
        this.img_gabarito.updatePixels();
        this.img_gabarito = null;
    }
    }
  }//function

  public void apagar(int qtd){
    println("--- Apagar último");
    int size_inicial = this.imagens.size();
    int gab = 0;
    println(" size: "+size_inicial + " / verificação: "+(size_inicial-qtd) );
    for(int i=qtd; i>0 ; i--){
      println("item "+i);
      this.imagens.remove(this.imagens.size()-1);
      this.lista_imagens_names.remove(this.lista_imagens_names.size()-1);
      //gab = qtd;
    }//for
  }//apagar

  // -------------------------------------------------- LISTA de IMAGENS
  void exibeListaImagens(){
    
    pushMatrix();
        translate(0,lista_posY-10);
        noStroke();
        fill(255);
        rect(0,0, width,80);
    popMatrix();
    
    for(int i=0 ; i<imagens.size() ; i++){
      PImage list_tmp = (PImage) imagens.get(i);
      pushMatrix();
      translate((list_tmp.width*i)+lista_posX, lista_posY);
      //println("width: "+(list_tmp.width*i));
      //if((list_tmp.width*i)>=width) translate(0,160);
      //rotate(random(-1,1));    
      
      image(list_tmp, 0,0);
      popMatrix();
    }//for

    

  }
  
  void previewBixo(){
    /*
    //println("===========================");
    //println("now:       "+millis());
    //println("antes:     "+this.previous_time);
    //println("intervalo: "+(millis()-this.previous_time) );
    //println("muleta 0: "+this.muleta);
    
    pushMatrix();
        bt_voltar.run();
        translate(this.camViewX + 10 + this.camView.width, this.camViewY);
        noStroke();
        fill(255);
        textFont(this.font);
        text("Seu bixo ficará assim!", 0,10);
        rect(0,20, 100,80);
        if(this.imagens.size() > 0){
          //image((PImage) this.imagens.get( (frameCount%this.imagens.size()) ), 10,30);
          image((PImage) this.imagens.get( this.muleta ), 10,30);
        }
        //translate(0,200);
        
    popMatrix();
    
    
    
    
    if( (millis()-this.previous_time) > this.timer_interval ){
     // println("mudar imagem: "+this.muleta); 
      this.previous_time = millis();
      if(this.muleta >= (this.imagens.size()-1)){
        this.muleta = 0;
      }
      else{
        this.muleta +=1;
      }
    }
    //else{
      //println("não mudar a foto");
      
    //}
    //println("muleta 1: "+this.muleta);
    //*/
  }

}//class