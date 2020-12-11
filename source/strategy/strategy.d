module strategy.strategy;
import std.random;
public import model;
public import helper;
import std.typecons;
import std.conv;


auto distanceSqr2(Vec2Int a, Vec2Int b) {
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}


struct BuildItem {
    EntityType typeByild;
    Vec2Int position;
    int builderId;

    this(EntityType typeByild,Vec2Int position, int builderId = -1){
        this.typeByild = typeByild;
        this.position = position;
        this.builderId = builderId;
    }

}

class Strategy{



    //this(PlayerView playerView){}
    int idBuilder = -1;
    int tempBuilder = -1;
    int oldhouseCount = 0; 
    int myId;
    
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

    bool IsPlaceEmptyForHouse(PlayerView playerView, Vec2Int p, int identity)
    {
        foreach (entity; playerView.entities) {
            if(entity.id!=identity && (p.x<entity.position.x && p.x+3>entity.position.x && p.y<entity.position.y && p.y+3>entity.position.y))
                return false;
        }
        return true;
    }

    // EntityAction getActionForFighter(Entity entity, PlayerView playerView)
    // {

    // }

    Action calculateAction(PlayerView playerView){
        Action action;
        myId = playerView.myId;

     
        Nullable!(BuildAction) buildAction = Nullable!(BuildAction).init;
        Nullable!(AttackAction) attackAction = Nullable!(AttackAction).init;
        Nullable!(RepairAction) repairAction = Nullable!(RepairAction).init;


        int[int]  playersU;

                      
        bool isBuildUnitChecked = false;
        bool isBuildBaseChecked = false;
        bool isHouseIsBuilding = false;


        int repairCounts = 0;
        int rangeCount = 0;
        int buildCount = 0;
        int houseCount = 0;
        int unitCount = 0;
        int resCount = 0;
        int turretCount = 0;
        int meleeCount = 0;
        int houseCompleted = 0;
               
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
                    buildCount++;
                if (enemyEntity.entityType == EntityType.RangedUnit)
                    rangeCount++;
                if (enemyEntity.entityType == EntityType.MeleeUnit)
                    meleeCount++;
                if (enemyEntity.entityType == EntityType.House){
                    houseCount++;
                    if (enemyEntity.active)
                        houseCompleted++;
                }
                if (enemyEntity.entityType ==3 || enemyEntity.entityType ==5 || enemyEntity.entityType ==7)
                    unitCount++;
                if (enemyEntity.entityType ==9)
                    turretCount++;
            }
            else if(!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId)
            {
                if (enemyEntity.entityType == 3 || enemyEntity.entityType == 5 || enemyEntity.entityType == 7)
                {
                    playersU[enemyEntity.playerId.get]++;
                }
            }
        }


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


        int rangedRes = playerView.entityProperties[EntityType.RangedUnit].buildScore + rangeCount;

                    int meleeCost = playerView.entityProperties[EntityType.MeleeUnit].buildScore + meleeCount;
                    int houseCost = playerView.entityProperties[EntityType.House].buildScore;

        foreach (entity; playerView.entities) {
            int countRes = playerView.entityProperties[EntityType.RangedUnit].buildScore +rangeCount;
            if(!entity.playerId.isNull() && entity.playerId.get==myId){

                foreach (baseEntity; playerView.entities) {
                        if (!baseEntity.playerId.isNull() && baseEntity.playerId.get==myId) {
                            if ((baseEntity.entityType==9 || baseEntity.entityType==1 ) && baseEntity.active==false){
                                idBuilder = -1;
                                isHouseIsBuilding = false;
                            }
                        }
                }



				if(entity.entityType ==5 || entity.entityType ==7)//если вояка
                {
                   // action.entityActions[entity.id]=getActionForFighter(entity, playerView);
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
                }
                else if (entity.entityType ==3)//  && isHouseIsBuilding==false
                {
                    i++;
                   
                    Nullable!Entity newBase;
                    foreach (newbase; playerView.entities) {
                        if (!newbase.playerId.isNull() && newbase.playerId.get==myId && (newbase.entityType == 6 || newbase.entityType == 4 || newbase.entityType == 2 ||newbase.entityType == 1||newbase.entityType == 9||newbase.entityType == 0)) {
                            if(newbase.health<playerView.entityProperties[newbase.entityType].maxHealth){
                                if(newBase.isNull() || distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(newbase.position.x, newbase.position.y)) <
                                        distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(newBase.get.position.x, newBase.get.position.y)))
                                            newBase = newbase;
                                    }
                        }
                    }

                    if(!newBase.isNull() && (idBuilder == entity.id || j<3 ))//distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(newBase.get.position.x, newBase.get.position.y))<400
                    {        
                        Nullable!(MoveAction) moveAction = MoveAction(newBase.get.position, true,false);
                        repairAction = RepairAction(newBase.get.id);
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        repairCounts++;
                        j++;
                    } 
                    else {
                       // int rr = playerView.entityProperties[EntityType.House].buildScore;
                        int newHouseX = 0;
                            int newHouseY  =0;
                            if(houseCount<4){
                                newHouseX = 5+houseCount*4;//100;
                                newHouseY = 11;//0;
                            }
                            else if (houseCount==4)
                            {
                                newHouseX = 11;
                                newHouseY = 7;//0;
                            }
                            else if (houseCount==5)
                            {
                                newHouseX = 11;//100;
                                newHouseY = 15;//0;
                            }
                            else if (houseCount>=6 && houseCount<11)
                            {
                                newHouseX = 1;//100;
                                newHouseY = 1+(houseCount-6)*4;//0;
                            }
                            else
                            {
                                newHouseX = 5+(houseCount-11)*4;//100;
                                newHouseY = 1;//0;
                            }
                        bool isPlaceIsEmpty = IsPlaceEmptyForHouse(playerView, Vec2Int(newHouseX,newHouseY),entity.id);
                        if (turretCount==1 && k<4 && resCount>playerView.entityProperties[EntityType.Turret].buildScore && IsPlaceEmptyForHouse(playerView, Vec2Int(15,18),entity.id))
                        {
                            int turretX = 15;
                                int turretY = 18;
                                // if(houseCount==7 )
                                // {
                                //     turretX = 18;
                                //     turretY = 15;
                                // }
                                buildAction = BuildAction(EntityType.Turret, Vec2Int(turretX,turretY) );
                                Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(turretX,turretY), true,false);
                                EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                action.entityActions[entity.id]=ent_act;
                                //resCount-=countRes;
                                isBuildBaseChecked = true;
                                isHouseIsBuilding = true;
                                idBuilder = entity.id;
                                k++;
                        }
                        else if (turretCount==2 &&  k<4 && houseCount>=6 && resCount>playerView.entityProperties[EntityType.Turret].buildScore+rangedRes && IsPlaceEmptyForHouse(playerView, Vec2Int(18,15),entity.id))
                        {
                            int turretX = 18;
                                int turretY = 15;
                                buildAction = BuildAction(EntityType.Turret, Vec2Int(turretX,turretY) );
                                Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(turretX,turretY), true,false);
                                EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                action.entityActions[entity.id]=ent_act;
                                //resCount-=countRes;
                                isBuildBaseChecked = true;
                                isHouseIsBuilding = true;
                                idBuilder = entity.id;
                                k++;
                        }
                        else if(resCount>houseCost && isBuildBaseChecked==false && isPlaceIsEmpty){//+rangedRes
                            // if(
                            //     houseCount==6 && resCount>playerView.entityProperties[EntityType.Turret].buildScore && IsPlaceEmptyForHouse(playerView, Vec2Int(15,18),entity.id)
                            // ){
                            //     int turretX = 15;
                            //     int turretY = 18;
                            //     // if(houseCount==7 )
                            //     // {
                            //     //     turretX = 18;
                            //     //     turretY = 15;
                            //     // }
                            //     buildAction = BuildAction(EntityType.Turret, Vec2Int(turretX,turretY) );
                            //     Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(turretX,turretY), true,false);
                            //     EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                            //     action.entityActions[entity.id]=ent_act;
                            //     //resCount-=countRes;
                            //     isBuildBaseChecked = true;
                            //     isHouseIsBuilding = true;
                            //     idBuilder = entity.id;
                            // }
                            // else{
                                buildAction = BuildAction(EntityType.House, Vec2Int(newHouseX,newHouseY) );
                                Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(newHouseX,newHouseY), true,false);
                                EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                action.entityActions[entity.id]=ent_act;
                                //resCount-=countRes;
                                isBuildBaseChecked = true;
                                isHouseIsBuilding = true;
                                idBuilder = entity.id;
                            //}
                        }
                        else{
                            Nullable!Entity nearestResource;

                            Nullable!Entity nearestEnemy;
                                foreach (enemyEntity; playerView.entities) {
                                    if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId && distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y))<100 ) {
                                        if (nearestEnemy.isNull() ||
                                                distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <
                                                    distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestEnemy.get.position.x, nearestEnemy.get.position.y))
                                        
                                                ) {
                                            nearestEnemy = enemyEntity;
                                        }
                                    }
                                }
                            //distanceSqr
                            if (!nearestEnemy.isNull()){

                                // foreach (resourceEntity; playerView.entities) {
                                //     if (resourceEntity.entityType ==8) {// && (resourceEntity.position.x*resourceEntity.position.x+ resourceEntity.position.y*resourceEntity.position.y)<=40
                                //         if (nearestResource.isNull() ||
                                //             (distanceSqr2(entity.position, resourceEntity.position) >
                                //                 distanceSqr2(entity.position, Vec2Int(15,15)) &&  distanceSqr2(nearestEnemy.get.position, resourceEntity.position) >
                                //                 distanceSqr2(entity.position, resourceEntity.position))) {
                                //             nearestResource = resourceEntity;
                                //         }
                                //     }
                                // }
                                    Vect2D!int vect = Vect2D!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestEnemy.get.position.x+15, nearestEnemy.get.position.y+15));
                           
                                    vect.turn(3.14159);
                                    Vec2Int target = Vec2Int(vect.finish.x, vect.finish.y);
                                    if(target.x<0) target.x=0;
                                    if(target.y<0) target.y=0;
                                    if(target.x>79) target.x=79;
                                    if(target.y>79) target.y=79;
                                    Nullable!(MoveAction) moveAction = MoveAction(target, true,false);
                                    EntityAction ent_act= EntityAction(moveAction, buildAction, Nullable!(AttackAction).init, repairAction);
                                    action.entityActions[entity.id]=ent_act;
                            }
                            else{

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
                                    Nullable!int resid = nearestResource.get().id;
                                    Nullable!(AutoAttack) autoattack = AutoAttack(10, [EntityType.Resource]);

                                    Nullable!(MoveAction) moveAction = MoveAction(target, true,false);
                                    attackAction = AttackAction(resid,autoattack);
                                    EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                    action.entityActions[entity.id]=ent_act;
                                }
                                else
                                {
                                    // int randx = uniform(0, 80);int randy = uniform(0, 80);
                                    // Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(randx, randy), true,false);
                                    // EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                    // action.entityActions[entity.id]=ent_act; Nullable!Entity nearestEnemy;
                                // Nullable!Entity nearestEnemy;
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
                                }
                            }
                        }
                    }
                }
                else if (entity.entityType ==EntityType.RangedBase){

                    
                    if((countRes+playerView.entityProperties[EntityType.House].buildScore<resCount))
                   // if (resCount>countRes)
                    {
                        int size = playerView.entityProperties[EntityType.RangedBase].size;
                        buildAction = BuildAction(EntityType.RangedUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        //resCount-=countRes;
                        isBuildUnitChecked = true;
                    }
                    else{
                        action.entityActions[entity.id]=EntityAction(Nullable!(MoveAction).init, Nullable!(BuildAction).init, Nullable!(AttackAction).init, Nullable!(RepairAction).init);
                    }

                }
                else if (entity.entityType ==EntityType.RangedBase || entity.entityType ==EntityType.MeleeBase){

                    
                    
                    if (entity.entityType ==EntityType.RangedBase && (rangedRes<resCount) )
                    {
                        int size = playerView.entityProperties[EntityType.RangedBase].size;
                        buildAction = BuildAction(EntityType.RangedUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        resCount-=rangedRes;
                        isBuildUnitChecked = true;
                    }

                }
                
                else if (entity.entityType ==EntityType.BuilderBase){



                    int countBuilderUnit = playerView.entityProperties[EntityType.BuilderUnit].buildScore;
                    
                    if (resCount>countBuilderUnit && buildCount<10+houseCompleted*2)
                    {
                        int size = playerView.entityProperties[EntityType.BuilderBase].size;
                        buildAction = BuildAction(EntityType.BuilderUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        //resCount-=countBuilderUnit;
                        isBuildUnitChecked = true;
                    }
                    else if (buildCount>=10+houseCompleted*2)
                    {
                        int size = playerView.entityProperties[EntityType.BuilderBase].size;
                        //buildAction = BuildAction(EntityType.BuilderUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, Nullable!(BuildAction).init, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        //resCount-=countBuilderUnit;
                        isBuildUnitChecked = true;
                    }

                }
                else if (entity.entityType ==EntityType.Turret){

                        Nullable!Entity nearestEnemy;
                        foreach (enemyEntity; playerView.entities) {
                            int dist = distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y));
                            if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId && dist<36) {
                                if (nearestEnemy.isNull() ||
                                    distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <
                                        distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestEnemy.get.position.x, nearestEnemy.get.position.y))) {
                                    nearestEnemy = enemyEntity;
                                }
                            }
                        }
                        if(!nearestEnemy.isNull()){
                            Nullable!(AutoAttack) autoattack = AutoAttack(20, [EntityType.RangedUnit, EntityType.MeleeUnit, EntityType.BuilderUnit]);
                            Nullable!int enemyid = Nullable!int.init;
                            attackAction = AttackAction(enemyid,autoattack);
                            Nullable!(MoveAction) moveAction = Nullable!(MoveAction).init;//nearestEnemy.get.position
                            EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                            action.entityActions[entity.id]=ent_act;
                        }


                }
					// if (distanceSqr(unit.position, lootBox.position) < 3) {
					// 	if(game.properties.weaponParameters[unit.weapon.get.typ].bullet.damage< game.properties.weaponParameters[weap.weaponType].bullet.damage){
					// 		targetPos = lootBox.position;
					// 		swapWeapon = true;
					// 	}
					// }
				
			}
        }
        return action;
    }

}