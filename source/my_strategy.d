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

// EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);


        // action.entityActions[5]=ent_act;
        // action.entityActions[7]=ent_act;
        //}

        
        foreach (entity; playerView.entities) {
            if(!entity.playerId.isNull() && entity.playerId.get==myId){
                int warunit = 0;
				if(entity.entityType ==5 || entity.entityType ==7)//если вояка
                {
                    if (!entity.playerId.isNull() && entity.playerId.get ==myId){
                        Vec2Int target = Vec2Int(playerView.mapSize/4+warunit*5,playerView.mapSize/4+warunit*5 );



                        Nullable!(MoveAction) moveAction = MoveAction(target, true,true);
                        EntityAction ent_act= EntityAction(moveAction, buildAction, attackAction, repairAction);
                        action.entityActions[entity.id]=ent_act;
                        warunit+=1;
                    }
                }
                else if (entity.entityType ==3)
                {
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
                else if (entity.entityType ==EntityType.RangedBase){
                    int resCount = 0;
                    foreach (player; playerView.players)
                    {
                        if (player.id==myId)
                        {
                            resCount = player.resource;
                        }
                    }


                    int countRes = playerView.entityProperties[EntityType.RangedUnit].buildScore;
                    
                    if (resCount>countRes)
                    {
                        int size = playerView.entityProperties[EntityType.RangedBase].size;
                        buildAction = BuildAction(EntityType.RangedUnit, Vec2Int(entity.position.x+size,entity.position.y) );
                        EntityAction ent_act= EntityAction(Nullable!(MoveAction).init, buildAction, attackAction, repairAction);
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
