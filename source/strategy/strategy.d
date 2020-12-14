module strategy.strategy;
import debug_interface;
import std.random;
public import model;
public import helper;
import std.typecons;
import std.conv;
import std.algorithm;
import std.stdio;


// untouchable - это пока не трогаю

struct EntityBuilder{
    Vec2Int position;
    bool isBuild = false;
    bool started = false;
    Vec2Int BuildPosition;
    int id;
}

struct BuildItem {
    EntityType typeByild;
    Vec2Int position;
    int builderId;
    int itemid;
    bool isBuilding = false;
    bool started = false;
    

    this(EntityType typeByild,Vec2Int position, int itemid = -1){
        this.typeByild = typeByild;
        this.position = position;
        this.itemid = itemid;
    }

}

class Strategy{
    BuildItem[] buildQueue;
    EntityBuilder[int] builders;
    Vec2Int[int] attackers;

    int idBuilder = -1;
    int tempBuilder = -1;
    int oldhouseCount = 0; 
    int myId;
    
    this(){
         buildQueue = [];

buildQueue~=BuildItem(EntityType.BuilderBase, Vec2Int(5,5));
buildQueue~=BuildItem(EntityType.RangedBase, Vec2Int(15,5));

buildQueue~=BuildItem(EntityType.Turret, Vec2Int(15,15));


buildQueue~=BuildItem(EntityType.House, Vec2Int(5,11));
buildQueue~=BuildItem(EntityType.House, Vec2Int(9,11));
buildQueue~=BuildItem(EntityType.House, Vec2Int(13,11));
buildQueue~=BuildItem(EntityType.MeleeBase, Vec2Int(5,15));

buildQueue~=BuildItem(EntityType.House, Vec2Int(17,11));

buildQueue~=BuildItem(EntityType.Turret, Vec2Int(15,18));

buildQueue~=BuildItem(EntityType.House, Vec2Int(11,15));
buildQueue~=BuildItem(EntityType.House, Vec2Int(11,7));

buildQueue~=BuildItem(EntityType.House, Vec2Int(1,1));
buildQueue~=BuildItem(EntityType.House, Vec2Int(1,5));
buildQueue~=BuildItem(EntityType.House, Vec2Int(1,9));
buildQueue~=BuildItem(EntityType.House, Vec2Int(1,13));
buildQueue~=BuildItem(EntityType.House, Vec2Int(1,17));

buildQueue~=BuildItem(EntityType.Turret, Vec2Int(18,15));

buildQueue~=BuildItem(EntityType.House, Vec2Int(5,1));
buildQueue~=BuildItem(EntityType.House, Vec2Int(9,1));
buildQueue~=BuildItem(EntityType.House, Vec2Int(13,1));
buildQueue~=BuildItem(EntityType.House, Vec2Int(17,1));
buildQueue~=BuildItem(EntityType.House, Vec2Int(21,1));
buildQueue~=BuildItem(EntityType.House, Vec2Int(21,5));
buildQueue~=BuildItem(EntityType.House, Vec2Int(21,9));
buildQueue~=BuildItem(EntityType.House, Vec2Int(21,13));
buildQueue~=BuildItem(EntityType.House, Vec2Int(21,17));

buildQueue~=BuildItem(EntityType.House, Vec2Int(21,21));

buildQueue~=BuildItem(EntityType.House, Vec2Int(1,21));
buildQueue~=BuildItem(EntityType.House, Vec2Int(5,21));
buildQueue~=BuildItem(EntityType.House, Vec2Int(9,21));
buildQueue~=BuildItem(EntityType.House, Vec2Int(13,21));
buildQueue~=BuildItem(EntityType.House, Vec2Int(17,21));

buildQueue~=BuildItem(EntityType.House, Vec2Int(25,1));
buildQueue~=BuildItem(EntityType.House, Vec2Int(25,5));
buildQueue~=BuildItem(EntityType.House, Vec2Int(25,9));
buildQueue~=BuildItem(EntityType.House, Vec2Int(25,13));
buildQueue~=BuildItem(EntityType.House, Vec2Int(25,17));
buildQueue~=BuildItem(EntityType.House, Vec2Int(25,21));

buildQueue~=BuildItem(EntityType.House, Vec2Int(1,25));
buildQueue~=BuildItem(EntityType.House, Vec2Int(5,25));
buildQueue~=BuildItem(EntityType.House, Vec2Int(9,25));
buildQueue~=BuildItem(EntityType.House, Vec2Int(13,25));
buildQueue~=BuildItem(EntityType.House, Vec2Int(17,25));
buildQueue~=BuildItem(EntityType.House, Vec2Int(21,25));

buildQueue~=BuildItem(EntityType.House, Vec2Int(25,25));

buildQueue~=BuildItem(EntityType.House, Vec2Int(29,1));
buildQueue~=BuildItem(EntityType.House, Vec2Int(29,5));
buildQueue~=BuildItem(EntityType.House, Vec2Int(29,9));
buildQueue~=BuildItem(EntityType.House, Vec2Int(29,13));
buildQueue~=BuildItem(EntityType.House, Vec2Int(29,17));
buildQueue~=BuildItem(EntityType.House, Vec2Int(29,21));
buildQueue~=BuildItem(EntityType.House, Vec2Int(29,25));

buildQueue~=BuildItem(EntityType.House, Vec2Int(1,29));
buildQueue~=BuildItem(EntityType.House, Vec2Int(5,29));
buildQueue~=BuildItem(EntityType.House, Vec2Int(9,29));
buildQueue~=BuildItem(EntityType.House, Vec2Int(13,29));
buildQueue~=BuildItem(EntityType.House, Vec2Int(17,29));
buildQueue~=BuildItem(EntityType.House, Vec2Int(21,29));
buildQueue~=BuildItem(EntityType.House, Vec2Int(25,29));

buildQueue~=BuildItem(EntityType.House, Vec2Int(29,29));
    }

