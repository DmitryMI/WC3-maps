#guard UserFunctions

library UserFunctions
	define 
	{
		int   = integer
		bool  = boolean
		void  = nothing
		float = real
		break = exitwhen true
	}

	real DistFromCoords(real x1, real y1, real x2, real y2)
	{
		local real dx = x2 - x1
		local real dy = y2 - y1
		return SquareRoot(dx * dx + dy * dy)
	}

	//OBSOLETE
	real DistFromCoordsNoRoot(real x1, real y1, real x2, real y2)
	{
		local real dx = x2 - x1
		local real dy = y2 - y1
		return dx * dx + dy * dy
	}
	
	real DistanceSqr(real x1, real y1, real x2, real y2)
	{
		return Pow(x2 - x1, 2) + Pow(y2 - y1, 2)
	}

	real AngleFromCoords(real x1, real y1, real x2, real y2)
	{
		return bj_RADTODEG * Atan2(y2 - y1, x2 - x1)
	}
	
	//function H2S takes handle h returns string
		//return I2S(GetHandleId(h))
	//endfunction

	nothing print(string msg)
	{
		int ind = TriggerAPI.TrIndOfNoWarnings(GetTriggeringTrigger())
		string tag = "Unknown"
		if(ind != -1) then
			tag = TriggerAPI.Keys[ind]
		endif
		string message = "|c0000FFF6" + tag + "|r" + ": " + msg
		DisplayTextToPlayer(Player(0), 0, 0, message)
		tag = null
	}

	bool Chance(real percent)
	{
		real chance = GetRandomReal(0, 100)
		return chance <= percent
	}
	
	real DistanceBetweenUnits(unit a, unit b)
	{
		return DistFromCoords(GetUnitX(a), GetUnitY(a), GetUnitX(b),  GetUnitY(b))
	}
endlibrary