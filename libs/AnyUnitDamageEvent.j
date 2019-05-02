// http://xgm.guru/p/wc3/catch-dmg
library UnitDamaged initializer InitRect
{
    region Region
    nothing Adder()
    {
        if(GetEnteringUnit()!=null)
        {
            TriggerRegisterUnitEvent(GetTriggeringTrigger(),GetEnteringUnit(),EVENT_UNIT_DAMAGED)
        }
    }
    
    nothing AnyUnitDamagedEvent(trigger trg)
    {
        group CurrentUnits = CreateGroup()
        unit Picked
        GroupEnumUnitsInRect(CurrentUnits,bj_mapInitialPlayableArea,null)
        loop
        {
            Picked = FirstOfGroup(CurrentUnits)
            exitwhen Picked == null
            TriggerRegisterUnitEvent(trg,Picked,EVENT_UNIT_DAMAGED)
            GroupRemoveUnit(CurrentUnits,Picked)
        }
        TriggerRegisterEnterRegion(trg,Region,null)
        TriggerAddAction(trg,function Adder)
        DestroyGroup(CurrentUnits)
        CurrentUnits=null
    }
    
    nothing InitRect()
    {
        Region = CreateRegion()
        RegionAddRect(Region, bj_mapInitialPlayableArea)
    }
}