    bool is_unit(EntityType type){
        int t = type.to!int;
        switch(t) {
        case 3,5,7:
            return true;
        default: // if nothing else matches
            return false;
        }
    }
    bool is_building(EntityType type){
        int t = type.to!int;
        switch(t) {
        case 0,1,2,4,6,9:
            return true;
        default: // if nothing else matches
            return false;
        }
    }

    bool IsPlaceEmptyForHouse(PlayerView playerView, Vec2Int p, int identity, int size)
    {
        foreach (entity; playerView.entities) {
            if(p.x<entity.position.x && p.x+size>entity.position.x && p.y<entity.position.y && p.y+size>entity.position.y)
                return false;
        }
        return true;
    }

    

    Action calculateAction(PlayerView playerView, DebugInterface debugInterface){

               


        Action action;
        myId = playerView.myId;
        
     
        Nullable!(BuildAction) buildAction = Nullable!(BuildAction).init;
        Nullable!(AttackAction) attackAction = Nullable!(AttackAction).init;
        Nullable!(RepairAction) repairAction = Nullable!(RepairAction).init;


        int[int]  playersU;

        //TODO: Может выкинуть?
        bool isBuildUnitChecked = false;
        bool isBuildBaseChecked = false;
        bool isHouseIsBuilding = false;


        int repairCounts = 0;
        int rangeCount = 0;
        int buildCount = 0;
        int houseCount = 0;
        int finalhouseCount = 0;
        int unitCount = 0;
        int resCount = 0;
        int turretCount = 0;
        int meleeCount = 0;
               
        foreach (player; playerView.players)
        {
            if (player.id==myId)
            {
                resCount = player.resource;
            }
            else{
                playersU[player.id] = 0;
            }
        }
        
        foreach (enemyEntity; playerView.entities) {
            if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get==myId) {
                if (enemyEntity.entityType == EntityType.BuilderUnit)
                    {
                        buildCount++;
                        if (buildCount>=3 && builders.length<3 && !(enemyEntity.id in builders) )
                        {
                            EntityBuilder b = EntityBuilder();
                            b.position = enemyEntity.position;
                            b.isBuild = false;
                            b.started = false;
                            b.BuildPosition = Vec2Int(0,0);
                            b.id = enemyEntity.id;
                            builders[enemyEntity.id] = b;
                         //   writeln(enemyEntity.id);
                        }


                    }
                if (enemyEntity.entityType == EntityType.RangedUnit)
                    rangeCount++;
                if (enemyEntity.entityType == EntityType.MeleeUnit)
                    meleeCount++;
                if (enemyEntity.entityType == EntityType.House)
                    {houseCount++;
                    

                    if(enemyEntity.active)
                        finalhouseCount++;
                        
                 
                        
                    }
                if (enemyEntity.entityType ==3 || enemyEntity.entityType ==5 || enemyEntity.entityType ==7)
                    {
                        unitCount++;
                        
                    }
                if (enemyEntity.entityType ==9)
                    turretCount++;
                if(is_building(enemyEntity.entityType)){

                    //    foreach(key, buil ; builders)
                    // {
                    //    // writeln(buil.id.to!string~ " "~buil.isBuild.to!string~ " "~buil.BuildPosition.x.to!string~ " "~enemyEntity.position.x.to!string~ " "~buil.isBuild.to!string);
                    //     //writeln(buil.id.to!string~ " "~buil.isBuild.to!string);
                    //     if(buil.BuildPosition.x==enemyEntity.position.x && buil.BuildPosition.y==enemyEntity.position.y && buil.isBuild==true)
                    //     {
                    //         //writeln(buil.id.to!string~ " "~buil.isBuild.to!string~ " "~buil.BuildPosition.x.to!string~ " "~enemyEntity.position.x.to!string~ " "~buil.isBuild.to!string);
                    //         builders[key].BuildPosition = Vec2Int(0,0);
                    //         builders[key].isBuild = false;
                    //         builders[key].started = false;
                    //         //writeln(buil.id.to!string~ " "~buil.isBuild.to!string~ " "~buil.BuildPosition.x.to!string~ " "~enemyEntity.position.x.to!string);
                    //     }
                    // }



                     int[] todel = [];
                    for(int g=0;g<buildQueue.length;g++){
                        if(enemyEntity.position.x == buildQueue[g].position.x && enemyEntity.position.y == buildQueue[g].position.y)
                        {
                            todel~=g;
                        }
                    }
                    foreach(tod ; todel)
                    {
                        buildQueue.remove(tod);
                    }
                }
            }
            else if(!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId)
            {
                if (enemyEntity.entityType == 3 || enemyEntity.entityType == 5 || enemyEntity.entityType == 7)
                {
                    playersU[enemyEntity.playerId.get]++;
                }
            }
        }

