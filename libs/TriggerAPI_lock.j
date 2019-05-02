#guard TriggerAPI

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
		static integer TotalMemoryAllocated = 0
		
		static bool Lock = false
		

		static method LineEmpty takes integer i returns boolean
        
			if i < TotalMemoryAllocated then
				return false
			endif
			return true
		endmethod

		// Returns trigger's position in casted triggers array
		static method TriggerIndexOf takes trigger trig returns integer
		
			while(Lock)
			{
				BJDebugMsg("TriggerIndexOf waiting on LOCK")
			}

			local integer i = 0
			loop
				exitwhen LineEmpty(i)
				if Triggers[i] == trig then
				
					// clear memory
					trig = null

					return i
					//break
				endif
				set i = i + 1
			endloop
			set trig = null
			
			string invokerTag = "Unknown"
			int invokerIndex = TrIndOfNoWarnings(GetTriggeringTrigger())
			if(invokerIndex != -1) then
				invokerTag = TriggerAPI.Keys[TrIndOfNoWarnings(GetTriggeringTrigger())]
			endif
			
			DisplayTextToPlayer(Player(0), 0, 0,\
				"========================================\n" + \
				"|c00FF0000TRIGGER API ERROR|r\n" + \
				"Invoker ID: " + I2S(GetHandleId(GetTriggeringTrigger())) + "\n" + \
				"Invoker tag: " + invokerTag + "\n" + \
				"Error: |c00FCFF00Trigger not found in assotiative array|r\n" + \
				"Info: Function ended on variable I = " + I2S(i) + "\n" + \
				"|c0000F6FFTrigger will be destroyed in 10.00 seconds|r\n" + \
				"========================================")
			PauseGame(true)
			TriggerSleepAction(10.00)
			TriggerClearActions(trig)
			DestroyTrigger(trig)
        
			// Clear memory
			trig = null
			invokerTag = null

			return -1
		endmethod
		
		static method TrIndOfNoWarnings takes trigger trig returns integer
			
			while(Lock)
			{
				BJDebugMsg("TrIndOfNoWarnings is waiting on LOCK")
			}
			
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
			
			while(Lock)
			{
				BJDebugMsg("FindEnd is waiting on LOCK")
			}
		
			local integer i = 0
			loop
				exitwhen LineEmpty(i)
				set i = i + 1
			endloop

			return i
		endmethod

		// Adds new trigger to an array. Returns it's index
		static method NewTrigger takes trigger t, integer fields, string Key returns integer
		
			while(Lock)
			{
				BJDebugMsg("NewTrigger is waiting on LOCK")
			}
			
			Lock = true
		
			local integer lastInd = FindEnd()
			set Triggers[lastInd] = t
			set MemoryFields[lastInd] = fields
			set Keys[lastInd] = Key
        
			TotalMemoryAllocated += fields
        
			// Clear memory
			t = null
			Key = null
			
			Lock = false
			return lastInd
		endmethod
		
		// Deletes trigger from an array, destroys it and shifts all memory arrays
		static method DeleteTrigger takes trigger trig returns nothing
			while(Lock)
			{
				BJDebugMsg("DeleteTrigger waiting on LOCK")
			}
			
			Lock = true
			
		
			local integer i = TriggerIndexOf(trig)
			DisableTrigger(trig)
			TriggerClearActions(trig)
			DestroyTrigger(trig)			
        
			if i != -1 then 
            
				// Get memory fields allocated by this trigger
				local integer fields = MemoryFields[i]
				local integer last = FindEnd()
            
				TotalMemoryAllocated -= fields
            
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
                
				// Shift memory arrays
				loop
					exitwhen i >= last
                
					set Triggers[i] = Triggers[i + fields]
					set Positions[i] = Positions[i + fields]
					set Units[i] = Units[i + fields]
					set Effects[i] = Effects[i + fields]
					set Reals[i] = Reals[i + fields]
					set Integers[i] = Integers[i + fields]
					set TextTags[i] = TextTags[i + fields]
					set Dialogs[i] = Dialogs[i + fields]
					set DialogButtons[i] = DialogButtons[i + fields]
					set Lightnings[i] = Lightnings[i + fields]
					set MemoryFields[i] = MemoryFields[i + fields]
					set Keys[i] = Keys[i + fields]
                
					set i = i + 1
				endloop			
				
			endif
			
			// Clear memory
			trig = null
			
			Lock = false
        
		endmethod
    
		static method FindMatchingTrigger takes integer index returns integer
			while(Lock)
			{
				BJDebugMsg("Lock is truely needed! Or it's just a bug :(")
			}
						
			integer ind = index
			loop
				exitwhen TriggerAPI.Triggers[ind] != null or ind < 0
				ind = ind - 1
			endloop

			return ind
		endmethod
    
		static method UnitTrigIndexOf takes unit u, string Key returns integer   
			
			while(Lock)
			{
				BJDebugMsg("Lock is truely needed! Or it's just a bug :(")
			}
						
			// Scan all units in array
			integer ind = 0
			loop
				exitwhen TriggerAPI.LineEmpty(ind)
            
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
			while(Lock)
			{
				BJDebugMsg("FindTrigger is waiting on LOCK")
			}
		
			int ind = 0
			loop
				exitwhen ind >= TotalMemoryAllocated				
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
		
		/*
		
		// Getters and setters
		// If trig == null then field is a apbsolute pointer.
		// 	 Else field is relative to trig's position
		//   And oveflowing will be checked
		static unit GetUnit(trigger trig, int field)
		{
			if(trig != null) then
				int trigInd = TriggerIndexOf(trig)
				int length = MemoryFields[trigInd]
				if(field < length and field >= 0) then
					return Units[trigInd + field]
				else
					OveflowError(field, "GetUnit()")
				endif
				return null
			else
				return Units[field]
			endif
		}
		
		static integer GetInteger(trigger trig, int field)
		{
			if(trig != null) then
				int trigInd = TriggerIndexOf(trig)
				int length = MemoryFields[trigInd]
				if(field < length and field >= 0) then
					return Integers[trigInd + field]
				else
					OveflowError(field, "GetInteger()")
				endif
				return null
			else
				return Integers[field]
			endif
		}
		
		static real GetReal(trigger trig, int field)
		{
			if(trig != null) then
				int trigInd = TriggerIndexOf(trig)
				int length = MemoryFields[trigInd]
				if(field < length and field >= 0) then
					return Reals[trigInd + field]
				else
					OveflowError(field, "GetReal()")
				endif
				return null
			else
				return Reals[field]
			endif
		}
		
		static nothing SetUnit(trigger trig, int field, unit value)
		{
			if(trig != null) then
				int trigInd = TriggerIndexOf(trig)
				int length = MemoryFields[trigInd]
				if(field < length and field >= 0) then
					Units[trigInd + field] = value
				else
					OveflowError(field, "SetUnit()")
				endif
			else
				Units[field] = value
			endif
		}
		
		static nothing SetInteger(trigger trig, int field, int value)
		{
			if(trig != null) then
				int trigInd = TriggerIndexOf(trig)
				int length = MemoryFields[trigInd]
				if(field < length and field >= 0) then
					Integers[trigInd + field] = value
				else
					OveflowError(field, "SetInteger()")
				endif
			else
				Integers[field] = value
			endif
		}
		
		static nothing SetReal(trigger trig, int field, real value)
		{			
			if(trig != null) then
				int trigInd = TriggerIndexOf(trig)
				int length = MemoryFields[trigInd]
				
				int tarFieldtrigInd = FindMatchingTrigger(trigInd + field)
				string tarTag = Keys[tarFieldtrigInd]
				if(IsDebug) then					
					if(Keys[trigInd] == tarTag) then
						DisplayTextToPlayer(Player(0), 0, 0, "Trigger with index " + I2S(trigInd) + " |c000000FF(" + Keys[trigInd] + ")|r " + " is writing to " + I2S(trigInd + field))
					else
						DisplayTextToPlayer(Player(0), 0, 0, "Trigger with index " + I2S(trigInd) + " |c000000FF(" + Keys[trigInd] + ")|r " + " is writing to " + I2S(trigInd + field) + " |c00FF0000(" + tarTag + ")|r" )
					endif
				elseif (Keys[trigInd] != tarTag)
					DisplayTextToPlayer(Player(0), 0, 0, "Trigger with index " + I2S(trigInd) + " |c000000FF(" + Keys[trigInd] + ")|r " + " is writing to " + I2S(trigInd + field) + " |c00FF0000(" + tarTag + ")|r" )
				endif
				
				if(field < length and field >= 0) then
					Reals[trigInd + field] = value
				else
					OveflowError(field, "SetReal()")
				endif
			else
				Reals[field] = value
			endif
		}
		*/
		static nothing ResetTriggerAPI()
		{
			int i = 0
			loop
				exitwhen i >= TotalMemoryAllocated
				if(Triggers[i] != null) then
					DeleteTrigger(Triggers[i])
				endif
				i++
			endloop
		}
		
    
	endstruct
endlibrary