/*
1. shoot ball from mouse position with a random tecture and random direction.
2.ball falls to ground due to gravity
3. ball spin determined by original direction and bounces
4. ball on ball collision 
5. potential energy decay with time and collisions
*/

float FLOOR = 920;
public float THRESH = 0.001;
public float START_VELOCITY = 10.0;
public float ENERGYLOSS = 0.5;
float gravity = 0.98;
float bounce = -1;

public PShape back_wall;
class Ball {
  boolean moving = true;
  float xpos, ypos, zpos, velx, vely, velz;
  float size = 100;
  PShape shape = createShape(SPHERE, size);
  float rotX;
  float rotY;
  Ball lastCollision = null;
  Ball(float x, float y, float z, float vx, float vy, float vz) {
    xpos = x;
    ypos = y;
    zpos = z;
    velx = vx;
    vely = vy;
    velz = vz;
    shape.setTexture(loadImage(int(random(1, 4)) + ".jpeg"));
    
  }
  
}


void put_a_cube_at_here(){
  beginShape();
  stroke(255);
  //200 so its bigger in general
  vertex(200, 200, 200);
  vertex(200, -200, 200);
  vertex(-200, -200, 200);
  vertex(-200, 200, 200);
  
  vertex(-200, -200, 200);
  vertex(-200, -200, -200);
  vertex(-200, 200, -200);
  vertex(-200, 200, 200);

  vertex(-200, 200, 200);
  vertex(200, 200, 200);
  vertex(200, 200, -200);
  vertex(-200, 200, -200);
 
  vertex(-200, 200, -200);
  vertex(200, 200, -200);
  vertex(200, -200, -200);
  vertex(-200, -200, -200);

  vertex(-200, -200, -200);
  vertex(200, -200, -200);
  vertex(200, -200, 200);
  vertex(-200, -200, 200);
  endShape();

  
}


ArrayList<Ball> balls = new ArrayList<Ball>();


PShape createBall() {
  PShape globe;
  globe = createShape(SPHERE, 100);
  //globe.setTexture(img);
  return globe;
}

void setup() {
 size(1000, 1000, P3D);
 back_wall = createShape(RECT, 0, 1000, 0, 1000);
}
void mouseClicked() {
  Ball ball = new Ball(float(mouseX), float(mouseY), 0.0,random(-10, 10),gravity + random(-10, 10),random(1, 10));
  boolean newBall = true;
  for (Ball ball2 : balls) {
    if (distance(ball,ball2) < 200) {
      newBall = false;
    }
  }
  if (newBall)
    balls.add(ball);
}

void draw() {
  int time = millis() / 100;
  background(0);
  lights();



  
  
  pushMatrix();
  translate(width/2, height/2, 400);
  put_a_cube_at_here(); 
  popMatrix();

  noStroke();
  update();
  noStroke();

  
  
}

double distance(Ball ball, Ball ball2) {
  return Math.sqrt (
          (ball2.xpos - ball.xpos) * (ball2.xpos - ball.xpos) 
          + (ball2.ypos - ball.ypos) * (ball2.ypos - ball.ypos) 
          + (ball2.zpos - ball.zpos) * (ball2.zpos - ball.zpos)
        );
                        
}

