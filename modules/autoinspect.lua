local IQ = InQuiro
IQ:RegisterModule("AutoInspect"):RegisterEvent("PLAYER_TARGET_CHANGED", function()
	IQ:Inspect("target")
end)