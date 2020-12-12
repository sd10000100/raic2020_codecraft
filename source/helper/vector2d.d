 module helper.vector2d;
 import helper;
import std.math; 
import std.conv;


struct Vect2D (T) {
    alias Point = Point2D!T;
    Point start;
    Point finish;

    this(Point _start, Point _finish){
        this.start = _start;
        this.finish = _finish;
    }

    Point V() {
        return Point(finish.x - start.x, finish.y - start.y);
    }

   auto length() { return sqrt((start.x-finish.x)*(start.x-finish.x) + (start.y-finish.y)*(start.y-finish.y)); }


   void mult(double coeff) {
       finish.x = start.x + V().x * coeff;
       finish.y = start.y + V().y * coeff;
   }

    void turn(double angle)
    {
        double x = V().x * cos(angle) - V().y * sin(angle);
        double y = V().y * cos(angle) + V().x * sin(angle);
        finish.x = start.x + x;
        finish.y = start.y + y;
    }
}
