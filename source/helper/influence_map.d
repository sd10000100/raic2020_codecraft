module helper.influence_map;

import helper;
import std.math;
import std.conv;

class InfluenceMap (T){
    public: 
        T[][] infMap;
        int height;
        int width;

        auto array_generator(int _height,int _width) {
            auto matr = new double[][](_height,_width);
            foreach(ref rw ; matr){
                foreach(ref item ; rw){
                    item = 0.0;
                }
            }
            return matr;
        }     

        double signedMax(double a, double b){
            if(abs(a)>=abs(b)) return a;
            else return b;
        }

        double getSign(double x){
            if (x>0) return 1;
            else return -1;
        }

        double putp(double oldV, double newV){
            if(oldV==80) return 80;
            else if(oldV == 0) return newV;
            else return (oldV+newV)/2;
        }

        bool isCorrectCoordinate(int x, int y){
            if(x>=0 && x<this.width && y>=0 && y<this.height)
                return true;
            return false;
        }

    public: 
        @property nothrow pure double[][] Map() { return infMap; }
        @property nothrow pure int Height() { return height; }
        @property nothrow pure int Width() { return width; }

        this(int _height,int _width){
            this.height = _height;
            this.width = _width;
            infMap = array_generator(_height,_width);
        }

        Point2D!T[] GetNearest(Point2D!T p){
            Point2D!T[] res;
            res~=Point2D!T(p.x + 1, p.y);
            res~=Point2D!T(p.x - 1, p.y);
            res~=Point2D!T(p.x, p.y + 1);
            res~=Point2D!T(p.x, p.y - 1);

            foreach (Point2D!T point ; res)
            {
                // Проверяем, что не вышли за границы карты.
                if (point.x < 0 || point.x >= height)
                    continue;
                if (point.y < 0 || point.y >= width)
                    continue;
                result~=neighbourNode;
            }
            return res;
        }

        bool IsNearestAnyEmpty(Point2D!T p, T emptyVal){
            Point2D!T[] res;
            res~=Point2D!T(p.x + 1, p.y);
            res~=Point2D!T(p.x - 1, p.y);
            res~=Point2D!T(p.x, p.y + 1);
            res~=Point2D!T(p.x, p.y - 1);

            foreach (Point2D!T point ; res)
            {
                // Проверяем, что не вышли за границы карты.
                if (point.x < 0 || point.x >= height)
                    continue;
                if (point.y < 0 || point.y >= width)
                    continue;
                if( infMap[point.y][point.x]==emptyVal)
                    return true;
            }
            return false;
        }
        
        void PutPotential(double power, double step, Point2D!T p)
        {
            double s = 0;
            int x = (abs(floor((p.x).to!double))).to!int;
            int y = (abs(floor((p.y).to!double))).to!int;
            for(double l = 0;l<fabs(power);l=l+step, s++)
            {
                for(int temp = (y-s).to!int;temp<=s+y;temp++)
                {
                    int tempArrMinX = (floor(x-s)).to!int;
                    int tempArrMaxX = (floor(x+s)).to!int;
                    if(isCorrectCoordinate(tempArrMinX, temp))
                        infMap[temp][tempArrMinX]=signedMax(infMap[temp][tempArrMinX],getSign(power)*(abs(power)-l));
                    if(isCorrectCoordinate(tempArrMaxX, temp))
                        infMap[temp][tempArrMaxX]=signedMax(infMap[temp][tempArrMaxX],getSign(power)*(abs(power)-l));
                }
                for(int temp = (x-s+1).to!int;temp<=s+x-1;temp++)
                {
                    int tempArrMinY = (floor(y-s)).to!int;
                    int tempArrMaxY = (floor(y+s)).to!int;
                    if(isCorrectCoordinate(temp, tempArrMinY))
                        infMap[tempArrMinY][temp]=signedMax(infMap[tempArrMinY][temp],getSign(power)*(abs(power)-l));
                    if(isCorrectCoordinate(temp, tempArrMaxY))
                        infMap[tempArrMaxY][temp]=signedMax(infMap[tempArrMaxY][temp],getSign(power)*(abs(power)-l));
                }
            }
        }