        int MyArmyMax = 15+finalhouseCount*5;
        int MinUnitPlayers = 10000;
        int MinUnitPlayerId = 0;
        int i = 0;
        int j = 0;
        int k = 0;
                
        foreach (pl, vpl; playersU)
        {
            if(vpl<MinUnitPlayers)
            {
                MinUnitPlayers = vpl;
                MinUnitPlayerId = pl;
            }
        }


        int RangedCost = playerView.entityProperties[EntityType.RangedUnit].buildScore + rangeCount;

        int meleeCost = playerView.entityProperties[EntityType.MeleeUnit].buildScore + meleeCount;
        int houseCost = playerView.entityProperties[EntityType.House].buildScore;

        foreach (entity; playerView.entities) {
            int countRes = playerView.entityProperties[EntityType.RangedUnit].buildScore +rangeCount;
            if(!entity.playerId.isNull() && entity.playerId.get==myId){

                // foreach (baseEntity; playerView.entities) {
                //         if (!baseEntity.playerId.isNull() && baseEntity.playerId.get==myId) {
                //             if ((baseEntity.entityType==9 || baseEntity.entityType==1 ) && baseEntity.active==false){
                //                 idBuilder = -1;
                //                 isHouseIsBuilding = false;
                //             }
                //         }
                // }


                // untouchable
				if(entity.entityType ==5 || entity.entityType ==7)//если вояка
                {
                    Nullable!Entity nearestEnemy;

                    foreach (enemyEntity; playerView.entities) {
                        if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId) {
                            if (nearestEnemy.isNull() ||
                                    distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <
                                        distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestEnemy.get.position.x, nearestEnemy.get.position.y))
                            
                                    ) {
                                nearestEnemy = enemyEntity;
                            }
                        }
                    }

