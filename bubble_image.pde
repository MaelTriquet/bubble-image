ArrayList<Ball> balls = new ArrayList<Ball>();
int widthCell;
int heightCell;
int minRadius = 8;
int maxRadius = 17;
Cell[] cells;
int startI;
int stopI;
PImage image;
PVector[] init;
int startingFountainNb = 9;
int fountainNb = startingFountainNb;
Threading[] threads;
boolean showing = true;
color[] colors;
int lastChange = 0;
float startingSpeed = 8;
float speed = startingSpeed;
int substeps = 5;
boolean pause = false;
int maxBalls;
ArrayList<Integer> rand = new ArrayList<Integer>();

void setup() {
  size(500, 500);
  //noStroke();
  stroke(255);
  image = loadImage("paularis.jpg");
  background(0);
  widthCell = ((int)width) / maxRadius + 1;
  threads = new Threading[max(widthCell/4, 1)];
  heightCell = ((int)height) / maxRadius + 1;
  cells = new Cell[widthCell * heightCell];
  for (int i = 0; i < cells.length; i++) {
    cells[i] = new Cell(i);
  }
}

void draw() {
  if (!pause) {
    if (lastChange > 500 && init == null) {

      maxBalls = balls.size();
      pause = true;
      println(balls.size());
      noStroke();
      frameCount = 1;

      init = new PVector[balls.size()];
      for (int i = 0; i < init.length; i++) {
        init[i] = balls.get(i).pos;
      }
      showing = true;

      colors = new color[init.length];
      try {
        background(image);
      }
      catch (RuntimeException e) {
        image.resize(width, height);
        image(image, 0, 0);
      }
      loadPixels();
      for (int i = 0; i < colors.length; i++) {
        colors[i] = averageColor(i);
      }
      balls.clear();
      updateCells();
      fountainNb = startingFountainNb;
      speed = startingSpeed;
      lastChange = 0;
    }

    if (frameCount > 2500 && frameCount % 300 == 0) {
      fountainNb += 1;
      if (speed > .3) {
        //speed += -.2;
      }
    }
    if (init == null) {
      try {
        background(image);
      }
      catch (RuntimeException e) {
        image.resize(width, height);
        image(image, 0, 0);
      }
    } else {
      background(0);
    }
    for (int i = 0; i < fountainNb; i++) {
      if (init == null) {
        if (isAlright((int) widthCell/2 - fountainNb/2 + i) && !enoughBalls()) {
          int randR = (int) random(minRadius, maxRadius);
          balls.add(new Ball(randR, new PVector((widthCell/2 - fountainNb/2) * (maxRadius + .15) + i * (maxRadius + .1), maxRadius/1.2), new PVector(cos(frameCount / 150.), abs(sin(frameCount/150.))).mult(speed), balls.size(), color(0)));
          rand.add(randR);
          lastChange = 0;
        }
      } else {
        if (isAlright((int) widthCell/2 - fountainNb/2 + i) && !enoughBalls() && balls.size() < maxBalls) {
          balls.add(new Ball(rand.get(balls.size()), new PVector((widthCell/2 - fountainNb/2) * (maxRadius + .15) + i * (maxRadius + .1), maxRadius/1.2), new PVector(cos(frameCount / 150.), abs(sin(frameCount/150.))).mult(speed), balls.size(), colors[balls.size()]));
          lastChange = 0;
        }
      }
    }


    for (int i = 0; i < substeps; i++) {
      collision();
    }
    for (Ball b : balls) {
      if (showing) {
        b.show();
      }
      b.update();
    }
    lastChange++;
  } else {
    frameCount--;
  }
}

void collision() {
  for (Ball b : balls) {
    b.wallCollide();
  }
  updateCells();
  //first half to make it deterministic
  for (int i = 0; i < threads.length; i++) {
    threads[i] = new Threading((int) (i * (1. * widthCell/threads.length)), (int) (i *  (1. * widthCell/threads.length) + widthCell/(threads.length*2)), 1);
  }
  for (int i = 0; i < threads.length; i++) {
    threads[i].start();
  }
  try {
    for (int i = 0; i < threads.length; i++) {
      threads[i].join();
    }
  }
  catch (InterruptedException e) {
  }

  //second half
  for (int i = 0; i < threads.length; i++) {
    threads[i] = new Threading((int) (i * (1. * widthCell/threads.length) + widthCell/(threads.length*2)), (int)((i+1) *  (1. * widthCell/threads.length)), 2);
  }
  for (int i = 0; i < threads.length; i++) {
    threads[i].start();
  }
  try {
    for (int i = 0; i < threads.length; i++) {
      threads[i].join();
    }
  }
  catch (InterruptedException e) {
  }
}

boolean enoughBalls() {
  int sum = 0;
  for (Ball b : balls) {
    sum += b.radius/2 * b.radius/2 * 3.14;
  }
  return sum > width * height;
}

boolean isAlright(int fountain) {
  ArrayList<Cell> neighbours = cells[fountain].neighbours();
  for (Cell c : neighbours) {
    if (c.content.size() > 0) {
      return false;
    }
  }
  return true;
}

color averageColor(int i) {
  int r = 0;
  int g = 0;
  int b = 0;
  int count = 1;
  for (int x = -balls.get(i).radius/4; x < balls.get(i).radius/4; x++) {
    for (int y = -balls.get(i).radius/4; y < balls.get(i).radius/4; y++) {
      if ((int)balls.get(i).pos.x + x + width * ((int) balls.get(i).pos.y + y) > 0 && (int)balls.get(i).pos.x + x + width * ((int) balls.get(i).pos.y + y) < width * height) {
        r += red(pixels[(int)balls.get(i).pos.x + x + width * ((int) balls.get(i).pos.y + y)]);
        g += green(pixels[(int)balls.get(i).pos.x + x + width * ((int) balls.get(i).pos.y + y)]);
        b += blue(pixels[(int)balls.get(i).pos.x + x + width * ((int) balls.get(i).pos.y + y)]);
        count++;
      }
    }
  }
  return color(r/count, g/count, b/count);
}

void keyPressed() {
  if (key == 'p') {
    pause = !pause;
  } else if (key == 'e') {
    lastChange = 500;
  }
}
