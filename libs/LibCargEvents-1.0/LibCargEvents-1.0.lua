local lib = LibStub:NewLibrary("LibCargEvents-1.0", 1)
if(not lib) then return end

local events = {}
local metahandlers = {}
local frame = CreateFrame("Frame")
function lib.RegisterEvent(self, event, func)
	events[event] = events[event] or {}
	local thisEvent = events[event]
	thisEvent[self] = func
	if(thisEvent.count) then
		thisEvent.count = thisEvent.count+1
	else
		thisEvent.count = 1
		frame:RegisterEvent(event)
	end
end

function lib.UnregisterEvent(self, event)
	if(not lib.IsEventRegistered(self, event)) then return end
	local thisEvent = events[event]
	thisEvent[self] = nil
	thisEvent.count = thisEvent.count-1
	if(thisEvent.count == 0) then
		frame:UnregisterEvent(event)
		thisEvent.count = nil
	end
end

function lib.IsEventRegistered(self, event)
	return events and events[event] and events[event][self] and true
end

function lib.SetMetaHandler(self, func)
	metahandlers[self] = func
end

function lib.Implement(self)
	for k,v in pairs(lib) do
		self[k] = v
	end
end
gEvents = events
frame:SetScript("OnEvent", function(self, event, ...)
	for frame, func in pairs(events[event]) do
		if(frame ~= "count" and (not metahandlers[self] or metahandlers[self](self, event, ...))) then
			func(frame, event, ...)
		end
	end
end)