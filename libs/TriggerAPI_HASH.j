#guard TriggerAPI

define TAPI_SIZE = 503

library TrigApiLib
	struct TriggerAPI
		// Flags
		static bool IsDebug = false
		static bool ForceRemoveNullables = false // Except units
		
		// Casted trigger array
		static trigger array Triggers
		// Trigger memory arrays
		static unit array Units
		static location array Positions
		static integer array Integers
		static real array Reals    
		static effect array Effects
		static texttag array TextTags
		static dialog array Dialogs
		static button array DialogButtons
		static lightning array Lightnings
		// Special memory
		static integer array MemoryFields
		static string array Keys

		static method HashFunc takes trigger t returns integer
			return ModuloInteger(GetHandleId(t), TAPI_SIZE)
		endmethod

		static method LineEmpty takes integer i returns boolean
			// Checking if last trigger is far above enough
			integer ind = i
			loop
				exitwhen Triggers[ind] != null || ind < 0
				set ind = ind - 1
			endloop
			if(MemoryFields[ind] + ind < i) then
				return true
			endif
			return false
		endmethod
		
		static method IsFieldFree takes integer i, integer size returns boolean
			if(not LineEmpty(i)) then
				return false
			endif
			integer ind = i
			loop
				exitwhen Triggers[ind] != null or ind - i > size
				set ind = ind + 1
			endloop
			
			return ind - i > size
		endmethod

		// Returns trigger's position in casted triggers array
		static method TriggerIndexOf takes trigger trig returns integer
			local integer i = HashFunc(trig)
			loop
				exitwhen Triggers[i] == trig or i > TAPI_SIZE				
				set i = i + 1
			endloop
			set trig = null	
			return i			
		endmethod
		
		static method TrIndOfNoWarnings takes trigger trig returns integer
			local integer i = 0
			loop
				exitwhen LineEmpty(i)//udg_SpellTriggers[i] == null
				if Triggers[i] == trig then
				
					// clear memory
					trig = null
					
					return i
				endif
				set i = i + 1
			endloop
			set trig = null       
			
			// Clear memory
			trig = null
					
			return -1
		endmethod

		// Returns index of first empty cell in casted triggers array
		static method FindEnd takes nothing returns integer
			local integer i = 0
			loop
				exitwhen LineEmpty(i)
				set i = i + 1
			endloop
			return i
		endmethod

		// Adds new trigger to an array. Returns it's index
		static method NewTrigger takes trigger t, integer fields, string Key returns integer
			local integer lastInd = HashFunc(t)
			
			loop
				exitwhen IsFieldFree(lastInd, fields) || lastInd > TAPI_SIZE
				lastInd++
			endloop
			
			set Triggers[lastInd] = t
			set MemoryFields[lastInd] = fields
			set Keys[lastInd] = Key
                
			// Clear memory
			t = null
			Key = null
			
			return lastInd
		endmethod
		
		// Deletes trigger from an array, destroys it and shifts all memory arrays
		static method DeleteTrigger takes trigger trig returns nothing
        
			local integer i = TriggerIndexOf(trig)
			DisableTrigger(trig)
			TriggerClearActions(trig)
			DestroyTrigger(trig)			
        
			if i != -1 then 
            
				// Get memory fields allocated by this trigger
				local integer fields = MemoryFields[i]
                        
				// Clear memory
				integer j = i
				loop            
					exitwhen j >= i + fields
					
					// Remove nullables
					if(ForceRemoveNullables) then
						if(Positions[j] != null) then
							RemoveLocation(Positions[j])
						endif
						if(Effects[j] != null)
							DestroyEffect(Effects[j])
						endif
						if(TextTags[j] != null) then
							DestroyTextTag(TextTags[j])
						endif
						if(Dialogs[j] != null) then
							DialogDestroy(Dialogs[j])
						endif
						if(Lightnings[j] != null) then
							DestroyLightning(Lightnings[j])
						endif
						ForceRemoveNullables = false
					elseif (IsDebug)
						if(Positions[j] != null) then
							DisplayTextToPlayer(Player(0), 0, 0, "|c00FF0000Position left undestroyed!|r")
						endif
						if(Effects[j] != null) then
							DisplayTextToPlayer(Player(0), 0, 0, "|c00FF0000Effect left undestroyed!|r")
						endif
						if(TextTags[j] != null) then
							DisplayTextToPlayer(Player(0), 0, 0, "|c00FF0000TextTag left undestroyed!|r")
						endif
						if(Dialogs[j] != null) then
							DisplayTextToPlayer(Player(0), 0, 0, "|c00FF0000Dialog left undestroyed!|r")
						endif
						if(Lightnings[j] != null) then
							DisplayTextToPlayer(Player(0), 0, 0, "|c00FF0000Lightning left undestroyed!|r")
						endif
					endif
					
					set Triggers[j] = null
					set Positions[j] = null
					set Units[j] = null
					set Effects[j] = null
					set Reals[j] = 0
					set Integers[j] = 0
					set TextTags[j] = null
					set Dialogs[j] = null
					set DialogButtons[j] = null
					set Lightnings[j] = null
					set MemoryFields[j] = 0
					set Keys[j] = null		
					
					j++
				endloop
			endif
			
			// Clear memory
			trig = null
        
		endmethod
    
		static method FindMatchingTrigger takes integer index returns integer
			integer ind = index
			loop
				exitwhen TriggerAPI.Triggers[ind] != null or ind < 0
				ind = ind - 1
			endloop
			return ind
		endmethod
    
		static method UnitTrigIndexOf takes unit u, string Key returns integer        
			// Scan all units in array
			integer ind = 0
			loop
				exitwhen ind > TAPI_SIZE
            
				unit matchingUnit = TriggerAPI.Units[ind]
				if matchingUnit == u then
					integer sInd = FindMatchingTrigger(ind)
					string sKey = TriggerAPI.Keys[sInd]
					if Key == sKey or Key == "*any*" then
					
						// clear memory
						u = null
						
						return sInd
					endif
				endif
            
				// Clear memory
				matchingUnit = null		
				
				set ind = ind + 1
			endloop
        
			if TriggerAPI.LineEmpty(ind) then
				ind = -1
			endif
			
			// clear memory
			u = null
			Key = null
			
			return ind
		endmethod
		
		static int FindTrigger(string Key)
		{
			int ind = 0
			loop
				exitwhen ind > TAPI_SIZE				
				if(Keys[ind] == Key && Triggers[ind] != null) then
					return ind
				endif
				ind++
			endloop
			return -1
		}
		
		static nothing OveflowError(int field, string func)
		{
			string invokerTag = "Unknown"
			int invokerIndex = TrIndOfNoWarnings(GetTriggeringTrigger())
			int maxFields = MemoryFields[invokerIndex]
			if(invokerIndex != -1) then
				invokerTag = TriggerAPI.Keys[TrIndOfNoWarnings(GetTriggeringTrigger())]
			endif
			DisplayTextToPlayer(Player(0), 0, 0,\
				"========================================\n" + \
				"|c00FF0000TRIGGER API ERROR|r\n" + \
				"Invoker ID: " + I2S(GetHandleId(GetTriggeringTrigger())) + "\n" + \
				"Invoker tag: " + invokerTag + "\n" + \
				"Error: |c00FCFF00Oveflow exception in " + func + "|r\n" + \
				"Info: Argument index is " + I2S(field) + "\n" + \
				"	             Fields: " + I2S(maxFields) + "\n" + \
				"========================================")
				
			DisableTrigger(Triggers[invokerIndex])
		}
		
		static nothing ResetTriggerAPI()
		{
			int i = 0
			loop
				exitwhen i >= TAPI_SIZE
				if(Triggers[i] != null) then
					DeleteTrigger(Triggers[i])
				endif
				i++
			endloop
		}
		
    
	endstruct
endlibrary