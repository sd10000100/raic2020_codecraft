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

    int idBuilder = -1;
    Action getAction(PlayerView playerView, DebugInterface debugInterface)
    {
        auto myId = playerView.myId;

                Action action;

            
            

Nullable!(BuildAction) buildAction = Nullable!(BuildAction).init;
Nullable!(AttackAction) attackAction = Nullable!(AttackAction).init;
Nullable!(RepairAction) repairAction = Nullable!(RepairAction).init;

// EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);


        // action.entityActions[5]=ent_act;
        // action.entityActions[7]=ent_act;
        //}

                      
                bool isBuildUnitChecked = false;
                bool isBuildBaseChecked = false;
                bool isHouseIsBuilding = false;

                bool isNewHouse = false;

                int oldhouseCount = 0; 
                 int repairCounts = 0;

                  int warunit = 0;
                int rangeCount = 0;
                int meleeCount = 0;
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
                }

                foreach (myEntity; playerView.entities) {
                    if (!myEntity.playerId.isNull() && myEntity.playerId.get==myId) {
                        if (myEntity.entityType == EntityType.BuilderUnit)
                            buildCount++;
                        if (myEntity.entityType == EntityType.MeleeUnit)
                            meleeCount++;
                        if (myEntity.entityType == EntityType.RangedUnit)
                            rangeCount++;
                        if (myEntity.entityType == EntityType.House)
                            houseCount++;
                        if (myEntity.entityType ==3 || myEntity.entityType ==5 || myEntity.entityType ==7)
                            unitCount++;
                        if (myEntity.entityType ==9)
                            turretCount++;
                    }
                }       



        foreach (entity; playerView.entities) {
            if(!entity.playerId.isNull() && entity.playerId.get==myId){

                if (houseCount!=oldhouseCount)
                {
                    isHouseIsBuilding = false;
                    oldhouseCount =  houseCount;
                   idBuilder = -1;
                }
				if(entity.entityType ==5 || entity.entityType ==7)//если вояка
                {
                    if (!entity.playerId.isNull() && entity.playerId.get ==myId){
                        Vec2Int target = Vec2Int(playerView.mapSize+warunit*5,0); //playerView.mapSize+warunit*5


                        Nullable!Entity nearestForBaseEnemy;
                        int minDistToBase  = 10000;
                        foreach (enemyEntity; playerView.entities) {
                            if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId) {
                                if (nearestForBaseEnemy.isNull() ||
                                    distanceSqr!int(Point2D!int(15,15), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <
                                        distanceSqr(Point2D!int(15,15), Point2D!int(nearestForBaseEnemy.get.position.x, nearestForBaseEnemy.get.position.y))) {
                                    nearestForBaseEnemy = enemyEntity;
                                    minDistToBase = distanceSqr!int(Point2D!int(15,15), Point2D!int(enemyEntity.position.x, enemyEntity.position.y));
                                }
                            }
                        }

                        Nullable!Entity nearestEnemy;
                        foreach (enemyEntity; playerView.entities) {
                            if (!enemyEntity.playerId.isNull() && enemyEntity.playerId.get!=myId) {
                                if (nearestEnemy.isNull() ||
                                    distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(enemyEntity.position.x, enemyEntity.position.y)) <
                                        distanceSqr(Point2D!int(entity.position.x, entity.position.y), Point2D!int(nearestEnemy.get.position.x, nearestEnemy.get.position.y))) {
                                    nearestEnemy = enemyEntity;
                                }
                            }
                        }
                        Nullable!int enemyid = Nullable!int.init;
                        Nullable!(MoveAction) moveAction = Nullable!(MoveAction).init;
                        Vec2Int targetpos; 
                        // if (minDistToBase>900)
                        // {
                            enemyid = nearestEnemy.get().id;
                            targetpos = nearestEnemy.get.position;
                        // }
                        // else
                        // {
                        //     enemyid = nearestForBaseEnemy.get().id;
                        //     targetpos = nearestForBaseEnemy.get.position;
                        // }
                        Nullable!(AutoAttack) autoattack = AutoAttack(20, [EntityType.Resource]);
                        
                        attackAction = AttackAction(enemyid,Nullable!(AutoAttack).init);
                        moveAction = MoveAction(targetpos, true,true);//nearestEnemy.get.position
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        warunit+=1;
                    }
                }
                else if (entity.entityType ==3 && isHouseIsBuilding==false)
                {

                    Nullable!Entity newBase;
                    foreach (newbase; playerView.entities) {
                        if (!newbase.playerId.isNull() && newbase.playerId.get==myId && (newbase.entityType == 6 || newbase.entityType == 4 || newbase.entityType == 2 ||newbase.entityType == 1||newbase.entityType == 9)) {
                            if(newBase.isNull() &&  newbase.health<playerView.entityProperties[newbase.entityType].maxHealth)
                            
                                newBase = newbase;
                        }
                    }

                    if(!newBase.isNull()&& (distanceSqr!int(Point2D!int(entity.position.x, entity.position.y), Point2D!int(newBase.get.position.x, newBase.get.position.y))<100))
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
                        if(resCount>rr && isBuildBaseChecked==false && (houseCount)*5+10<=unitCount+2  ){
                            int newHouseX = 0;
                            int newHouseY  =0;
                            if(houseCount<5){
                                newHouseX = 5+houseCount*3;//100;
                                newHouseY = 11;//0;
                            }
                            else
                            {
                                newHouseX = 0;//100;
                                newHouseY = 0+(houseCount-5)*3;//0;
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
                else if ((entity.entityType ==EntityType.RangedBase || entity.entityType ==EntityType.MeleeBase) && unitCount<=13+(houseCount)*5){

                    int rangedRes = playerView.entityProperties[EntityType.RangedUnit].buildScore + rangeCount;

                    int meleeCost = playerView.entityProperties[EntityType.MeleeUnit].buildScore + meleeCount;
                    
                    if (resCount>rangedRes && rangedRes*2/3<=meleeCost && entity.entityType ==EntityType.RangedBase)
                    {
                        int size = playerView.entityProperties[EntityType.RangedBase].size;
                        buildAction = BuildAction(EntityType.RangedUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        resCount-=rangedRes;
                        isBuildUnitChecked = true;
                    }
                    else if (resCount>meleeCost && rangedRes*2/3>meleeCost && entity.entityType ==EntityType.MeleeBase)
                    {
                        int size = playerView.entityProperties[EntityType.MeleeBase].size;
                        buildAction = BuildAction(EntityType.MeleeUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        resCount-=meleeCost;
                        isBuildUnitChecked = true;
                    }

                }
                else if (entity.entityType ==EntityType.BuilderBase){



                    int countRes = playerView.entityProperties[EntityType.BuilderUnit].buildScore;
                    
                    if (resCount>countRes && buildCount<7+houseCount)
                    {
                        int size = playerView.entityProperties[EntityType.BuilderBase].size;
                        buildAction = BuildAction(EntityType.BuilderUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        //resCount-=countRes;
                        isBuildUnitChecked = true;
                    }
                    else if (buildCount>=7+houseCount)
                    {
                        int size = playerView.entityProperties[EntityType.BuilderBase].size;
                        //buildAction = BuildAction(EntityType.BuilderUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, Nullable!(BuildAction).init, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        //resCount-=countRes;
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
