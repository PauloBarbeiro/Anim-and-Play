class BixoPlay{

  ArrayList bixos;
  //ArrayList explosao;
  PImage[] explosao;
  ArrayList explosoes;
  //ArrayList explosoes_time;
  
  boolean canRun = false;
  
  BixoPlay(){
    this.bixos = new ArrayList();
    
    this.explosoes = new ArrayList();
    
    this.explosao = new PImage[8];
    this.explosao[0] = requestImage("explo_00.png");
    this.explosao[1] = requestImage("explo_01.png");
    this.explosao[2] = requestImage("explo_02.png");
    this.explosao[3] = requestImage("explo_03.png");
    this.explosao[4] = requestImage("explo_04.png");
    this.explosao[5] = requestImage("explo_05.png");
    this.explosao[6] = requestImage("explo_06.png");
    this.explosao[7] = requestImage("explo_07.png");
    
  }
  
  public void instanciaNovoBixo(String lista_imagens){
    this.bixos.add( new Bixo(lista_imagens,int(random(10,700)),int(random(10,500))) );
    //this.canRun = true;
  }

  public void run(){
    println("loop ---------------------------------------------");
    for(int i=0 ; i<this.bixos.size() ; i++){
      Bixo tmp = (Bixo) this.bixos.get(i);
      tmp.enxame(this.bixos);
      tmp.run();
      
    }
    this.collision();
    //this.desenhaExplosoes();
  }//run
  
  // ==================================================================
  // Load XML FILE
  // ==================================================================
  public void reloadData(){
    
    this.clearData();
    
    try{
      xmlInOut = loadXML("dados0.xml");
      println("Player :: Carregou XML com sucesso.");
    }
    catch(Exception e){
      println("ERRO: Ao carregar XML -> dados || "+e);
      //xmlEvent(new proxml.XMLElement("dados"));
    }//*/
  
  }//reloadData
  
  private void clearData(){
    this.bixos.clear();
  }
  
  private void xmlEvent(/*proxml.XMLElement element*/){
    /*
    println("Disparado evento do XML");
    xmlFile = element;
    readXMLFile();
    //*/
  }
  
  private void readXMLFile(){
    /*
    xmlFile.printElementTree(" ");
    //proxml.XMLElement monstros;
    proxml.XMLElement monstro;
    proxml.XMLElement imagens;
    //proxml.XMLElement mascara;
  //  
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
  //  monstros.countChildren()
    //if( monstros != null){
      for(int i=0 ; i<xmlFile.countChildren() ; i++){
        println("----- "+i);
        monstro = xmlFile.getChild(i);
        imagens = monstro.getChild(0);
        //mascara = monstro.getChild(1);
        println(imagens.getAttribute("lista"));
        if(imagens.getAttribute("lista").length() > 6){
          this.instanciaNovoBixo(imagens.getAttribute("lista"));
        }
        //println(mascara.firstChild());
      }
      
      //player.canRun = true;
    //}//if
    //*/
  }//readXMLFile
  
  // ====================================================================
  private void collision(){
    for(int i=0 ; i<this.bixos.size() ; i++){
      Bixo tmp = (Bixo) this.bixos.get(i);
      
      int pos_x = int(tmp.getLoc().x);
      int pos_y = int(tmp.getLoc().y);
      //println("-----------------------------");
      //println("posicao: "+pos_x+" / width: "+width);
      float norma_x = norm(pos_x, 0, width);
      float norma_y = norm(pos_y, 0, height);
      
      //println("posicao: "+norma_x+" / larg mov: "+movement.width);
      //println("usando norm: "+norm(pos_x, 0, movement.width));
      int proj_movement_x = int(norma_x*movement.width);
      int proj_movement_y = int(norma_y*movement.height);
      
      //println("Posição de projeção: "+proj_movement_x+" / "+proj_movement_y);
      
      color cor = movement.get(proj_movement_x,proj_movement_y);
      //float brilho = brightness(cor);
      //println("cor: "+cor+" / brilho: "+brilho);
      if(brightness(cor) > 10){
        tmp.colidiu(new PVector(pos_x, pos_y));
        //println("ponto da colisão: "+pos_x+"/"+pos_y);
        this.explosoes.add(new PVector(pos_x, pos_y));
        //tmp = null;
      }//if
      
    }//for
  }//collision
  
  
  private void desenhaExplosoes(){
    if(this.explosoes.size() > 1){ // ---- há explosoes
      // --- para cada explosão
      for(int i=0 ; i<this.explosoes.size() ; i++){
        PVector tmp = (PVector) this.explosoes.get(i);
        ellipse(tmp.x, tmp.y, 10,10);
      }//for
    }
  }//function
  
//  private boolean explosaoAcabou(PVector v){
//    
//  }
  
}//class