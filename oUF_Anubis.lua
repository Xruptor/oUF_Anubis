--special thanks to the creators of oUF_zp (thatguyzp), oUF_lily (Haste), and oUF_Lumen (neverg), lyn and p3lim's work.
--a very special thanks to thatguyzp whom without his layout this wouldn't have been possible :)  Thanks again!

local f = CreateFrame("frame",nil,UIParent)
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local bartexture = 'Interface\\AddOns\\oUF_Anubis\\texture\\statusbar'
local bufftexture = 'Interface\\AddOns\\oUF_Anubis\\texture\\buff'
local _, PlayerClass = UnitClass("player")
local pluginBarAdjust = 0 --don't touch

--Settings
--I'm NOT responsible for anything that gets broken visually if you edit these settings.
--If you are compelled to edit these settings, then do so at your own risk.  I WILL NOT PROVIDE ASSISTANCE!!!
local setScaleVal = 1
local playerTargetWidth = 220
local enableShortName = true
local shortNameLength = 15
local enablePartyFrames = true
local enablePartyPets = true
local showPlayerPortait = true
local showTargetPortait = true
local showPartyPortait = true
local showPlayerCastBar = false
local showTargetCastBar = true
local showTargetBuffs = true
local showTargetDebuffs = true
local maxNumTargetBuffs = 10
local maxNumTargetDebuffs = 40
local targetDebuffSize = 20
local targetBuffSize = 20
local playerCastBarPos = -60
local targetCastBarPos = -62
local spellRangeAlpha = 0.6
local partyFramesYOffset = -50
local partyPetXOffset = 118
local showBuffDebuffCooldowns = true

--enable oUF_CombatFeedback on the following frames
local cfs = {
	["player"] = true,
	["target"] = true,
	["pet"] = false,
	["focus"] = true,
	["targettarget"] = false,
	["party"] = true,
	["partypets"] = false,
}

oUF.colors.power = {
	["MANA"] = {26/255, 139/255, 255/255 },
	["RAGE"] = {255/255, 26/255, 48/255 },
	["FOCUS"] = {255/255, 150/255, 26/255 },
	["ENERGY"] = {255/255, 225/255, 26/255 },
	["HAPPINESS"] = {0.00, 1.00, 1.00 },
	["RUNES"] = {0.50, 0.50, 0.50 },
	["RUNIC_POWER"] = {0.00, 0.82, 1.00 },
	["AMMOSLOT"] = {0.80, 0.60, 0.00 },
	["FUEL"] = {0.0, 0.55, 0.5 },
}

oUF.colors.happiness = {
	[1] = {182/225, 34/255, 32/255},
	[2] = {220/225, 180/225, 52/225},
	[3] = {143/255, 194/255, 32/255},
}

oUF.colors.reaction = {
	[1] = {182/255, 34/255, 32/255},
	[2] = {182/255, 34/255, 32/255},
	[3] = {182/255, 92/255, 32/255},
	[4] = {220/225, 180/255, 52/255},
	[5] = {143/255, 194/255, 32/255},
	[6] = {143/255, 194/255, 32/255},
	[7] = {143/255, 194/255, 32/255},
	[8] = {143/255, 194/255, 32/255},
}

oUF.colors.smooth = { 1, 0, 0, 1, 1, 0, 1, 1, 1}
oUF.colors.runes = {{0.77, 0.12, 0.23};{0.70, 0.85, 0.20};{0.14, 0.50, 1};{.70, .21, 0.94};}

----------------------
-- Local Functions  --
----------------------

SlashCmdList['OUF_ANUBIS'] = function(s)
	for i, frame in ipairs(oUF.objects) do
		if frame.CastBar_Anchor then
			if frame.CastBar_Anchor:IsMovable() then
				frame.CastBar_Anchor:SetMovable(false)
				frame.CastBar_Anchor:EnableMouse(false)
				frame.CastBar_Anchor:SetBackdrop(nil)
			else
				frame.CastBar_Anchor:SetMovable(true)
				frame.CastBar_Anchor:EnableMouse(true)
				frame.CastBar_Anchor:SetBackdrop({
						bgFile = "Interface/Tooltips/UI-Tooltip-Background",
				})
				frame.CastBar_Anchor:SetBackdropColor(0.75,0,0,1)
				frame.CastBar_Anchor:SetBackdropBorderColor(0.75,0,0,1)
			end
		end
	end		
end
SLASH_OUF_ANUBIS1 = '/anubis'

function f:SaveLayout(frame)
	if not AnubisDB then AnubisDB = {} end
	local opt = AnubisDB[frame] or nil;

	if opt == nil then
		AnubisDB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["PosX"] = 0,
			["PosY"] = 0,
		}
		opt = AnubisDB[frame];
	end

	local f = getglobal(frame);
	local scale = f:GetEffectiveScale();
	opt.PosX = f:GetLeft() * scale;
	opt.PosY = f:GetTop() * scale;
end

function f:RestoreLayout(frame)
	if not AnubisDB then return end
	
	local f = getglobal(frame);
	local opt = AnubisDB[frame] or nil;
	if not opt then return end
	
	local x = opt.PosX;
	local y = opt.PosY;
	local s = f:GetEffectiveScale();

	if not x or not y then
		f:ClearAllPoints();
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
		return 
	end

	--calculate the scale
	x,y = x/s,y/s;

	--set the location
	f:ClearAllPoints();
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y);
end

