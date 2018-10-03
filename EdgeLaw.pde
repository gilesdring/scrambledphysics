abstract class EdgeLaw extends Law {
  float minX, minY, maxX, maxY;
  EdgeLaw(float x, float y, float w, float h) {
    super("Edge");
    minX = min(x, x+w); maxX = max(x, x+w);
    minY = min(y, y+h); maxY = max(y, y+h);
  }
  EdgeLaw() { this(0,0,width,height); }
}