void update() {
 boolean colliding;
 for (Ball ball : balls) {
   colliding = false;
   //ball.ypos -= 1;
   
   
   
   if(ball.ypos > FLOOR || ball.ypos < 0) {
     ball.vely *= bounce;
     
     if (ball.vely < 0) {
        ball.vely += ENERGYLOSS;
      } else {
        ball.vely -= ENERGYLOSS;
      }
     if (ball.ypos > FLOOR && ball.velx < THRESH && ball.vely < THRESH && ball.velz < THRESH) {
       ball.moving = false;
     }
    }
    
    if(ball.zpos < -800 || ball.zpos > 0) {
      ball.velz *= bounce;
      
      if (ball.velz < 0) {
        ball.velz += ENERGYLOSS;
      } else {
        ball.velz -= ENERGYLOSS;
      }
      
     
    }
    
    if (ball.xpos < 0 || ball.xpos > 800 ) {
      ball.velx *= bounce;
      
      if (ball.velx < 0) {
        ball.velx += ENERGYLOSS;
      } else {
        ball.velx -= ENERGYLOSS;
      }
    } 
    
    for (Ball ball2: balls) {
      if (ball.lastCollision == ball2) {
        ball.lastCollision = null;
        ball2.lastCollision = null;
        continue;
      }
      double distance = distance(ball, ball2);   
                             
      if(ball != ball2 && distance < 200) {
        //ball.velx *= bounce;
        colliding = true;
        if (ball.velx < 0) {
          ball.velx += ENERGYLOSS;
        } else {
          ball.velx -= ENERGYLOSS;
        }
        
        if (ball.vely < 0) {
          ball.vely += ENERGYLOSS;
        } else {
          ball.vely -= ENERGYLOSS;
        }
        
        if (ball.velz < 0) {
          ball.velz += ENERGYLOSS;
        } else {
          ball.velz -= ENERGYLOSS;
        }
        
        
        collision(ball, ball2);
          
          /*
          float tx = ball.velx;
          float ty = ball.vely;
          float tz = ball.velz;
          
          ball.velx = ball2.velx;
          ball.vely = ball2.vely;
          ball.velz = ball2.velz;
          
          ball2.velx = tx;
          ball2.vely = ty;
          ball2.velz = tz;*/
          
          ball2.lastCollision = ball;
          ball.lastCollision = ball2;
        //collision(ball, ball2);
        //ball.vely *= bounce;
        //ball.velz *= bounce;
      }
    }
    
    if (!ball.moving) {
        ball.velx = 0;
        ball.vely = 0;
        ball.velz = 0;
    } else {
    
       ball.vely += gravity;
      
       ball.xpos -= ball.velx;
       ball.zpos -= ball.velz;
       ball.ypos += ball.vely;
    }
   
    
    
    pushMatrix();
    
    translate(ball.xpos, ball.ypos, ball.zpos);
    //fill(255);
     if (ball.moving) {
       ball.shape.rotateX(radians(ball.velx));
      
     }

    shape(ball.shape, 0,0);
  
    popMatrix();
    
  }
}
 
   
   
void collision(Ball b1, Ball b2) {
  //determine the 3D angle between the two colliders
   if (!b1.moving) {
     b1.velx = -1 * b1.velx;
     b1.vely = -1 * b1.vely;
     b1.velz = -1 * b1.velz;
     return;
   } else if (!b2.moving) {
     b2.velx = -1 * b2.velx;
     b2.vely = -1 * b2.vely;
     b2.velz = -1 * b2.velz;
     return;
   }
   //calculating normal vector n = x1 - x2 / |x1-x2|
   float dx = (b1.xpos - b2.xpos);
   float dy = (b1.ypos - b2.ypos);
   float dz = (b1.zpos - b2.zpos);
   
   float nx = dx / sqrt(dx*dx + dy*dy + dz*dz);
   float ny = dy / sqrt(dx*dx + dy*dy + dz*dz);
   float nz = dz / sqrt(dx*dx + dy*dy + dz*dz);
   
   //difference in velocities (relative velocity)
   // dv = v1 - v2
   float dvx =  (b1.velx - b2.velx);
   float dvy =  (b1.vely - b2.vely);
   float dvz =  (b1.velz - b2.velz);
   
   //relative velocity along the normal direction
   // vnorm = (dv dot n)n
   float dot = (dvx * nx) + (dvy * ny) + (dvz * nz);
    
   float nvx = dot * nx;
   float nvy = dot * ny;
   float nvz = dot * nz;
   
   // normal components of momentum are interchanged in ball-ball collision
   //balls with equal mass interchange momentum.
   
   b1.velx -= nvx;
   b1.vely -= nvy;
   b1.velz -= nvz;
   
   b2.velx += nvx;
   b2.vely += nvy;
   b2.velz += nvz;
   
  
 
  System.out.println(nvx);
  System.out.println(nvy);
  System.out.println(nvz);
  
 
   
}
