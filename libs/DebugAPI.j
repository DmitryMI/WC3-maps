#guard DebugAPI

// Checks is string starts with given mask
function StartsWith takes string source, string template returns boolean
    return SubString(source, 0, StringLength(template)) == template
endfunction

// Returns word with a specific number from a given string
function ExcludeWord takes string command, integer wordNum returns string
    
    local integer srcLen = StringLength(command)
    local integer i = 0
    local integer curWord = 1
    local integer start = 0
    loop        
        set i = i + 1
        set start = i
        loop
            exitwhen i >= srcLen or SubString(command, i, i + 1) == " "
            set i = i + 1
        endloop
        
        exitwhen curWord >= wordNum
        set curWord = curWord + 1
    endloop

    return SubString(command, start, i)
endfunction

function ErrorStream takes trigger trig, string Title, string message, bool pause, bool destroy returns nothing
	string text = \
				"|c00FF0000" + Title + "|r\n" + \
				"In trigger: " + I2S(GetHandleId(trig)) + "\n" + \
				"Error: |c00FCFF00" + message + "|r\n"
				
	if destroy then
		text += "|c0000F6FFTrigger will be destroyed in 10.00 seconds|r\n"
	endif
	
	if pause then
		text += "Game is paused. To unpause type </unpause>"
	endif
	
	text += "========================================\n"
	
	
	DisplayTextToPlayer(Player(0), 0, 0, text)
	
	if pause then
		PauseGame(true)
	endif
	
	if destroy then
		TriggerSleepAction(10.00)
		TriggerClearActions(trig)
		DestroyTrigger(trig)
	endif
	
endfunction

