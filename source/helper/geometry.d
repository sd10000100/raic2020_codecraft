 module helper.geometry;
 import helper;
 import std.algorithm;

// расстояние между 2-мя точками
auto distanceSqr(T)(Point2D!T a, Point2D!T b) {
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}

// ориентированная площадь треугольника
// Исп-я понятие косого (псевдополяр) произвед векторов
// a ^ b = |a||b|sin(<(a,b))=2S
// угол вращения между векторами против часовой стрелки
// 2s=|x1 y1 1|
//    |x2 y2 1|=(x2-x1)(y3-y1)-(y2-y1)(x3-x1)
//    |x3 y3 1|
auto OrientedArea(T) (Point2D!T a, Point2D!T b, Point2D!T c) {
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

// проверка, что точки не лежат на одной плоскости
bool isPointNotOnSamePlane(T) (T a, T b, T c, T d) {
    if (a > b) swap(a, b);
    if (c > d) swap(c, d);
    return max(a, c) <= min(b, d);
}

// Чтобы отрезки AB и CD пересекались, нид чтобы A и B находились
// по разные стороны от прямой CD и аналогично C и D по разные стороны от AB
// Нужно вычислить ориентированные площади треугольников и сравнить знаки
bool intersect(T) (Point2D!T a, Point2D!T b, Point2D!T c, Point2D!T d) {
    return isPointNotOnSamePlane (a.x, b.x, c.x, d.x)
           && isPointNotOnSamePlane (a.y, b.y, c.y, d.y)
           && OrientedArea(a,b,c) * OrientedArea(a,b,d) <= 0
           && OrientedArea(c,d,a) * OrientedArea(c,d,b) <= 0;
}

// Only for CodeSide
bool intersect (T)(Vect2D!T a, Vect2D!T b, Vect2D!T c, Vect2D!T d) {
    alias Point2D = Point2D!T;
    return isPointNotOnSamePlane (a.x, b.x, c.x, d.x)
           && isPointNotOnSamePlane (a.y, b.y, c.y, d.y)
           && OrientedArea(Point2D(a.x,a.y),
                           Point2D(b.x,b.y),
                           Point2D(c.x,c.y))
                           *
              OrientedArea(Point2D(a.x,a.y),
                           Point2D(b.x,b.y),
                           Point2D(d.x,d.y)) <= 0
           && OrientedArea(Point2D(c.x,c.y),
                           Point2D(d.x,d.y),
                           Point2D(a.x,a.y))
                           *
              OrientedArea(Point2D(c.x,c.y),
                           Point2D(d.x,d.y),
                           Point2D(b.x,b.y)) <= 0;
}

// проверка на нахождение точки внутри треугольника (подходит для выпуклых многоугольников)
// Проверяем каждую грань на пересечение с лучом из искомой точки (луч в рандомное место)
// Если кол-во перемещений кратно 2-м - точка не в многоугольнике
// инеаче - внутри
// Примеч: можно случайно попасть на стык ребер - решается выбором луча поизощреннее

bool isPointInTriangle(T)(Vect2D!T p, Vect2D!T p1, Vect2D!T p2,Vect2D!T p3){
    alias Point2D = Point2D!T;
    alias Vec2D = Vect2D!T;

    Vec2D[] stackEnges;
    int countIntersect = 0;
    stackEnges+=Vec2D(Point2D(p1.x,p1.y),Point2D(p2.x,p2.y));
    stackEnges+=Vec2D(Point2D(p2.x,p2.y),Point2D(p3.x,p3.y));
    stackEnges+=Vec2D(Point2D(p3.x,p3.y),Point2D(p1.x,p1.y));

    foreach(Vec2D item; stackEnges)
    {
        if(intersect (Point2D(p.x,p.y), Point2D(10000,1), item.start, item.finish))
            countIntersect++;
    }
    if(countIntersect%2==0)
        return false;
    else {
        return true;
    }
}