function f:CreateAnchor(name, parent, width, height)
	local frameAnchor = CreateFrame("Frame", name, parent)
	
	frameAnchor:SetWidth(width)
	frameAnchor:SetHeight(height)
	frameAnchor:SetMovable(false)
	frameAnchor:SetClampedToScreen(true)
	frameAnchor:SetFrameStrata("DIALOG")
	frameAnchor:EnableMouse(false)
	
	frameAnchor:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	})
	frameAnchor:SetBackdropColor(0.75,0,0,1)
	frameAnchor:SetBackdropBorderColor(0.75,0,0,1)

	frameAnchor:SetScript("OnMouseDown", function(frame, button)
		if frame:IsMovable() then
			frame.isMoving = true
			frame:StartMoving()
		end
	end)

	frameAnchor:SetScript("OnMouseUp", function(frame, button) 
		if( frame.isMoving ) then
			frame.isMoving = nil
			frame:StopMovingOrSizing()
			f:SaveLayout(frame:GetName())
		end
	end)

	f:RestoreLayout(name)
	
	return frameAnchor
end

function f:PLAYER_LOGIN()
	--Debuff and Buff Debug Locations
	-- local sample_buff_icon   = [[Interface\Icons\Spell_ChargePositive]]
	-- local sample_debuff_icon = [[Interface\Icons\Spell_ChargeNegative]]
	-- f.oldUnitAura = _G["UnitAura"]
	-- UnitAura = function(unit, index, filter, ...)
		-- return GetSpellInfo(28062), "Rank 2", sample_buff_icon, 0, "Magic", 0, 0, "player", nil, 1, 28062
	-- end
	
	for i, frame in ipairs(oUF.objects) do
		if frame.SmoothBar then
			--Smooth Update doesn't fully hook until after player login
			SmoothUpdate(frame)
		end
		if frame.CastBar_Anchor then
			f:RestoreLayout(frame.CastBar_Anchor:GetName())
		end
	end

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

----------------------
----------------------
----------------------

