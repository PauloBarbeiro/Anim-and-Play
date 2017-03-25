class Botao{
   
   int pos_x;
   int pos_y;
   
   int b_width;
   int b_height;
   
   char tecla_atalho;
   PFont font;
   String legenda;
   
   Botao(int x_, int y_, int larg, int alt, char at, String name){
     this.pos_x = x_;
     this.pos_y = y_;
     this.tecla_atalho = at;
     
     this.b_width = larg;
     this.b_height= alt;
     
     legenda = name;
     font = loadFont("Purisa-25.vlw");
   }//construtor
   
   public void run(){
     this.render();
   }

   private void render(){
     pushMatrix();
     textFont(font);
     translate(this.pos_x, this.pos_y);
     //rect
     fill(70,80,180);
     rect(0,0 , this.b_width, this.b_height);
     //legenda
     fill(255);
     text(this.legenda, 5, this.b_height-5);
     
     popMatrix();
   }
   
   // EVENTOS ------
   public boolean clique(int x_, int y_){
     //println("mouse released");
     if( (x_ > this.pos_x) && (x_ < (this.pos_x+this.b_width)) &&
         (y_ > this.pos_y) && (y_ < (this.pos_y+this.b_height))){
         println("clicou neste botao");
         return true;
     }
     else return false;
   }//clique
   
   void pressed(char tkl){
     if(tkl == this.tecla_atalho){
       println("tecla ativou este botão");
     }
   }

}//class
