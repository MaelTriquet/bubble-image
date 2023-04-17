class Threading extends Thread {
  int start;
  int stop;
  int nb;

  Threading(int start_, int stop_, int nb_) {
    start = start_;
    stop = stop_;
    nb = nb_;
  }
  void run() {
    for (int i = start; i < stop; i++) {
      for (int j = 0; j < heightCell; j++) {
        ArrayList<Cell> neighbours = cells[i + widthCell * j].neighbours();
        for (Cell c2 : neighbours) {
          cells[i + widthCell * j].collide(c2);
        }
        //fill(255, 0, 0);
        //if (nb == 2) {
        //  fill(0, 255, 0);
        //}
        //rect(i * maxRadius, j * maxRadius, maxRadius, maxRadius);
      }
    }
  }
}
