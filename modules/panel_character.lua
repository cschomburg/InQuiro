local IQ = InQuiro
local char = IQ:CreateTabDialog(CHARACTER)
char.ShowEquip = true

local function HexToRGB(hex)
	local rhex, ghex, bhex = hex:sub(1, 2), hex:sub(3, 4), hex:sub(5, 6)
	return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

local StatEntryOrder = {
	{ name = PLAYERSTAT_BASE_STATS, stats = {"STR", "AGI", "STA", "INT", "SPI", "ARMOR"} },
	{ name = HEALTH.." & "..MANA, stats = {"HP", "MP", "HP5", "MP5"} },
	{ name = MELEE.." & "..RANGED, stats = {"AP", "RAP", "APFERAL", "CRIT", "HIT", "HASTE", "WPNDMG", "RANGEDDMG", "ARMORPENETRATION", "EXPERTISE"} },
	{ name = PLAYERSTAT_SPELL_COMBAT, stats = {"HEAL", "SPELLDMG", "ARCANEDMG", "FIREDMG", "NATUREDMG", "FROSTDMG", "SHADOWDMG", "HOLYDMG", "SPELLCRIT", "SPELLHIT", "SPELLHASTE", "SPELLPENETRATION"} },
	{ name = PLAYERSTAT_DEFENSES, stats = {"DEFENSE", "DODGE", "PARRY", "BLOCK", "BLOCKVALUE", "RESILIENCE"} },
}

local abbr = setmetatable({
	["STR"] = "Str",
	["INT"] = "Int",
	["STA"] = "Stam",
	["SPI"] = "Spi",
	["AGI"] = "Agi",

	["SPELLPOWER"] = "%s spell",
	["ATTACKPOWER"] = "%s ap",
	["ATTACKPOWERFERAL"] = "%s feral ap",
	["CR_CRIT"] = "%s crit",
	["CR_HASTE"] = "%s haste",
	["CR_HIT"] = "%s hit",
	["SPELLPEN"] = "%s spellpen",
	["CR_ARMOR_PENETRATION"] = "%s armorpen",

	["MANAREG"] = "%s mp5",
	["HEALTHREG"] = "%s hp5",
	["MANA"] = "+%s mana",
	["HEALTH"] = "+%s health",

	["BASE_ARMOR"] = "%s armor",
	["CR_RESILIENCE"] = "%s resi",
	["CR_DEFENSE"] = "%s def",
	["CR_DODGE"] = "%s dodge",
	["CR_PARRY"] = "%s parry",
	["CR_BLOCK"] = "%s block",
	["CR_EXPERTISE"] = "%s expert",

	["RUNSPEED"] = "+%s%% run",
	["FISHING"] = "+%s fish",
	["MINING"] = "+%s mine",
	["HERBALISM"] = "+%s herb",
	["SKINNING"] = "+%s skin",
}, {__call = function(t,k) return t[k] or k end })

local colors = setmetatable({
	["STR"] = "ff9900",
	["AGI"] = "33ff33",
	["INT"] = "99aaff",
	["SPI"] = "ffff00",
}, {__call = function(t,k) return HexToRGB(t[k] or "ffffff") end})

local stats = {
	["base"] = { "STA", "STR", "AGI", "INT", "SPI" },
	["resist"] = { "FIRERES", "NATURERES", "ARCANERES", "FROSTRES", "SHADOWRES", "HOLYRES" },
	["attack"] = { "SPELLPOWER", "ATTACKPOWER", "ATTACKPOWERFERAL", "CR_CRIT", "CR_HASTE", "CR_HIT", "SPELLPEN", "CR_EXPERTISE", "CR_ARMOR_PENETRATION" },
	["reg"] = { "MANAREG", "HEALTHREG", "MANA", "HEALTH"},
	["def"] = { "BASE_ARMOR", "CR_RESILIENCE", "CR_DEFENSE", "CR_DODGE", "CR_PARRY", "CR_BLOCK", "SNARERES" },
	["prof"] = { "RUNSPEED", "FISHING", "MINING", "HERBALISM", "SKINNING"},
}

local statTables = {}
local function createStatTable(name, invert)
	local table = {}
	local first, prev
	local aPoint = invert and "BOTTOMLEFT" or "TOPLEFT"
	local bPoint = invert and "TOPLEFT" or "BOTTOMLEFT"
	for i=1, #stats[name] do
		local text = char:CreateFontString(nil, "OVERLAY", i==1 and "GameFontHighlight" or "GameFontHighlightSmall")
		if(prev) then
			text:SetPoint(aPoint, prev, bPoint, i==2 and 10 or 0, invert and 2 or -2)
		end
		table[#table+1] = text
		prev = text
	end
	statTables[name] = table
	return table[1]
end

--[[ ##################
	Layout
#################### ]]
local prev
for i = 1, #stats.resist do
	local resist = CreateFrame("Frame", nil, char)
	resist:SetWidth(32)
	resist:SetHeight(27)
	resist:SetScale(.8)

	resist.texture = resist:CreateTexture(nil,"BACKGROUND")
	resist.texture:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-ResistanceIcons]])
	resist.texture:SetTexCoord(0,1,(i - 1) * 0.11328125 + 0.016,i * 0.11328125)
	resist.texture:SetAllPoints()

	resist.value = resist:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	resist.value:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
	resist.value:SetPoint("BOTTOM", 1, 3)
	resist.value:SetTextColor( 1, 1, 0)

	if(not prev) then
		resist:SetPoint("BOTTOMLEFT", 124, 58)
	else
		resist:SetPoint("LEFT", prev ,"RIGHT")
	end
	prev = resist

	char["Resist"..i] = resist
end

for i=1, #stats.base do
	local stat = stats.base[i]
	local text = char:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local caption = char:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	local r,g,b = colors(stat)
	text.stat = stat

	caption:SetText(abbr(stat))
	text:SetTextColor(r,g,b)
	caption:SetTextColor(r,g,b)

	text:SetPoint("TOPLEFT", 15+45*i, -40)
	caption:SetPoint("BOTTOMLEFT", text, "TOPLEFT", -5, 2)
	char["Base"..i] = text
end

createStatTable("attack"):SetPoint("TOPLEFT", 190, -80)
createStatTable("def"):SetPoint("TOPLEFT", 50, -80)
createStatTable("reg"):SetPoint("TOPLEFT", 50, -180)
createStatTable("prof"):SetPoint("TOPLEFT", 190, -180)

function char:OnInspect()
	-- Base stats
	for i, stat in pairs(stats.base) do
		self["Base"..i]:SetText(IQ.Bonuses[stat] or "0")
	end

	-- Resistances
	for i, stat in pairs(stats.resist) do
		local button = self["Resist"..i]
		local bonus = IQ.Bonuses[stat]
		button.value:SetText(bonus)
		button:SetAlpha(bonus and 1 or 0.5)
	end

	-- Stat tables
	for name, table in pairs(statTables) do
		local row = 1
		local nStats = stats[name]
		for i=1, #nStats do
			local stat = nStats[i]
			local bonus = IQ.Bonuses[stat]
			if(bonus) then
				table[row]:SetText("|cffaaffaa"..abbr(stat):format("|r"..bonus.."|cffaaffaa").."|r")
				row = row+1
			end
		end
		for i=row, #table do
			table[i]:SetText("")
		end
	end
end