                    if(!nearestEnemy.isNull()){
                        Nullable!(AutoAttack) autoattack = AutoAttack(20, [EntityType.BuilderUnit, EntityType.MeleeUnit, 
                                                                        EntityType.RangedUnit, EntityType.Turret,
                                                                        EntityType.Wall,EntityType.House,EntityType.BuilderBase,
                                                                        EntityType.MeleeBase,EntityType.RangedBase]);
                        Nullable!int enemyid = nearestEnemy.get().id;
                        attackAction = AttackAction(enemyid,autoattack);
                        Nullable!(MoveAction) moveAction = MoveAction(nearestEnemy.get.position, true,true);//Vec2Int(40,40)
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        attackers.remove(entity.id);
                    }
                    else if(!(entity.id in attackers) || (attackers[entity.id].x==entity.position.x && attackers[entity.id].y==entity.position.y))
                    {
                        int randx = uniform(0, 80);int randy = uniform(0, 80);
                        Nullable!(AutoAttack) autoattack = AutoAttack(20, [EntityType.BuilderUnit, EntityType.MeleeUnit, 
                                                                        EntityType.RangedUnit, EntityType.Turret,
                                                                        EntityType.Wall,EntityType.House,EntityType.BuilderBase,
                                                                        EntityType.MeleeBase,EntityType.RangedBase]);
                        attackAction = AttackAction(Nullable!int.init,autoattack);
                        Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(randx, randy), true,false);
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        attackers[entity.id] = Vec2Int(randx, randy);
                    }
                }
                else if (entity.entityType ==3)//  && isHouseIsBuilding==false
                {
                    //i++;
                    Nullable!Entity newBase;
                    foreach (newbase; playerView.entities) {
                        if (!newbase.playerId.isNull() && newbase.playerId.get==myId && (is_building(newbase.entityType))) {
                            if(newbase.health<playerView.entityProperties[newbase.entityType].maxHealth){
                                if(newBase.isNull() || distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(newbase.position.x, newbase.position.y)) <
                                        distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(newBase.get.position.x, newBase.get.position.y)))
                                            newBase = newbase;
                                    }
                        }//&& !(entity.id in builders)
                    }//(((entity.id in builders)  && builders[entity.id].BuildPosition.x==newBase.get.position.x && builders[entity.id].BuildPosition.y==newBase.get.position.y )||
                    if(!newBase.isNull()  && j<max(min(resCount/RangedCost, 12),3) )//                    if(!newBase.isNull() && (((entity.id in builders)  && builders[entity.id].BuildPosition.x==newBase.get.position.x && builders[entity.id].BuildPosition.y==newBase.get.position.y )|| j<max(min(resCount/RangedCost, 12),3) ))
                    {        
                        Nullable!(MoveAction) moveAction = MoveAction(newBase.get.position, true,false);
                        repairAction = RepairAction(newBase.get.id);
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        repairCounts++;
                        j++;
                    } 
                    else {
                        if(entity.id in builders){
                            
                              
                            if(resCount>houseCost){ //&& builders[entity.id].isBuild==false
                            int newHouseX = 0;
                            int newHouseY  =0;
                            EntityType tpe = EntityType.House;
                           //TODO: 
                           int l = 0;
                           while(l<buildQueue.length && (!IsPlaceEmptyForHouse(playerView, buildQueue[l].position,entity.id, playerView.entityProperties[buildQueue[l].typeByild].size) )
                            )
                           {
                                l++;

                           }
                           newHouseX = buildQueue[l].position.x;
                                newHouseY = buildQueue[l].position.y;
                                tpe = buildQueue[l].typeByild;
                                //buildQueue[l].started=true;
                           if(l==buildQueue.length){
                               newHouseX = 5+(houseCount+1-11)*4;//100;
                               newHouseY = 1;//0;
                           }
                                    //debugInterface.send(model.DebugCommand.Add(new Primitives([ColoredVertex(worldPos,Vec2Float(0,0),Color(100,0,0,0.5)),ColoredVertex(worldPos,Vec2Float(0,0),Color(100,0,0,0.5))], PrimitiveType.Lines)));
                    

                                //     auto debugCommand1 = new  DebugCommand.Add(new DebugData.Log("go to build"));
                                // debugInterface.send(debugCommand1);
                                    buildAction = BuildAction(tpe, Vec2Int(newHouseX,newHouseY) );
                                    Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(newHouseX,newHouseY), true,false);
                                    EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                    action.entityActions[entity.id]=ent_act;
                                    resCount-=houseCost;
                                    // isBuildBaseChecked = true;
                                    // isHouseIsBuilding = true;
                                    // idBuilder = entity.id;
                                    //builders[entity.id].BuildPosition = Vec2Int(newHouseX,newHouseY);
                                    builders[entity.id].started = true;
                                    //builders[entity.id].isBuild = true;
                                    k++;
                            }
                            else {//if (builders[entity.id].isBuild==false)
                                Nullable!Entity nearestResource;
                                foreach (resourceEntity; playerView.entities) {
                                    if (resourceEntity.entityType ==8) {                                    
                                        if (nearestResource.isNull() ||
                                            distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(resourceEntity.position.x, resourceEntity.position.y)) <
                                                distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestResource.get.position.x, nearestResource.get.position.y))) {
                                            nearestResource = resourceEntity;
                                        }
                                    }
                                }
                                if (!nearestResource.isNull()){
                                    Vec2Int target = nearestResource.get.position;
                                    Nullable!(AutoAttack) autoattack = AutoAttack(60, [EntityType.Resource, EntityType.BuilderUnit]);

                                    Nullable!(MoveAction) moveAction = MoveAction(target, true,false);
                                    attackAction = AttackAction(Nullable!int.init,autoattack);
                                    EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                    action.entityActions[entity.id]=ent_act;
                                }
                                else if(!(entity.id in attackers) || (attackers[entity.id].x==entity.position.x && attackers[entity.id].y==entity.position.y))
                                {
                                    int randx = uniform(0, 80);int randy = uniform(0, 80);
                                    Nullable!(AutoAttack) autoattack = AutoAttack(20, [EntityType.BuilderUnit, EntityType.MeleeUnit, 
                                                                                    EntityType.RangedUnit, EntityType.Turret,
                                                                                    EntityType.Wall,EntityType.House,EntityType.BuilderBase,
                                                                                    EntityType.MeleeBase,EntityType.RangedBase]);
                                    attackAction = AttackAction(Nullable!int.init,autoattack);
                                    Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(randx, randy), true,false);
                                    EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                    action.entityActions[entity.id]=ent_act;
                                    attackers[entity.id] = Vec2Int(randx, randy);
                                }
                            }
                        }
                        else{
                            Nullable!Entity nearestResource;
                            foreach (resourceEntity; playerView.entities) {
                                if (resourceEntity.entityType ==8) {                                    
                                    if (nearestResource.isNull() ||
                                        distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(resourceEntity.position.x, resourceEntity.position.y)) <
                                            distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestResource.get.position.x, nearestResource.get.position.y))) {
                                        nearestResource = resourceEntity;
                                    }
                                }
                            }
                            if (!nearestResource.isNull()){
                                Vec2Int target = nearestResource.get.position;
                                Nullable!(AutoAttack) autoattack = AutoAttack(60, [EntityType.Resource, EntityType.BuilderUnit]);

                                Nullable!(MoveAction) moveAction = MoveAction(target, true,false);
                                attackAction = AttackAction(Nullable!int.init,autoattack);
                                EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                action.entityActions[entity.id]=ent_act;
                            }
                            else
                            {
                                Nullable!Entity nearestEnemy;
                                foreach (enemyEntity; playerView.entities) {
                                    if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId) {
                                        if (nearestEnemy.isNull() ||
                                                distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <
                                                    distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestEnemy.get.position.x, nearestEnemy.get.position.y))
                                        
                                                ) {
                                            nearestEnemy = enemyEntity;
                                        }
                                    }
                                }

                                if(!nearestEnemy.isNull()){
                                    Nullable!(AutoAttack) autoattack = AutoAttack(20, [EntityType.BuilderUnit, EntityType.MeleeUnit, 
                                                                                    EntityType.RangedUnit, EntityType.Turret,
                                                                                    EntityType.Wall,EntityType.House,EntityType.BuilderBase,
                                                                                    EntityType.MeleeBase,EntityType.RangedBase]);
                                    Nullable!int enemyid = nearestEnemy.get().id;
                                    attackAction = AttackAction(enemyid,autoattack);
                                    Nullable!(MoveAction) moveAction = MoveAction(nearestEnemy.get.position, true,true);
                                    EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                    action.entityActions[entity.id]=ent_act;
                                }
                                else if(!(entity.id in attackers) || (attackers[entity.id].x==entity.position.x && attackers[entity.id].y==entity.position.y))
                                {
                                    int randx = uniform(0, 80);int randy = uniform(0, 80);
                                    Nullable!(AutoAttack) autoattack = AutoAttack(20, [EntityType.BuilderUnit, EntityType.MeleeUnit, 
                                                                                    EntityType.RangedUnit, EntityType.Turret,
                                                                                    EntityType.Wall,EntityType.House,EntityType.BuilderBase,
                                                                                    EntityType.MeleeBase,EntityType.RangedBase]);
                                    attackAction = AttackAction(Nullable!int.init,autoattack);
                                    Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(randx, randy), true,false);
                                    EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                    action.entityActions[entity.id]=ent_act;
                                    attackers[entity.id] = Vec2Int(randx, randy);
                                }
                            }
                        }
                    }
                }
                else if (entity.entityType ==EntityType.RangedBase){
                    if (RangedCost<=meleeCost*2 && (RangedCost<resCount) )
                    {
                        int size = playerView.entityProperties[EntityType.RangedBase].size;
                        buildAction = BuildAction(EntityType.RangedUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        resCount-=RangedCost;
                        isBuildUnitChecked = true;
                    }
                    else 
                    {
                        action.entityActions[entity.id]=EntityAction(Nullable!(MoveAction).init, Nullable!(BuildAction).init, Nullable!(AttackAction).init, Nullable!(RepairAction).init);
                    }
                    

                }
                else if(entity.entityType ==EntityType.MeleeBase){
                    if (resCount>meleeCost  && meleeCost<RangedCost*2)
                    {
                        int size = playerView.entityProperties[EntityType.MeleeBase].size;
                        buildAction = BuildAction(EntityType.MeleeUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        resCount-=meleeCost;
                        isBuildUnitChecked = true;
                    }
                    else 
                    {
                        action.entityActions[entity.id]=EntityAction(Nullable!(MoveAction).init, Nullable!(BuildAction).init, Nullable!(AttackAction).init, Nullable!(RepairAction).init);
                    }
                }
                
                else if (entity.entityType ==EntityType.BuilderBase){
                    int countBuilderUnit = playerView.entityProperties[EntityType.BuilderUnit].buildScore;
                    
                    if (resCount>countBuilderUnit && buildCount<10+houseCount*2)
                    {
                        int size = playerView.entityProperties[EntityType.BuilderBase].size;
                        buildAction = BuildAction(EntityType.BuilderUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        //resCount-=countBuilderUnit;
                        isBuildUnitChecked = true;
                    }
                    else if (buildCount>=10+houseCount*2)
                    {
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, Nullable!(BuildAction).init, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                    }
                }
                else if (entity.entityType ==EntityType.Turret){
                    Nullable!(AutoAttack) autoattack = AutoAttack(20, [EntityType.RangedUnit, EntityType.MeleeUnit, EntityType.BuilderUnit]);
                    attackAction = AttackAction(Nullable!int.init,autoattack);
                    EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                    action.entityActions[entity.id]=ent_act;
                }
			}
        }
        return action;
    }

}