        void PutAvgPotential(T)(double power, double step,  Point2D!T p, double wall=80)
        {
            double s = 0;
            int x = (abs(floor((p.x).to!double))).to!int;
            int y = (abs(floor((p.y).to!double))).to!int;
            for(double l = 0;l<fabs(power);l=l+step, s++)
            {
                for(int temp = (y-s).to!int;temp<=s+y;temp++)
                {
                    int tempArrMinX = (floor(x-s)).to!int;
                    int tempArrMaxX = (floor(x+s)).to!int;
                    if(isCorrectCoordinate(tempArrMinX, temp) && infMap[temp][tempArrMinX]<wall)
                        infMap[temp][tempArrMinX]=putp(infMap[temp][tempArrMinX],getSign(power)*(abs(power)-l));
                    if(isCorrectCoordinate(tempArrMaxX, temp) && infMap[temp][tempArrMaxX]<wall)
                        infMap[temp][tempArrMaxX]=putp(infMap[temp][tempArrMaxX],getSign(power)*(abs(power)-l));
                }
                for(int temp = (x-s+1).to!int;temp<=s+x-1;temp++)
                {
                    int tempArrMinY = (floor(y-s)).to!int;
                    int tempArrMaxY = (floor(y+s)).to!int;
                    if(isCorrectCoordinate(temp, tempArrMinY) && infMap[tempArrMinY][temp]<wall)
                        infMap[tempArrMinY][temp]=putp(infMap[tempArrMinY][temp],getSign(power)*(abs(power)-l));
                    if(isCorrectCoordinate(temp, tempArrMaxY) && infMap[tempArrMaxY][temp]<wall)
                        infMap[tempArrMaxY][temp]=putp(infMap[tempArrMaxY][temp],getSign(power)*(abs(power)-l));
                }
            }
        }

        //TODO: пофиксить это убожество
        double getSumOfVectorOnInfluenseMap(T)(Point2D!T fromV, Point2D!T toV, double wall=80){
            double sum = 0;
            int sqareStartX =  fmin(floor(fromV.x.to!double).to!int, floor(toV.x.to!double).to!int).to!int;
            int sqareFinishX = fmax(ceil(fromV.x.to!double).to!int,ceil(toV.x.to!double).to!int).to!int;
            int sqareStartY = fmin(floor(fromV.y.to!double).to!int,floor(toV.y.to!double).to!int).to!int;
            int sqareFinishY = fmax(ceil(fromV.y.to!double).to!int,ceil(toV.y.to!double).to!int).to!int;

            for(int i = sqareStartX; i<=sqareFinishX;i++)
            {
                for(int j = sqareStartY; j<=sqareFinishY;j++) {
                    if (isCorrectCoordinate(i, j) && (
                            intersect(fromV, toV, Point2D!T(size_t(i), size_t(j)), Point2D!T(size_t(i), size_t(j) + 1))
                            ||
                            intersect(fromV, toV, Point2D!T(size_t(i), size_t(j)), Point2D!T(size_t(i) + 1, size_t(j)))
                            ||
                            intersect(fromV, toV, Point2D!T(size_t(i) + 1, size_t(j)), Point2D!T(size_t(i) + 1, size_t(j) + 1))
                            ||
                            intersect(fromV, toV, Point2D!T(size_t(i), size_t(j) + 1), Point2D!T(size_t(i) + 1, size_t(j) + 1))
                    )) {
                        sum += infMap[j][i];
                    }
                    else if(!isCorrectCoordinate(i, j))
                    {sum +=wall;}
                }
            }
            return sum;
        }

        Point2D!T GetMinPotentialByRadius(T)(int radius, Point2D!T source) {
            double min = 10000;
            Point2D!T minPos = source;

            int x = (abs(floor((source.x).to!double))).to!int;
            int y = (abs(floor((source.y).to!double))).to!int;

            for (int temp = y-radius+1; temp < y+radius; temp++) {
                int minX = x-radius;
                int maxX = x+radius;
                double minSum = getSumOfVectorOnInfluenseMap(source, Point2D!T (minX,temp));
                double maxSum = getSumOfVectorOnInfluenseMap(source, Point2D!T (maxX,temp));
                if(minSum<min)
                {
                    min = minSum;
                    minPos.x = minX;
                    minPos.y = temp;
                }
                if(maxSum<min)
                {
                    min = maxSum;
                    minPos.x = maxX;
                    minPos.y = temp;
                }
            }
            for (int temp = x-radius+1; temp < x+radius; temp++) {
                int minY = y-radius;
                int maxY = y+radius;
                double minSum = getSumOfVectorOnInfluenseMap(source, Point2D!T (temp,minY));
                double maxSum = getSumOfVectorOnInfluenseMap(source, Point2D!T (temp,maxY));
                if(minSum<min)
                {
                    min = minSum;
                    minPos.x = temp;
                    minPos.y = minY;
                }
                if(maxSum<min)
                {
                    min = maxSum;
                    minPos.x = temp;
                    minPos.y = maxY;
                }
            }
            return minPos;

        }

}