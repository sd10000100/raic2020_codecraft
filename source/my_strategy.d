import model;
import debug_interface;
import std.typecons;
import std.conv;
import helper;

class MyStrategy
{

    // bool is_unit(EntityType type){
    //     if (type ==2 || type ==4 || type ==6)
    //     return true;
    //     else return false;
    // }
// bool is_unit(EntityType type){
    //     if (type ==2 || type ==4 || type ==6)
    //     return true;
    //     else return false;
    // }

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

    int idBuilder = -1;
    int tempBuilder = -1;
    int oldhouseCount = 0; 
    BuildItem[] buildQueue;
    Nullable!Vec2Int idle;

    this(){
        idle = Nullable!Vec2Int.init;
buildQueue = [];
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(11,20));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(12,20));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(13,20));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(14,19));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(15,18));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(16,17));
buildQueue~=BuildItem(EntityType.Turret, Vec2Int(13,16));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(17,16));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(18,15));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(19,14));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(20,13));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(21,12));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(21,11));
// buildQueue~=BuildItem(EntityType.Wall, Vec2Int(21,10));
buildQueue~=BuildItem(EntityType.Turret, Vec2Int(11,17));
    }
    Action getAction(PlayerView playerView, DebugInterface debugInterface)
    {
        auto myId = playerView.myId;

                Action action;
       // if (playerView.currentTick==1)
       // {
           // playerView.entities

            //find closest enemy
            //MeleeBase 

            // //min
            // foreach (entity; playerView.entities) {
			// 	if(entity.entityType ==2 || entity.entityType ==4 || entity.entityType ==6)
            //     {
                    
            //     }
			// 		// if (distanceSqr(unit.position, lootBox.position) < 3) {
			// 		// 	if(game.properties.weaponParameters[unit.weapon.get.typ].bullet.damage< game.properties.weaponParameters[weap.weaponType].bullet.damage){
			// 		// 		targetPos = lootBox.position;
			// 		// 		swapWeapon = true;
			// 		// 	}
			// 		// }
				
			// }
            
            
            

Nullable!(BuildAction) buildAction = Nullable!(BuildAction).init;//BuildAction();
Nullable!(AttackAction) attackAction = Nullable!(AttackAction).init;
Nullable!(RepairAction) repairAction = Nullable!(RepairAction).init;


int[int]  playersU;
// aa

// int[string] aa;   // Associative array of ints that are
//                   // indexed by string keys.
//                   // The KeyType is string.
// aa["hello"] = 3;  // set value associated with key "hello" to 3
// int value = aa["hello"];
// Nullable!Player nearestPlayer;
// foreach (enemyplayers; playerView.players) {
//     if (!nearestPlayer.isNull() && enemyplayers.id!=myId) {
//         if (nearestEnemy.isNull() ||
//             distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <
//                 distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestEnemy.get.position.x, nearestEnemy.get.position.y))) {
//             nearestEnemy = enemyEntity;
//         }
//     }
// }

// EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);


        // action.entityActions[5]=ent_act;
        // action.entityActions[7]=ent_act;
        //}

                      
                bool isBuildUnitChecked = false;
                bool isBuildBaseChecked = false;
                bool isHouseIsBuilding = false;

                bool isNewHouse = false;

               // int[int] rep
                 int repairCounts = 0;
                 int warunit = 0;
                int rangeCount = 0;
                int buildCount = 0;
                int houseCount = 0;
                int unitCount = 0;
                int resCount = 0;
                int turretCount = 0;
               
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
                        if (enemyEntity.entityType == EntityType.House)
                            houseCount++;
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
                
foreach (pl, vpl; playersU)
{
    if(vpl<MinUnitPlayers)
    {
        MinUnitPlayers = vpl;
        MinUnitPlayerId = pl;
    }
}
int i = 0;
        foreach (entity; playerView.entities) {
            int countRes = playerView.entityProperties[EntityType.RangedUnit].buildScore +rangeCount;
            if(!entity.playerId.isNull() && entity.playerId.get==myId){
                
                if (houseCount!=oldhouseCount)
                {
                    isHouseIsBuilding = false;
                    oldhouseCount =  houseCount;
                   idBuilder = -1;
                }
				if(entity.entityType ==5 || entity.entityType ==7)//если вояка
                {
                   if(rangeCount<3){
                        Nullable!(AutoAttack) autoattack = AutoAttack(30, [EntityType.RangedUnit, EntityType.MeleeUnit]);
                        Nullable!int enemyid = Nullable!int.init;
                        attackAction = AttackAction(enemyid,autoattack);
                        Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(20,20), true,true);//Vec2Int(playerView.mapSize+warunit*5,0)
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        warunit+=1;
                    }
                    else {
                       Nullable!Entity nearestEnemy;
                        foreach (enemyEntity; playerView.entities) {
                        if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId) {
                            if (nearestEnemy.isNull() || (enemyEntity.position.x<35 && enemyEntity.position.y<35 && 
                                    distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <400)
                            ){
                                nearestEnemy = enemyEntity;
                            }
                        }
                        }
                        if (nearestEnemy.isNull()){
                            foreach (enemyEntity; playerView.entities) {
                                if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get==MinUnitPlayerId) {
                                    if (nearestEnemy.isNull() ||
                                        // distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <
                                        //     distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestEnemy.get.position.x, nearestEnemy.get.position.y))
                                            (enemyEntity.entityType == 6 || enemyEntity.entityType == 2 || enemyEntity.entityType == 4|| enemyEntity.entityType == 1|| enemyEntity.entityType == 9)
                                            
                                            ) {
                                        nearestEnemy = enemyEntity;
                                    }
                                }
                            }
                        }
                        if (nearestEnemy.isNull())
                        {
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
                        }


                        Nullable!(AutoAttack) autoattack = AutoAttack(30, [EntityType.BuilderUnit, EntityType.MeleeUnit, 
                                                                           EntityType.RangedUnit, EntityType.Turret,
                                                                           EntityType.Wall,EntityType.House,EntityType.BuilderBase,
                                                                           EntityType.MeleeBase,EntityType.RangedBase]);
                        Nullable!int enemyid = nearestEnemy.get().id;
                        attackAction = AttackAction(enemyid,autoattack);
                        Nullable!(MoveAction) moveAction = MoveAction(nearestEnemy.get.position, true,true);//Vec2Int(playerView.mapSize+warunit*5,0)
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        warunit+=1;
                    }
                }
                else if (entity.entityType ==3 && isHouseIsBuilding==false)// 
                {
                    i++;
                    if(tempBuilder ==-1 && i==5)
                    {
                        tempBuilder = entity.id;
                    }

                    if(buildQueue.length>0 &&  tempBuilder == entity.id)
                    { 
                        // && idle.isNull() && resCount>playerView.entityProperties[itm.typeByild].buildScore
                        
                        if(resCount>playerView.entityProperties[buildQueue[0].typeByild].buildScore)
                        {
                            buildAction = BuildAction(buildQueue[0].typeByild, buildQueue[0].position );
                            Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(buildQueue[0].position.x,buildQueue[0].position.y+1), true,false);
                            EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                            action.entityActions[entity.id]=ent_act;
                            resCount-=playerView.entityProperties[buildQueue[0].typeByild].buildScore;
                           // if()
                            
                            idle = buildQueue[0].position;
                        }
                        else
                        {
                            Nullable!Entity newBase;
                            foreach (newbase; playerView.entities) {
                                if (!newbase.playerId.isNull() && newbase.playerId.get==myId && (newbase.entityType == 6 || newbase.entityType == 4 || newbase.entityType == 2 ||newbase.entityType == 1||newbase.entityType == 9||newbase.entityType == 0)) {
                                    if(newBase.isNull() &&  newbase.health<playerView.entityProperties[newbase.entityType].maxHealth)
                                    
                                        newBase = newbase;
                                        if(!idle.isNull() && newbase.position.x == idle.get.x && newbase.position.y == idle.get.y)
                                            {idle = Nullable!Vec2Int.init;
                                            buildQueue = buildQueue[1..$];}
                                }
                            }



                            if(!newBase.isNull())
                            {        
                                Nullable!(MoveAction) moveAction = MoveAction(newBase.get.position, true,false);
                                repairAction = RepairAction(newBase.get.id);
                                EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                                action.entityActions[entity.id]=ent_act;
                                repairCounts++;
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
                            Vec2Int target = nearestResource.get.position;
                            Nullable!int resid = nearestResource.get().id;
                            Nullable!(AutoAttack) autoattack = AutoAttack(10, [EntityType.Resource]);

                            Nullable!(MoveAction) moveAction = MoveAction(target, true,false);
                            attackAction = AttackAction(resid,autoattack);
                            EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                            action.entityActions[entity.id]=ent_act;
                        }
                        }
                        //continue;
                    }
                    else if (tempBuilder != entity.id){

                    Nullable!Entity newBase;
                    foreach (newbase; playerView.entities) {
                        if (!newbase.playerId.isNull() && newbase.playerId.get==myId && (newbase.entityType == 6 || newbase.entityType == 4 || newbase.entityType == 2 ||newbase.entityType == 1||newbase.entityType == 9||newbase.entityType == 0)) {
                            if(newBase.isNull() &&  newbase.health<playerView.entityProperties[newbase.entityType].maxHealth)
                            
                                newBase = newbase;
                                if(!idle.isNull() && newbase.position.x == idle.get.x && newbase.position.y == idle.get.y)
                                    {idle = Nullable!Vec2Int.init;
                                    buildQueue = buildQueue[1..$];}
                        }
                    }




                    if(!newBase.isNull() && (idBuilder == entity.id || distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(newBase.get.position.x, newBase.get.position.y))<100))
                    {        
                        Nullable!(MoveAction) moveAction = MoveAction(newBase.get.position, true,false);
                        repairAction = RepairAction(newBase.get.id);
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        repairCounts++;
                    } 
                    else {
                        int rr = playerView.entityProperties[EntityType.House].buildScore;
                        // if(turretCount<2 && resCount>playerView.entityProperties[EntityType.Turret].buildScore && isBuildBaseChecked==false)
                        // {
                        //     buildAction = BuildAction(EntityType.Turret, Vec2Int(13,17) );
                        //     Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(13,17+1), true,false);
                        //     EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        //     action.entityActions[entity.id]=ent_act;
                        //     //resCount-=countRes;
                        //     isBuildBaseChecked = true;
                        // }
                        // else 
                        if(resCount>rr && isBuildBaseChecked==false  ){
                            int newHouseX = 0;
                            int newHouseY  =0;
                            if(houseCount<4){
                                newHouseX = 5+houseCount*4;//100;
                                newHouseY = 11;//0;
                            }
                            else if (houseCount>=4 && houseCount<9)
                            {
                                newHouseX = 1;//100;
                                newHouseY = 1+(houseCount-4)*4;//0;
                            }
                            else
                            {
                                newHouseX = 5+(houseCount-9)*4;//100;
                                newHouseY = 1;//0;
                            }
                            
   
    // //строим зданиеif

                            buildAction = BuildAction(EntityType.House, Vec2Int(newHouseX,newHouseY) );
                            Nullable!(MoveAction) moveAction = MoveAction(Vec2Int(newHouseX,newHouseY+1), true,false);
                            EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                            action.entityActions[entity.id]=ent_act;
                            //resCount-=countRes;
                            isBuildBaseChecked = true;
                            isHouseIsBuilding = true;
                            idBuilder = entity.id;
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
                            Vec2Int target = nearestResource.get.position;
                            Nullable!int resid = nearestResource.get().id;
                            Nullable!(AutoAttack) autoattack = AutoAttack(10, [EntityType.Resource]);

                            Nullable!(MoveAction) moveAction = MoveAction(target, true,false);
                            attackAction = AttackAction(resid,autoattack);
                            EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                            action.entityActions[entity.id]=ent_act;
                        }
                    }
                    }
                }
                else if (entity.entityType ==EntityType.RangedBase &&  (countRes+playerView.entityProperties[EntityType.House].buildScore<resCount)){

                    
                    
                    // if (resCount>countRes)
                    // {
                        int size = playerView.entityProperties[EntityType.RangedBase].size;
                        buildAction = BuildAction(EntityType.RangedUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        //resCount-=countRes;
                        isBuildUnitChecked = true;
                    //}

                }
                
                else if (entity.entityType ==EntityType.BuilderBase){



                    int countBuilderUnit = playerView.entityProperties[EntityType.BuilderUnit].buildScore;
                    
                    if (resCount>countBuilderUnit && buildCount<10+houseCount)
                    {
                        int size = playerView.entityProperties[EntityType.BuilderBase].size;
                        buildAction = BuildAction(EntityType.BuilderUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        //resCount-=countBuilderUnit;
                        isBuildUnitChecked = true;
                    }
                    else if (buildCount>=10+houseCount)
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

    void debugUpdate(PlayerView playerView, DebugInterface debugInterface)
    {
        debugInterface.send(new DebugCommand.Clear());
        debugInterface.getState();
    }
}