local menu = function(self)
	--local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub('(.)', string.upper, 1)

	if (cunit == "Vehicle") then
		cunit = "Pet"
	end
	
	if(_G[cunit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[cunit..'FrameDropDown'], 'cursor')
	elseif(self.unit:match('^party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	elseif(self.unit:match('^raid')) then
		self.name = unit
		RaidGroupButton_ShowMenu(self)
	end
	
end

local function updateCombo(self, event, unit)
	if(unit == PlayerFrame.unit and unit ~= self.CPoints.unit) then
		self.CPoints.unit = unit
	end
	--adjust the debuffs depending if the druid is in cat form or not
	if PlayerClass == "DRUID" then
		local icon, name, active, castable = GetShapeshiftFormInfo(3)
		if active and self.Debuffs and not self.Debuffs.moved then
			self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -35)
			self.Debuffs.moved = true
		elseif self.Debuffs and self.Debuffs.moved then
			self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -25)
			self.Debuffs.moved = false
		end
	end
end

local function shorthpval(value)
	if(value >= 1e6) then
		return string.format('%.1fm', value / 1e6)
	elseif(value >= 1e4) then
		return string.format('%.1fk', value / 1e3)
	elseif value >= 1e3 then
		return string.format('%.1fk', value / 1e3)
	else
		return value
	end
end

local function UpdateDruidPower(self)
	local bar = self.DruidPower
	local num, str = UnitPowerType('player')
	local min = UnitPower('player', (num ~= 0) and 0 or 3)
	local max = UnitPowerMax('player', (num ~= 0) and 0 or 3)

	bar:SetMinMaxValues(0, max)

	if(min ~= max) then
		bar:SetValue(min)
		bar:SetAlpha(1)

		if(num ~= 0) then
			bar:SetStatusBarColor(unpack(oUF.colors.power['MANA']))
		else
			bar:SetStatusBarColor(unpack(oUF.colors.power['ENERGY']))
		end
	else
		bar:SetAlpha(0)
	end
end

local function UpdateMasterLooter(self)
	self.MasterLooter:ClearAllPoints()
	if((UnitInParty(self.unit) or UnitInRaid(self.unit)) and UnitIsPartyLeader(self.unit)) then
		self.MasterLooter:SetPoint('LEFT', self.Leader, 'RIGHT')
	else
		self.MasterLooter:SetPoint("CENTER", self, "TOPLEFT", 20, 3)
	end
end

local function repositionTargetCastbar(self, unit)
	if showTargetCastBar and self.visibleDebuffs then
		local offSet = ceil(self.visibleDebuffs / floor(0.05 * playerTargetWidth)) * (targetDebuffSize + 2)
		if self:GetParent().CastBar_Anchor and (not AnubisDB or not AnubisDB[self:GetParent().CastBar_Anchor:GetName()]) then
			self:GetParent().CastBar_Anchor:ClearAllPoints()
			self:GetParent().CastBar_Anchor:SetPoint('CENTER', oUF.units.target, 'CENTER', 11, targetCastBarPos + -(offSet))
		end
	end
end

local shortName = function(str, i, dots)
	if not str then return end
	local strLen = str:len()
	if (strLen <= i) then
		return str
	else
		local len, pos = 0, 1
		while (pos <= strLen) and (len < i) do
			local px = str:byte(pos)
			if (px > 0 and px < 128) then
				pos = pos + 1
			elseif (px >= 192 and px < 224) then
				pos = pos + 2
			elseif (px >= 224 and px < 240) then
				pos = pos + 3
			elseif (px >= 240 and px < 248) then
				pos = pos + 4
			end
			len = len + 1
		end
		if (len >= i and pos <= strLen) then
			return str:sub(1, pos - 1)..(dots and '...' or '')
		else
			return str
		end
	end
end

oUF.TagEvents['shortcurhp'] = 'UNIT_HEALTH'
oUF.Tags['shortcurhp'] = function(u) return shorthpval(UnitHealth(u)) end

oUF.TagEvents['shortcurpp'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE'
oUF.Tags['shortcurpp'] = function(u) return shorthpval(UnitPower(u)) end

oUF.TagEvents["c_unitinfo"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"
oUF.Tags["c_unitinfo"] = function(unit)

	local classInfo = UnitClassification(unit)
	local level = UnitLevel(unit)
	local lvlc = GetQuestDifficultyColor(level)
	local race = UnitRace(unit) or 'Unknown'
	local cType = UnitCreatureFamily(unit) or ''

	local str = ""

	if classInfo == "worldboss" then
		str = string.format("|cff%02x%02x%02xBoss|r", 250, 20, 0)
	elseif classInfo == "eliterare" then
		str = "|cff0080FFRare|r Elite"
	elseif classInfo == "elite" then
		str = "Elite"
	elseif classInfo == "rare" then
		str = "|cff0080FFRare|r"
	else
		if not UnitIsConnected(unit) then
			str = "??"
		else
			if UnitIsPlayer(unit) then
				str = string.format("|cffc2c2c2%s", race)
			elseif UnitPlayerControlled(unit) then
				str = string.format("|cffc2c2c2%s|r", cType)
			end
		end		
	end
	return str
end

oUF.TagEvents["c_unitname"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_NAME_UPDATE"
oUF.Tags["c_unitname"] = function(unit)

	local level = UnitLevel(unit)
	local lvlc = GetQuestDifficultyColor(level)
	local name = UnitName(unit) or "Unknown"
	
	if enableShortName then
		name = shortName(name, shortNameLength, unit == 'target' or nil)
	end

	local str = ""

	if level <= 0 then level = "??" end
	
	if UnitIsFriend("player", unit) and not UnitIsPlayer(unit) then
		lvlc = GetQuestDifficultyColor(UnitLevel("player"))
	end
		
	if not UnitIsConnected(unit) then
		str = name
	else
		str = string.format("|cff%02x%02x%02x%s|r %s", lvlc.r*255, lvlc.g*255, lvlc.b*255, level, name)
	end
	
	return str
end

oUF.TagEvents["c_shortname"] = "UNIT_NAME_UPDATE"
oUF.Tags["c_shortname"] = function(unit)
	local name = UnitName(unit) or "Unknown"
	if enableShortName then
		name = shortName(name, shortNameLength, unit == 'target' or nil)
	end
	return name
end

oUF.Tags["afkdnd"] = function(unit)
	if unit then
		return not UnitIsConnected(unit) and "" or UnitIsAFK(unit) and " |cffffffff[AFK]|r " or UnitIsDND(unit) and " |cffffffff[DND]|r "
	end
end
oUF.TagEvents["afkdnd"] = "PLAYER_FLAGS_CHANGED"

local auraIcon = function(Auras, button)
	button.icon:SetTexCoord(.07, .93, .07, .93)
	button.icon:SetPoint('TOPLEFT', button, 'TOPLEFT', 1, -1)
	button.icon:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -1, 1)
	
	button.overlay:SetTexture(bufftexture)
	button.overlay:SetTexCoord(0,1,0,1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end
	
	button.cd:SetReverse()
	button.cd:SetPoint('TOPLEFT', button, 'TOPLEFT', 2, -2) 
	button.cd:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -2, 2)
	button.cd.noCooldownCount = showBuffDebuffCooldowns     
end

---------------
---PLUGINS
---------------

local SmoothUpdate = function(self)
	if IsAddOnLoaded("oUF_Smooth") then
		self.Health.Smooth = true
		if self.Power then self.Power.Smooth = true end
		if self.SmoothBar then
			if self.Castbar then self:SmoothBar(self.Castbar) end
			if self.DruidPower then self:SmoothBar(self.DruidPower) end
			if self.HealCommBar then self:SmoothBar(self.HealCommBar) end
			if self.CPoints then
				for i = 1, MAX_COMBO_POINTS do
					self:SmoothBar(self.CPoints[i])
				end
			end
			if self.Runes then
				for i = 1, 6 do
					self:SmoothBar(self.Runes[i])
				end
			end
			if self.TotemBar then
				for i = 1, 4 do
					self:SmoothBar(self.TotemBar[i])
				end
			end
		end
	end	
end

local TotemBar = function(self, unit)
	if IsAddOnLoaded("oUF_TotemBar") and PlayerClass == "SHAMAN" then
		if unit == 'player' then
			self.TotemBar = {} 
			for i = 1, 4 do 
				self.TotemBar[i] = CreateFrame("StatusBar", nil, self) 
				self.TotemBar[i]:SetHeight(6) 
				self.TotemBar[i]:SetWidth(playerTargetWidth / 4.05)
				
				if (i > 1) then
					self.TotemBar[i]:SetPoint('TOPLEFT', self.TotemBar[i-1], 'TOPRIGHT', 1, 0)
				else
					self.TotemBar[i]:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', -1, -25)
				end
				
				self.TotemBar[i]:SetStatusBarTexture(bartexture) 
				self.TotemBar[i]:SetMinMaxValues(0, 1) 
				self.TotemBar[i].destroy = true 
		 
				self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER") 
				self.TotemBar[i].bg:SetTexture(bartexture)
				self.TotemBar[i].bg:SetPoint("TOPLEFT", self.TotemBar[i], "TOPLEFT", -1, 1)
				self.TotemBar[i].bg:SetPoint("BOTTOMRIGHT", self.TotemBar[i], "BOTTOMRIGHT", 1, -1)
				self.TotemBar[i].bg.multiplier = 0.25
			end
		end
		pluginBarAdjust = -10
	end
end

local RuneBar = function(self, unit)
	if PlayerClass == "DEATHKNIGHT" then
		if unit == 'player' then
			self.Runes = CreateFrame("Frame", nil, self)
			for i = 1, 6 do
				self.Runes[i] = CreateFrame('StatusBar', nil, self)

				if (i > 1) then
					self.Runes[i]:SetPoint('TOPLEFT', self.Runes[i-1], 'TOPRIGHT', 1, 0)
				else
					self.Runes[i]:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', -1, -25)
				end

				self.Runes[i]:SetStatusBarTexture(bartexture)
				self.Runes[i]:SetHeight(6)
				self.Runes[i]:SetWidth(playerTargetWidth / 6.05)
				
				self.Runes[i].bg = self.Runes[i]:CreateTexture(nil, "BORDER")
				self.Runes[i].bg:SetTexture(bartexture)
				self.Runes[i].bg:SetPoint("TOPLEFT", self.Runes[i], "TOPLEFT", -1, 1)
				self.Runes[i].bg:SetPoint("BOTTOMRIGHT", self.Runes[i], "BOTTOMRIGHT", 1, -1)
				self.Runes[i].bg.multiplier = 0.3
			end
		end
		pluginBarAdjust = -10
	end
end

local HealComm4 = function(self)	
	if IsAddOnLoaded("oUF_HealComm4") then
		self.HealCommBar = CreateFrame('StatusBar', nil, self.Health)
		self.HealCommBar:SetHeight(15)
		self.HealCommBar:SetWidth(playerTargetWidth)
		self.HealCommBar:SetStatusBarTexture(bartexture)
		self.HealCommBar:SetStatusBarColor(0, 0.8, 0, 0.5)
		self.HealCommBar:SetPoint('LEFT', self.Health, 'LEFT')
		self.allowHealCommOverflow = false
		self.HealCommOthersOnly = false
	end
end

local CombatFeed = function(self, unit)	
	if IsAddOnLoaded("oUF_CombatFeedback") then
		local unitIsParty = self:GetParent():GetName():match("oUF_Party")
		local unitIsPartyPet = unit and unit:find('partypet%d')
		if cfs[unit] or (unitIsParty and cfs.party) or (unitIsPartyPet and cfs.partypets) then
			self.CombatFeedbackText = self.Health:CreateFontString(nil, "OVERLAY")
			self.CombatFeedbackText:SetPoint("CENTER", self, "CENTER", 0, (unit ~= 'focus' and 3) or 0)
			self.CombatFeedbackText:SetFontObject(GameFontNormal)
		end
	end
end

local SpellRange = function(self, unit)
	if IsAddOnLoaded("oUF_SpellRange") then
		if unit ~= 'player' then
			self.SpellRange = {
			insideAlpha = 1,
			outsideAlpha = spellRangeAlpha
			}
		end
	end
end

local DruidBar = function(self, unit)
	if (unit == 'player' and PlayerClass == "DRUID") then
		self.DruidPower = CreateFrame('StatusBar', nil, self)
		self.DruidPower:SetPoint("TOPRIGHT", self.Health, 0, 20)
		self.DruidPower:SetStatusBarTexture(bartexture)
		self.DruidPower:SetHeight(5)
		self.DruidPower:SetWidth(playerTargetWidth / 2.8)
		self.DruidPower:SetAlpha(0)

		self.DruidPower.bg = self.DruidPower:CreateTexture(nil, "BORDER")
		self.DruidPower.bg:SetTexture(bartexture)
		self.DruidPower.bg:SetPoint("TOPLEFT", self.DruidPower, "TOPLEFT", -1, 1)
		self.DruidPower.bg:SetPoint("BOTTOMRIGHT", self.DruidPower, "BOTTOMRIGHT", 1, -1)
		self.DruidPower.bg:SetAlpha(0.3)
		self.DruidPower.bg:SetVertexColor(0, 0, 0, 0.3)
		self.DruidPower.bg.multiplier = 0.3

		self:RegisterEvent('UNIT_MANA', UpdateDruidPower)
		self:RegisterEvent('UNIT_ENERGY', UpdateDruidPower)
		self:RegisterEvent('PLAYER_LOGIN', UpdateDruidPower)
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateDruidPower)
	end
end

local PowerSpark = function(self, unit)
	if IsAddOnLoaded('oUF_PowerSpark') then
		if (unit == 'player' and self.Power) then
			self.Spark = self.Power:CreateTexture(nil, 'OVERLAY')
			self.Spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
			self.Spark:SetBlendMode('ADD')
			self.Spark:SetHeight(self.Power:GetHeight()*2)
			self.Spark:SetWidth(self.Power:GetHeight())
			self.Spark.manatick = true
		end
	end
end

-- oUF_Swing
--Make the bar veritile instead of horizontal
-- self.Swing:SetOrientation("VERTICAL")

---------------
---LAYOUT
---------------

local function layout(self, unit)
	pluginBarAdjust = 0

	local unitIsParty = self:GetParent():GetName():match("oUF_Party")
	local unitIsPartyPet = unit and unit:find('partypet%d')
	
	self.menu = menu
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	self:SetAttribute('*type2', 'menu')
	
	if unit == 'focus' then
		self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -2, left = -2, bottom = -5, right = -2}})
	else
		self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -2, left = -2, bottom = -5, right = -3}})
	end
	
	self:SetBackdropColor(0, 0, 0, 0.5)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetStatusBarTexture(bartexture)
	self.Health:SetHeight(15)

	self.Health:SetParent(self)
	self.Health:SetPoint('TOP')
	self.Health:SetPoint('LEFT')
	self.Health:SetPoint('RIGHT')

	self.Health.colorClass = true
	self.Health.colorTapping = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(bartexture)
	self.Health.bg:SetAlpha(0.3)
	
	self:SetScale(setScaleVal)
	
	if unit ~= 'player' then
		self.disallowVehicleSwap = true
	end
	
	local unitnames = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
	if unit == 'target' or unit == 'player' then
		self:Tag(unitnames,'[c_unitname][afkdnd]')
	elseif unitIsParty then
		self:Tag(unitnames,'[c_unitname]')
	else
		self:Tag(unitnames,'[c_shortname]')
	end
	
	local unitinfo = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
	self:Tag(unitinfo,'[c_unitinfo]')

	--player and target
	if unit == 'player' or unit == 'target' then
		self:SetAttribute('initial-height', 20)
		self:SetAttribute('initial-width', playerTargetWidth)
		
		self.Power = CreateFrame('StatusBar', nil, self)
		self.Power:SetStatusBarTexture(bartexture)
		self.Power:SetHeight(5)
		self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -1.45)

		self.Power:SetParent(self)
		self.Power:SetPoint('LEFT')
		self.Power:SetPoint('RIGHT')

		self.Power.colorPower = true
		self.Power.frequentUpdates = true

		self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetTexture(bartexture)
		self.Power.bg:SetAlpha(0.3)

		local curhealth = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
		curhealth:SetPoint('BOTTOM', self, 0, -20)
		self.Health.hTag = curhealth
		self:Tag(curhealth,'[shortcurhp]')
	
		local perhealth = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
		perhealth:SetPoint('BOTTOMLEFT', self, 0, -20)
		self.Health.pTag = perhealth
		self:Tag(perhealth,'[perhp]%')

		self.Health.PostUpdate = function(health, unit, min, max)
			if (not UnitIsConnected(unit)) or UnitIsDead(unit) or UnitIsGhost(unit) then
				health:SetValue(0)
				if(not UnitIsConnected(unit)) then
					health.hTag:SetText(0)
					health.pTag:SetText("Offline")
					health.pTag:SetTextColor(.8,.8,.8)
				elseif(UnitIsGhost(unit)) then
					health.hTag:SetText(0)
					health.pTag:SetText("Ghost")
					health.pTag:SetTextColor(.8,.8,.8)
				elseif(UnitIsDead(unit)) then
					health.hTag:SetText(0)
					health.pTag:SetText("Dead")
					health.pTag:SetTextColor(.7,.7,.7)
				end
			else
				health.pTag:SetTextColor(1,1,1)
			end
		end
		
		local healthbg = self.Health:CreateTexture(nil, 'BORDER')
		healthbg:SetPoint('CENTER', curhealth, 'CENTER', 1, 0)
		healthbg:SetTexture(bartexture)
		healthbg:SetWidth(playerTargetWidth + 4)
		healthbg:SetHeight(13)
		healthbg:SetVertexColor(0, 0, 0, 0.5)

		local curpower = self.Power:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
		curpower:SetPoint('BOTTOMRIGHT', self, 0, -20)
		curpower.frequentUpdates = 0.1
		self:Tag(curpower,'[shortcurpp]')

		if (unit == 'player' and showPlayerCastBar) or (unit == 'target' and showTargetCastBar) then
			self.CastBar_Anchor = f:CreateAnchor('oUF_Anubis_Castbar_'..unit, self, (playerTargetWidth - 15), 10)
			self.CastBar_Anchor:SetBackdrop(nil)
			
			self.Castbar = CreateFrame('StatusBar', nil, self.CastBar_Anchor)
			self.Castbar:SetBackdrop({bgFile = 'Interface\ChatFrame\ChatFrameBackground', insets = {top = -3, left = -3, bottom = -3, right = -3}})
			self.Castbar:SetBackdropColor(0, 0, 0)
			self.Castbar:SetWidth(playerTargetWidth - 15)
			self.Castbar:SetHeight(10)
			self.Castbar:SetStatusBarTexture(bartexture)
			self.Castbar:SetAllPoints(self.CastBar_Anchor)
		
			self.Castbar.bg = self.Castbar:CreateTexture(nil, 'BORDER')
			self.Castbar.bg:SetAllPoints(self.Castbar)
			self.Castbar.bg:SetTexture(bartexture)
			self.Castbar.bg:SetVertexColor(0,0,0,0.5)
			
			self.Castbar.Text = self.Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
			self.Castbar.Text:SetPoint('LEFT', self.Castbar, 0, 12)
			self.Castbar.Text:SetTextColor(1, 1, 1)
		
			self.Castbar.Time = self.Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallRight')
			self.Castbar.Time:SetPoint('RIGHT', self.Castbar, -3, 12)
			self.Castbar.Time:SetTextColor(1, 1, 1)
			
			self.Castbar.Icon = self.Castbar:CreateTexture(nil, 'ARTWORK')
			self.Castbar.Icon:SetTexCoord(0.1,0.9,0.1,0.9)
			self.Castbar.Icon:SetHeight(16)
			self.Castbar.Icon:SetWidth(16)
			self.Castbar.Icon:SetPoint("LEFT", self.Castbar, -19, 0)
		end
		
		if (unit == 'player' and showPlayerPortait) or (unit == 'target' and showTargetPortait) then
			self.Portrait = CreateFrame('PlayerModel', nil, self)
			self.Portrait:SetWidth(41)
			self.Portrait:SetHeight(41)
			if unit == 'target' then
				self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 1)
			else
				self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 1)
			end
			self.Portrait.bg = self.Portrait:CreateTexture(nil, "BORDER")
			self.Portrait.bg:SetTexture(bartexture)
			self.Portrait.bg:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", -1, 1)
			self.Portrait.bg:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMRIGHT", 1, -1)
			self.Portrait.bg:SetVertexColor(0,0,0,0.5)
		end
		
		unitinfo:SetJustifyH("LEFT")
		unitinfo:SetPoint('RIGHT', self, -3, 3)
		unitnames:SetPoint('LEFT', self, 3, 3)
		
		self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetHeight(16)
		self.RaidIcon:SetWidth(16)
		self.RaidIcon:SetPoint('TOP', self, 0, 10)
		self.RaidIcon:SetTexture'Interface\\TargetingFrame\\UI-RaidTargetingIcons'
		
	end
	
	--player
	if unit == 'player' then
		if self.Castbar and showPlayerCastBar then
			self.Castbar:SetStatusBarColor(1, 0.50, 0)
			self.CastBar_Anchor:SetPoint('CENTER', oUF.units.player, 'CENTER', 11, playerCastBarPos)
		end

		--resting while in city
		self.Resting = self.Health:CreateTexture(nil, "OVERLAY")
		self.Resting:SetHeight(20)
		self.Resting:SetWidth(20)
		self.Resting:SetPoint("CENTER", self, "TOPLEFT", 0, 3)

		--incombat indicator
		self.Combat = self.Health:CreateTexture(nil, "OVERLAY")
		self.Combat:SetHeight(20)
		self.Combat:SetWidth(20)
		self.Combat:SetPoint("CENTER", self, "TOPRIGHT", -20, 3)

		--party leader
		self.Leader = self.Health:CreateTexture(nil, 'OVERLAY')
		self.Leader:SetHeight(15)
		self.Leader:SetWidth(15)
		self.Leader:SetPoint("CENTER", self, "TOPLEFT", 20, 3)
		self.Leader:SetTexture('Interface\\GroupFrame\\UI-Group-LeaderIcon')
		
		--master looter
		self.MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
		self.MasterLooter:SetPoint('LEFT', self.Leader, 'RIGHT')
		self.MasterLooter:SetHeight(12)
		self.MasterLooter:SetWidth(12)
		self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', UpdateMasterLooter)
		self:RegisterEvent('PARTY_MEMBERS_CHANGED', UpdateMasterLooter)
		self:RegisterEvent('PARTY_LEADER_CHANGED', UpdateMasterLooter)
		
		--pvp icon
		self.PvP = self.Health:CreateTexture(nil, "OVERLAY")
		self.PvP:SetHeight(30)
		self.PvP:SetWidth(30)
		self.PvP:SetPoint("CENTER", self, "TOPRIGHT", 4, -3)
		
		self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetHeight(16)
		self.LFDRole:SetWidth(16)
		--self.doh:SetPoint('RIGHT', self.Combat, 'LEFT', 0, 2)
		self.LFDRole:SetPoint("LEFT", self, "RIGHT", 3, -2)
		self.LFDRole:SetTexture[[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]]
		self.LFDRole:SetTexCoord(20/64, 39/64, 1/64, 20/64)

	end

	--target
	if unit == 'target' then
		if showTargetCastBar then
			self.Castbar:SetStatusBarColor(0.80, 0.01, 0)
			self.CastBar_Anchor:SetPoint('CENTER', oUF.units.target, 'CENTER', 11, targetCastBarPos)
		end
		
		--pvp icon
		self.PvP = self.Health:CreateTexture(nil, "OVERLAY")
		self.PvP:SetHeight(30)
		self.PvP:SetWidth(30)
		self.PvP:SetPoint("CENTER", self, "TOPRIGHT", 4, -3)
		
		if showTargetBuffs then
			self.Buffs = CreateFrame('Frame', nil, self)
			self.Buffs.size = targetBuffSize
			self.Buffs:SetHeight(self.Buffs.size)
			self.Buffs:SetWidth(self.Buffs.size * 5)
			self.Buffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', -2, 5)
			self.Buffs.initialAnchor = 'BOTTOMLEFT'
			self.Buffs['growth-y'] = 'TOP'
			self.Buffs.num = maxNumTargetBuffs
			self.Buffs.spacing = 2
			self.Buffs.showDebuffType = false
			self.Buffs.PostCreateIcon = auraIcon
		end

		if PlayerClass == "ROGUE" or PlayerClass == "DRUID" then
			self.CPoints = {}
			for i = 1, MAX_COMBO_POINTS do
				self.CPoints[i] = CreateFrame('StatusBar', nil, self)

				if (i > 1) then
					self.CPoints[i]:SetPoint('TOPLEFT', self.CPoints[i-1], 'TOPRIGHT', 1, 0)
				else
					self.CPoints[i]:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', -1, -25)
				end

				self.CPoints[i]:SetStatusBarTexture(bartexture)
				self.CPoints[i]:SetStatusBarColor(1, 0.8, 0)
				self.CPoints[i]:SetHeight(6)
				self.CPoints[i]:SetWidth(playerTargetWidth / MAX_COMBO_POINTS)
				
				self.CPoints[i].bg = self.CPoints[i]:CreateTexture(nil, "BORDER") 
				self.CPoints[i].bg:SetTexture(bartexture)
				self.CPoints[i].bg:SetPoint("TOPLEFT", self.CPoints[i], "TOPLEFT", -1, 1)
				self.CPoints[i].bg:SetPoint("BOTTOMRIGHT", self.CPoints[i], "BOTTOMRIGHT", 1, -1)
				self.CPoints[i].bg:SetAlpha(0.3)
				self.CPoints[i].bg:SetVertexColor(0, 0, 0, 0.3)
				self.CPoints[i].bg.multiplier = 0.3
					
			end

			self.CPoints.unit = PlayerFrame.unit
			self:RegisterEvent('UNIT_COMBO_POINTS', updateCombo)
		end

		if showTargetDebuffs then
			self.Debuffs = CreateFrame('Frame', nil, self)
			self.Debuffs.size = targetDebuffSize
			self.Debuffs:SetHeight(self.Debuffs.size)
			self.Debuffs:SetWidth(self.Debuffs.size * floor(0.05 * playerTargetWidth))
			--move the debuffs if we are playing a rogue/druid
			if self.CPoints then
				self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -35)
				self.Debuffs.moved = true
			else
				self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -25)
				self.Debuffs.moved = false
			end
			self.Debuffs.initialAnchor = 'TOPLEFT'
			self.Debuffs['growth-y'] = 'DOWN'
			self.Debuffs.num = maxNumTargetDebuffs
			self.Debuffs.spacing = 2
			self.Debuffs.showDebuffType = true
			self.Debuffs.PostCreateIcon = auraIcon
			self.Debuffs.PostUpdate = repositionTargetCastbar
		end
	end
	
	if unit == 'focus' or unit == 'targettarget' then
		self:SetAttribute('initial-height', 12)
		self:SetAttribute('initial-width', 100)
		unitnames:SetPoint('LEFT', self, 0, 0)
		unitnames:SetWidth(90)
		unitnames:SetHeight(10)
	end
	
	--pet
	if unit == 'pet' then
		if PlayerClass == "HUNTER" then
			self.Health.colorReaction = false
			self.Health.colorClass = false
			self.Health.colorHappiness = true
		end
		
		self:SetAttribute('initial-height', 19)
		self:SetAttribute('initial-width', 100)
		unitnames:SetPoint('LEFT', self, 0, 2)
		unitnames:SetWidth(90)
		unitnames:SetHeight(10)
		
		self.Power = CreateFrame('StatusBar', nil, self)
		self.Power:SetStatusBarTexture(bartexture)
		self.Power:SetHeight(5)
		self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -1.45)

		self.Power:SetParent(self)
		self.Power:SetPoint'LEFT'
		self.Power:SetPoint'RIGHT'

		self.Power.colorPower = true
		self.Power.frequentUpdates = true

		self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetTexture(bartexture)
		self.Power.bg:SetAlpha(0.3)

	end
	
	--partypet
	if enablePartyFrames and enablePartyPets and unitIsPartyPet then
		if PlayerClass == "HUNTER" then
			self.Health.colorReaction = false
			self.Health.colorClass = false
			self.Health.colorHappiness = true
		end
		
		self:SetAttribute('initial-height', 20)
		self:SetAttribute('initial-width', 85)
		unitnames:SetPoint('LEFT', self, 0, 2)
		unitnames:SetWidth(90)
		unitnames:SetHeight(10)
		
		self.Power = CreateFrame('StatusBar', nil, self)
		self.Power:SetStatusBarTexture(bartexture)
		self.Power:SetHeight(5)
		self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -1.45)

		self.Power:SetParent(self)
		self.Power:SetPoint'LEFT'
		self.Power:SetPoint'RIGHT'

		self.Power.colorPower = true
		self.Power.frequentUpdates = true

		self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetTexture(bartexture)
		self.Power.bg:SetAlpha(0.3)
	end
	
	--party
	if enablePartyFrames and unitIsParty then
		self:SetAttribute('initial-height', 20)
		self:SetAttribute('initial-width', 155)

		self.Power = CreateFrame('StatusBar', nil, self)
		self.Power:SetStatusBarTexture(bartexture)
		self.Power:SetHeight(5)
		self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -1.45)

		self.Power:SetParent(self)
		self.Power:SetPoint('LEFT')
		self.Power:SetPoint('RIGHT')

		self.Power.colorPower = true
		self.Power.frequentUpdates = true

		self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetTexture(bartexture)
		self.Power.bg:SetAlpha(0.3)
		
		if (showPartyPortait) then
			self.Portrait = CreateFrame('PlayerModel', nil, self)
			self.Portrait:SetWidth(25)
			self.Portrait:SetHeight(25)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 1)

			self.Portrait.bg = self.Portrait:CreateTexture(nil, "BORDER")
			self.Portrait.bg:SetTexture(bartexture)
			self.Portrait.bg:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", -1, 1)
			self.Portrait.bg:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMRIGHT", 1, -1)
			self.Portrait.bg:SetVertexColor(0,0,0,0.5)
		end
		
		local curhealth = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
		curhealth:SetJustifyH("LEFT")
		curhealth:SetPoint('RIGHT', self, -3, 3)
		self.Health.hTag = curhealth
		self:Tag(curhealth,'[shortcurhp]')
		
		self.Health.PostUpdate = function(health, unit, min, max)
			if (not UnitIsConnected(unit)) or UnitIsDead(unit) or UnitIsGhost(unit) then
				health:SetValue(0)
				if(not UnitIsConnected(unit)) then
					health.hTag:SetText("Offline")
					health.hTag:SetTextColor(.8,.8,.8)
				elseif(UnitIsGhost(unit)) then
					health.hTag:SetText(0)
					health.hTag:SetText("Ghost")
					health.hTag:SetTextColor(.8,.8,.8)
				elseif(UnitIsDead(unit)) then
					health.hTag:SetText("Dead")
					health.hTag:SetTextColor(.7,.7,.7)
				end
			elseif UnitIsAFK(unit) then
				health.hTag:SetText("AFK")
				health.hTag:SetTextColor(.8,.8,.8)
			else
				health.hTag:SetTextColor(1,1,1)
			end
		end
		
		unitnames:SetPoint('LEFT', self, 3, 3)
		
		self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetHeight(16)
		self.RaidIcon:SetWidth(16)
		self.RaidIcon:SetPoint('TOP', self, 0, 10)
		self.RaidIcon:SetTexture'Interface\\TargetingFrame\\UI-RaidTargetingIcons'
		
		--incombat indicator
		self.Combat = self.Health:CreateTexture(nil, "OVERLAY")
		self.Combat:SetHeight(20)
		self.Combat:SetWidth(20)
		self.Combat:SetPoint("CENTER", self, "TOPRIGHT", -20, 3)

		--party leader
		self.Leader = self.Health:CreateTexture(nil, 'OVERLAY')
		self.Leader:SetHeight(15)
		self.Leader:SetWidth(15)
		self.Leader:SetPoint("CENTER", self, "TOPLEFT", 20, 3)
		self.Leader:SetTexture('Interface\\GroupFrame\\UI-Group-LeaderIcon')
		
		--master looter
		self.MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
		self.MasterLooter:SetPoint('LEFT', self.Leader, 'RIGHT')
		self.MasterLooter:SetHeight(12)
		self.MasterLooter:SetWidth(12)
		self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', UpdateMasterLooter)
		self:RegisterEvent('PARTY_MEMBERS_CHANGED', UpdateMasterLooter)
		self:RegisterEvent('PARTY_LEADER_CHANGED', UpdateMasterLooter)
		
		--pvp icon
		self.PvP = self.Health:CreateTexture(nil, "OVERLAY")
		self.PvP:SetHeight(30)
		self.PvP:SetWidth(30)
		self.PvP:SetPoint("CENTER", self, "TOPRIGHT", 4, -3)
		
		self.Debuffs = CreateFrame('Frame', nil, self)
		self.Debuffs.size = 20
		self.Debuffs:SetHeight(self.Debuffs.size)
		self.Debuffs:SetWidth(self.Debuffs.size * 15)
		self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -7)
		self.Debuffs.initialAnchor = 'TOPLEFT'
		self.Debuffs['growth-y'] = 'DOWN'
		self.Debuffs.num = 15
		self.Debuffs.spacing = 2
		self.Debuffs.showDebuffType = true
		self.Debuffs.PostCreateIcon = auraIcon
		
		self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetHeight(16)
		self.LFDRole:SetWidth(16)
		self.LFDRole:SetPoint("LEFT", self, "RIGHT", 3, -2)
		self.LFDRole:SetTexture[[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]]
		self.LFDRole:SetTexCoord(20/64, 39/64, 1/64, 20/64)
		
	end

	--plugins and additonal bars
	PowerSpark(self, unit)
	RuneBar(self, unit)
	TotemBar(self, unit)
	DruidBar(self, unit)
	HealComm4(self)
	CombatFeed(self, unit)
	SpellRange(self, unit)
	
	--do positional updates based on additional plugin bars
	if unit == 'player' and showPlayerCastBar and pluginBarAdjust ~= 0 then
		self.CastBar_Anchor:ClearAllPoints()
		self.CastBar_Anchor:SetPoint('CENTER', oUF.units.player, 'CENTER', 11, playerCastBarPos + pluginBarAdjust)
	end
	
