/*
1. shoot ball from mouse position with a random tecture and random direction.
2.ball falls to ground due to gravity
3. ball spin determined by original direction and bounces
4. ball on ball collision 
5. potential energy decay 
*/

final int SIZE = 1000;
final float THRESH = 0.05;
final float START_VELOCITY = 15.0;
final float ENERGYLOSS = 0.95;
final float gravity = 0.5;
final float bounce = -1;
ArrayList<Ball> balls = new ArrayList<Ball>();

class Ball {
  //position components
  float xpos, ypos, zpos;
  //velocity components
  float velx, vely, velz;
  //rotational velocity components
  // (only using rotX currentlya)
  float rotX, rotY, rotZ;
  //define size of ball.
  float radius = 100;
  
  PShape shape = createShape(SPHERE,radius);
  boolean moving = true;
  Ball lastCollision = null;
  Ball(float x, float y, float z, float vx, float vy, float vz) {
    xpos = x;
    ypos = y;
    zpos = z;
    velx = vx;
    vely = vy;
    velz = vz;
    shape.setTexture(loadImage(floor(random(1, 6)) + ".jpeg"));
    
  }
  
}

void setup() {
 size(1000, 1000, P3D);
}

/*
  when mouse is clicked, create a ball with random trajectory.
  Do not create the ball if there is a ball in the way.
*/
void mouseClicked() {
  Ball ball = new Ball(float(mouseX), float(mouseY), 0.0,random(-START_VELOCITY, START_VELOCITY),gravity + random(-START_VELOCITY, START_VELOCITY),random(1, START_VELOCITY));
  boolean newBall = true;
  for (Ball ball2 : balls) {
    if (distance(ball,ball2) < ball.radius*2) {
      newBall = false;
    }
  }
  if (newBall)
    balls.add(ball);
}

//draw walls and call update (which does all ball related stuff)
void draw() {
  clear();
  background(0);
  
  pushMatrix();
  translate(width/2, height/2, 400);
  hint(DISABLE_DEPTH_TEST);
  fill(0, 255, 255, 100);
  put_a_cube_at_here(); 
  popMatrix();
  
  hint(ENABLE_DEPTH_TEST);
  noStroke();
  fill(255);
  update();
  
}

/*
  calculate distance between two balls
*/
double distance(Ball ball, Ball ball2) {
  return Math.sqrt (
          (ball2.xpos - ball.xpos) * (ball2.xpos - ball.xpos) 
          + (ball2.ypos - ball.ypos) * (ball2.ypos - ball.ypos) 
          + (ball2.zpos - ball.zpos) * (ball2.zpos - ball.zpos)
        );                    
}

/*
  alters velcity on wall collisions
*/
void wallCollision(Ball ball) {
  
  /*
     Down is +y
     Floor and Ceiling Bounce
  */
  if(ball.ypos > SIZE || ball.ypos < 0) {
    
    ball.vely *= bounce;
    ball.vely *= ENERGYLOSS;
  }
  
  /*
    Front and back walls 
    Back wall is -z
    Camera at z = 0
  */
  if(ball.zpos < -SIZE || ball.zpos > 0) {
    if(ball.zpos < -SIZE)
      ball.zpos = -SIZE;
    else
      ball.zpos = 0;
    ball.velz *= bounce;
    ball.velz *= ENERGYLOSS;
  }
    
  /*
    Left and right walls
    right is +x
  */
  if (ball.xpos < 0 || ball.xpos > SIZE ) {
    if(ball.xpos > SIZE)
      ball.xpos = SIZE;
    else
      ball.xpos = 0;
    ball.velx *= bounce;
    ball.velx *= ENERGYLOSS;
  } 
}


/*
  cycles through all balls. detects collisions and calculates velocities.
  draws ball.
*/
void update() {
 boolean colliding;
 for (int i = 0; i < balls.size(); i ++) {
   Ball ball = balls.get(i);
   colliding = false;
   
  wallCollision(ball);
   
  // so we dont check the same collision twice. j = i = 1  
  for (int j = i+1; j < balls.size(); j ++) {
    Ball ball2 = balls.get(j);
    double distance = distance(ball, ball2);   
                             
    if(ball != ball2 && distance < ball.radius*2) {
      colliding = true;
      // transfer momentum between balls.
      collision(ball, ball2);
      ball2.lastCollision = ball;
      ball.lastCollision = ball2;
  
      }
    }
    ball.moving = true;
    // stop the y velocity growing large when on the ground
    if (ball.ypos < 1000){
        ball.vely += gravity; 
    } else if(ball.vely > 0) {
       ball.moving = false;
       ball.vely = 0;
      }
     
    // ball wont move when velocities have small magnitude.
    if(abs(ball.vely) > THRESH) 
      ball.ypos += ball.vely;
    if(abs(ball.velx) > THRESH)
      ball.xpos -= ball.velx;
    if(abs(ball.velz) > THRESH)
      ball.zpos -= ball.velz;
    
    // something rolling on the ground should continiously lose energy
    if(ball.ypos >= 1000) {    
      ball.velx *= ENERGYLOSS;
      ball.velz *= ENERGYLOSS;
      ball.vely *= ENERGYLOSS;       
      
    } 
     
    pushMatrix(); 
    translate(ball.xpos, ball.ypos, ball.zpos);
    ball.shape.rotateX(radians(ball.velx));
    shape(ball.shape, 0,0);
    popMatrix();
    
  }
}
 
   
/*
  exchanges momentum between two balls.
*/
void collision(Ball b1, Ball b2) {
  
  if (!b1.moving && b2.moving) {
    b2.vely = 0;
    return;
  } else if (!b2.moving && b1.moving) {
    b1.velx = 0;
    return;
  }
  
  float minDistance = b1.radius + b2.radius;
  
  //determine the 3D angle between the two colliders
  
  //calculating normal vector n = x1 - x2 / |x1-x2|
  float dx = (b1.xpos - b2.xpos);
  float dy = (b1.ypos - b2.ypos);
  float dz = (b1.zpos - b2.zpos);
   
  dx = (minDistance - dx)/2; 
  dy = (minDistance - dy)/2; 
  dz = (minDistance - dz)/2; 
   
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
  
  //energy loss in collision
  /*b1.velx *= ENERGYLOSS * ENERGYLOSS;
  b1.velz *= ENERGYLOSS  * ENERGYLOSS;
  b1.vely *= ENERGYLOSS  * ENERGYLOSS;
  b2.velx *= ENERGYLOSS  * ENERGYLOSS;
  b2.velz *= ENERGYLOSS  * ENERGYLOSS;
  b2.vely *= ENERGYLOSS * ENERGYLOSS;*/
   
  
 
  //System.out.println(nvx);
  //System.out.println(nvy);
  //System.out.println(nvz);  
}

/*
  defintion of cube.
*/
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
