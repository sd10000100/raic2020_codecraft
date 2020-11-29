module helper.point2d;

import helper;
import std.math; 
import std.conv;

struct Point2D(T){
    T x,y;
    this(T x, T y) {this.x = x; this.y = y;}
    //pure nothrow 

    bool opEquals(Point2D v) {
        return v.x == x && v.y == y;
    }

    ref Point2D opAssign(Point2D p) {
        x = p.x;
        y = p.y;
        return this;
    }


    Point2D opUnary(string op)() if (op == "+" || op == "~") {
        return Point2D(mixin(op ~ "x"), mixin(op ~ "y"));
    }

    Point2D opBinary(string op)(Point2D v) if (op == "-" || op == "+" || op == "*") {
        return Point2D(mixin("v.x" ~ op ~ "x"), mixin("v.y" ~ op ~ "y"));
    }

    ref Point2D opOpAssign(string op)(Point2D v) if (op == "-" || op == "+" || op == "*" || op == "/") {
        auto t = Point2D(x, y);
        mixin("auto r = t" ~ op ~ "v;");
        x = r.x;
        y = r.y;
        return this;
    }

    Point2D opBinary(string op)(double a) if (op == "/") {
        return this*(1/a);
    }

    @property auto dist() {
        return cast(T) sqrt((x*x).to!double + (y*y).to!double);
    }

    Point2D normalize(T len) {
        return Point2D(x/len, y/len);
    }

    Point2D normalize() {
        return Point2D(x*1/dist(), y*1/dist());
    }

    auto distTo(T x_, T y_) {
        return cast(T) sqrt(((x-x_)*(x-x_) + (y-y_)*(y-y_)).to!double);
    }

    auto distTo(Point2D p) {
        return distTo(p.x, p.y);
    }


    // Point2D& operator/=(double a) {
    //     return (*this)*=(1/a) ;
    // }
}