end

oUF:RegisterStyle('oUF_Anubis', layout)
oUF:SetActiveStyle('oUF_Anubis')

oUF:Spawn('player'):SetPoint('CENTER', -200, -300)
oUF:Spawn('focus'):SetPoint('TOPLEFT', oUF.units.player, 0, 30)
oUF:Spawn('target'):SetPoint('CENTER', 200, -300)
oUF:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF.units.target, 0, 30)
oUF:Spawn('pet'):SetPoint('BOTTOMLEFT', oUF.units.player, 0, (tonumber(showPlayerCastBar and -27) or 0) + -70)

-- spawn party frame
if enablePartyFrames then
	local party = oUF:SpawnHeader("oUF_Party", nil, "custom [group:raid]hide;[group:party]show;hide", 	
	'showParty', true,
	'yOffset', partyFramesYOffset)
	party:SetPoint('TOPLEFT', UIParent, 40, -230)

	local partyToggle = CreateFrame("Frame")
	partyToggle:RegisterEvent("PLAYER_LOGIN")
	partyToggle:RegisterEvent("RAID_ROSTER_UPDATE")
	partyToggle:RegisterEvent("PARTY_LEADER_CHANGED")
	partyToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
	partyToggle:SetScript("OnEvent", function(self)
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			local numraid = GetNumRaidMembers()
			if numraid > 1 then
					party:Hide()
			else
					party:Show()
			end
		end
	end)

	if enablePartyPets then
		local pets = {} 
		pets[1] = oUF:Spawn('partypet1', 'oUF_PartyPet1') 
		pets[1]:SetPoint('TOPRIGHT', party, 'TOPRIGHT', partyPetXOffset, 0) 
		for i =2, 4 do 
			pets[i] = oUF:Spawn('partypet'..i, 'oUF_PartyPet'..i) 
			pets[i]:SetPoint('TOP', pets[i-1], 'BOTTOM', 0, partyFramesYOffset) 
		end
	end
end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end