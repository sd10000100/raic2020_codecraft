import strategy.strategy;
import debug_interface;
import std.typecons;
import std.conv;
import helper;

class MyStrategy
{
    Strategy strat;

    this(){
        strat = new Strategy;
    }
    
    Action getAction(PlayerView playerView, DebugInterface debugInterface)
    {
        return strat.calculateAction(playerView);
    }

    void debugUpdate(PlayerView playerView, DebugInterface debugInterface)
    {
        debugInterface.send(new DebugCommand.Clear());
        debugInterface.getState();
    }
}
