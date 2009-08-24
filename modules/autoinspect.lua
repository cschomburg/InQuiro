local IQ = InQuiro
IQ:RegisterModule("AutoInspect"):RegisterEvent("PLAYER_TARGET_CHANGED", function()
	if(IQ.unit == "target" and UnitExists("target")) then
		IQ:Inspect("target")
	end
end)