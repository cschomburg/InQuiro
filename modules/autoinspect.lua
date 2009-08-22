function InQuiro:PLAYER_TARGET_CHANGED()
	if(self:IsShown() and self.unit == "target" and UnitExists("target")) then
		self:Inspect("target")
	end
end
InQuiro:RegisterEvent("PLAYER_TARGET_CHANGED")