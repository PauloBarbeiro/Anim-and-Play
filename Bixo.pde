class Bixo{
  
  ArrayList imagens;
  
  PVector loc;
  PVector vel;
  PVector acc;
  float maxVel;
  float maxForca;
  //float pos_y;
  float larg;
  float alt;
  
  //bixo esplosao
  int timer = 10;
  int timer_interval;
  long previous_time;
  int muleta = 8;
  PVector explo_loc;
  
  
  // ====================================================================
  // CONSTRUTOR
  // ====================================================================
  
  Bixo(String lista_imagens, int x, int y){
    //println("Criando instancia de Bixo...");
    
    this.loc = new PVector(x,y);
    this.vel = new PVector(random(-10,10),random(-10,10));
    this.acc = new PVector(0,0);
    
    this.maxVel = 75.0;
    this.maxForca=0.1;
    
    this.imagens = new ArrayList();
    this.gerarImagens(lista_imagens);
    //this.makeBody();
    
    //explosao
    this.timer_interval = 1000/timer;
    //println("Intervalo para tempo: "+this.timer_interval);
    this.previous_time = millis();
  }//Bixo
  
  
  // ====================================================================
  // RUN e DISPLAY --------------------------------------------   <<<<<<<
  // ====================================================================
  public void run(){
    this.atualiza();
    this.desenha();
  }//run
  
  private void desenha(){
    //Vec2 pos = mundo.getScreenPos(bixoBody);
    float ang = vel.heading2D() + radians(90);
    
    //fill(#ff0000);
    //ellipse(this.loc.x, this.loc.y, 10,10);
    
    pushMatrix();
    translate(this.loc.x,this.loc.y);
    rotate(ang);
    
    image((PImage) this.imagens.get( (frameCount%this.imagens.size()) ), -this.larg/4,-this.alt/4);
    
    popMatrix();
    
    if (this.muleta <= 6){ //explosao ainda não acabou
      if( (millis()-this.previous_time) > this.timer_interval ){
       // println("mudar imagem: "+this.muleta); 
        this.previous_time = millis();
        this.muleta++;
//        if(this.muleta >= (this.imagens.size()-1)){
//          this.muleta = 0;
//        }
//        else{
//          this.muleta +=1;
//        }
      }//if
      //println("muleta: "+this.muleta);
      image(player.explosao[this.muleta], this.explo_loc.x, this.explo_loc.y);
      
    }//muleta
    
  }
  
  private void atualiza(){
    
    vel.add(acc);
    //vel.limit(maxVel);
    loc.add(vel);
    
    if (loc.x > width) loc.x = 0;
    if (loc.x < 0) loc.x = width;
    if (loc.y > height) loc.y = 0;
    if (loc.y < 0) loc.y = height;
    
    acc.mult(0);
  }
  
  // ====================================================================
  // Preparação das imagens
  // ====================================================================
  private void gerarImagens(String lista){
    String[] tmp = split(lista, ',');
    //println("Gerando imagens: "+tmp.length);
    for(int i=0 ; i<(tmp.length-1) ; i++){
      println(tmp[i]);
      this.imagens.add( loadImage(tmp[i]) );
    }
    //player.canRun = true;
    this.dimensoesBixo((PImage) this.imagens.get(0));
  }
  
  private void dimensoesBixo(PImage img){
    this.larg = img.width;
    this.alt = img.height;
    //redimenciona
    for(int i=0 ; i<this.imagens.size() ; i++){
      PImage tmp = (PImage) this.imagens.get(i);
      //tmp.resize(img.width/2, img.height/2);
    }
  }
  // ====================================================================
  // GAME
  // ====================================================================
  
  public void colidiu(PVector ex_loc){
    //println("Esse Bixo bateu no Blob!!!!");
    this.explo_loc = ex_loc.get();
    this.setLoc( new PVector(10,10) );
    this.muleta = 0;
    //println("nova muleta: "+this.muleta);
  }
  
  // ====================================================================
  // GETTERS / SETTERS
  // ====================================================================
  public PVector getLoc(){ return this.loc; }
  
  public void setLoc(PVector new_pos){ 
    this.loc.mult(0);
    this.loc = new_pos.get(); 
  }
  
  // ====================================================================
  // FÍSICA e FLOCKING
  // ====================================================================
  void enxame(ArrayList grupo){
    //Funções para a lógica Sep, Ali, Coe
    PVector separacao = fSeparacao(grupo);
    PVector alinhamento = fAlinhamento(grupo);
    PVector coesao = fCoesao(grupo);
    //Definição de pesos para forças
    separacao.mult(0.85);
    alinhamento.mult(0.4);
    coesao.mult(0.95);
    //Adicionar as forças à aceleração
    //println(separacao);
    acc.add(separacao);
    acc.add(alinhamento);
    acc.add(coesao);
  }
  
  PVector fCoesao(ArrayList grupo){
    float distCoesao = 500.0;
    PVector guia = new PVector(0,0);
    int conta = 0;
    
    //Loop para selecionar os objetos próximos
    for(int i=0 ; i<grupo.size() ; i++){
      Bixo outro = (Bixo) grupo.get(i);
      float d = PVector.dist(loc, outro.loc);
      //fazer os cálculos apenas com os objetos próximos
      if( (d>0) && (d<distCoesao) ){
        //Captura o vetro de velocidade do 'outro'
        guia.add(outro.loc);
        conta++;
      }
    }//for
    
    //média 
    if(conta > 0){
      guia.div( (float)conta );
      return steerVector(guia);
    }    
    return guia;
  }
  
  PVector fAlinhamento(ArrayList grupo){
    float distAlinhamento = 25.0;
    PVector guia = new PVector(0,0);
    int conta = 0;
    
    //Loop para selecionar os objetos próximos
    for(int i=0 ; i<grupo.size() ; i++){
      Bixo outro = (Bixo) grupo.get(i);
      float d = PVector.dist(loc, outro.loc);
      //fazer os cálculos apenas com os objetos próximos
      if( (d>0) && (d<distAlinhamento) ){
        //Captura o vetro de velocidade do 'outro'
        guia.add(outro.vel);
        conta++;
      }
    }//for
    
    //média 
    if(conta > 0){
      guia.div( (float)conta );
    }
    
    //Havendo um vetor guia, implentar o steer behavior
    if(guia.mag() >0){
      guia.normalize();
      guia.mult(maxVel);
      guia.sub(vel);
      guia.limit(maxForca);
    }
    
    return guia;
  }
  
  PVector fSeparacao(ArrayList grupo){
    float distSeparacao = 25.0;
    PVector guia = new PVector(0,0);
    int conta = 0;
    
    //Loop para selecionar os objetos próximos
    for(int i=0 ; i<grupo.size() ; i++){
      Bixo outro = (Bixo) grupo.get(i);
      float d = PVector.dist(loc, outro.loc);
      //fazer os cálculos apenas com os objetos próximos
      if( (d>0) && (d<distSeparacao) ){
        PVector diff = PVector.sub(loc, outro.loc);
        diff.normalize();
        diff.div(d);
        guia.add(diff);
        conta++;
      }
    }//for
    
    //média 
    if(conta > 0){
      guia.div( (float)conta );
    }
    
    //Havendo um vetor guia, implentar o steer behavior
    if(guia.mag() >0){
      guia.normalize();
      guia.mult(maxVel);
      guia.sub(vel);
      guia.limit(maxForca);
    }
    
    return guia;
  }
  
  
  
  PVector steerVector(PVector alvo){
    PVector steer;
    PVector destino = PVector.sub(alvo, loc);
    float distancia = destino.mag();
    
    if(distancia > 0){//calcula o vetor se a distancia for maior que zero
      destino.normalize();//normaliza o vetor
      
      if( distancia < 100.0f ) destino.mult(maxVel*(distancia/100.0f));
      else destino.mult(maxVel);//deixa o vetor do tamanho da velocidade máxima
      
      steer = PVector.sub(destino, vel);//vetor de guia
      steer.limit(maxForca);//limita a intensidade do guia
    }
    else{//o vetor guia(steer) será zero
      steer = new PVector(0,0);
    }
    
    return steer;
  }
  
}//Bixo
