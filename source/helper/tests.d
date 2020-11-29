module helper.tests;
import helper;

import std.stdio;

unittest{

    auto p = Point2D!double(1,2);

    auto p11 = Point2D!double(1,2);
    auto p22 = Point2D!double(3,4);
    auto p33 = p11+p22;
    writeln(p33.dist());
    assert(p33.x != 4);
    assert(p33.y == 6);
    p33+=p11;


//     auto a = Point2D!double(0,0);
//         auto b = Point2D!double(4,0);
//         auto v = Vect2D!(double)(a,b);
//     v.turn(3.14159/2);


// auto ggg = array_generator(10,10);
// PutPotential!double(3,1,ggg,10,10,a);
// PutAvgPotential!double(6.5, 0.5, ggg, 10,10, b);
// for(int i=0;i<10;i++){
//     // for(int j=0;j<5;j++){
//     // write((ggg[i][j]).to!string~" ");
//     // }
//     writeln(ggg[i]);
// }


}