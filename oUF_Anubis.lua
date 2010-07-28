--special thanks to the creators of oUF_zp, oUF_lily, and oUF_Lumen

local bartexture = 'Interface\\AddOns\\oUF_Anubis\\texture\\statusbar'
local bufftexture = 'Interface\\AddOns\\oUF_Anubis\\texture\\buff'
local _, PlayerClass = UnitClass("player")
local petAdjust = 0 --don't touch

--Settings
local showPortait = true
local showPlayerCastBar = true
local showTargetBuffs = true
local maxNumTargetBuffs = 10
local playerCastBarAdjust = -60

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
	
local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub('(.)', string.upper, 1)

	if(unit == 'party' or unit == 'partypet') then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor', 0, 0)
	elseif(_G[cunit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[cunit..'FrameDropDown'], 'cursor', 0, 0)
	end
end

local function updateCombo(self, event, unit)
	if(unit == PlayerFrame.unit and unit ~= self.CPoints.unit) then
		self.CPoints.unit = unit
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

oUF.TagEvents['shortcurhp'] = 'UNIT_HEALTH'
oUF.Tags['shortcurhp'] = function(u) return shorthpval(UnitHealth(u)) end

oUF.TagEvents['shortcurpp'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE'
oUF.Tags['shortcurpp'] = function(u) return shorthpval(UnitPower(u)) end

oUF.TagEvents["c_unitinfo"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"
oUF.Tags["c_unitinfo"] = function(unit)

	local classInfo = UnitClassification(unit)
	local level = UnitLevel(unit)
	local lvlc = GetQuestDifficultyColor(level)
	local race = UnitRace(unit)
	
	local cType = UnitCreatureFamily(unit)
	if (not cType) then cType = '' end
	
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

oUF.Tags["c_unitname"] = function(unit)

	local level = UnitLevel(unit)
	local lvlc = GetQuestDifficultyColor(level)
	local name = UnitName(unit) or "Unknown"

	local str = ""

	if level <= 0 then level = "??" end
	
	if UnitIsFriend("player", unit) and not UnitIsPlayer(unit) then
		lvlc = GetQuestDifficultyColor(UnitLevel("player"))
	end
		
	if not UnitIsConnected(unit) then
		str = "??"
	else
		str = string.format("|cff%02x%02x%02x%s|r %s", lvlc.r*255, lvlc.g*255, lvlc.b*255, level, name)
	end
	
	return str
end

local auraIcon = function(self, button, icons)
	icons.showDebuffType = true
	
	button.icon:SetTexCoord(.07, .93, .07, .93)
	button.icon:SetPoint('TOPLEFT', button, 'TOPLEFT', 1, -1)
	button.icon:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -1, 1)
	
	button.overlay:SetTexture(bufftexture)
	button.overlay:SetTexCoord(0,1,0,1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end
	
	button.cd:SetReverse()
	button.cd:SetPoint('TOPLEFT', button, 'TOPLEFT', 2, -2) 
	button.cd:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -2, 2)
	button.cd.noCooldownCount = true     
end

---------------
---PLUGINS
---------------

local SmoothUpdate = function(self)
	if IsAddOnLoaded("oUF_Smooth") then
		self.Health.Smooth = true
		if self.Power then self.Power.Smooth = true end
		if self.Castbar then self:SmoothBar(self.Castbar) end
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
	end	
end

local TotemBar = function(self, unit)
	if IsAddOnLoaded("oUF_TotemBar") and PlayerClass == "SHAMAN" then
		if unit == 'player' then
			self.TotemBar = {} 
			for i = 1, 4 do 
				self.TotemBar[i] = CreateFrame("StatusBar", nil, self) 
				self.TotemBar[i]:SetHeight(6) 
				--self.TotemBar[i]:SetWidth(248/4 - 0.85)
				self.TotemBar[i]:SetWidth(248/4)
				
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
		petAdjust = -10
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
				self.Runes[i]:SetWidth(248 / 6)
				
				self.Runes[i].bg = self.Runes[i]:CreateTexture(nil, "BORDER")
				self.Runes[i].bg:SetTexture(bartexture)
				self.Runes[i].bg:SetPoint("TOPLEFT", self.Runes[i], "TOPLEFT", -1, 1)
				self.Runes[i].bg:SetPoint("BOTTOMRIGHT", self.Runes[i], "BOTTOMRIGHT", 1, -1)
				self.Runes[i].bg.multiplier = 0.3
			end
		end
		petAdjust = -10
	end
end

local HealComm4 = function(self)	
	if IsAddOnLoaded("oUF_HealComm4") then
		self.HealCommBar = CreateFrame('StatusBar', nil, self.Health)
		self.HealCommBar:SetHeight(15)
		self.HealCommBar:SetWidth(self.Health:GetWidth())
		self.HealCommBar:SetStatusBarTexture(self.Health:GetStatusBarTexture():GetTexture())
		self.HealCommBar:SetStatusBarColor(0, 0.8, 0, 0.5)
		self.HealCommBar:SetPoint('LEFT', self.Health, 'LEFT')
		self.allowHealCommOverflow = false
		self.HealCommOthersOnly = false
	end
end

---------------
---LAYOUT
---------------

local function layout(self, unit)
	petAdjust = 0
	castBarAdjust = 0
	
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
	
	if unit ~= 'player' then
		self.disallowVehicleSwap = true
	end
	
	local unitnames = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
	if unit == 'target' or unit == 'player' then
		self:Tag(unitnames,'[c_unitname]')
	else
		self:Tag(unitnames,'[name]')
	end
	
	local unitinfo = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
	self:Tag(unitinfo,'[c_unitinfo]')

	if unit == 'player' or unit == 'target' then
		self:SetAttribute('initial-height', 20)
	    self:SetAttribute('initial-width', 250)

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
				if(not UnitIsConnected(unit) and unit == 'target') then
					health.hTag:SetText(0)
					health.pTag:SetText("offline")
					health.pTag:SetTextColor(.8,.8,.8)
				elseif(UnitIsGhost(unit) and unit == "target") then
					health.hTag:SetText(0)
					health.pTag:SetText("ghost")
					health.pTag:SetTextColor(.8,.8,.8)
				elseif(UnitIsDead(unit) and unit == "target") then
					health.hTag:SetText(0)
					health.pTag:SetText("dead")
					health.pTag:SetTextColor(.7,.7,.7)
				end
			end
		end
		
		local healthbg = self.Health:CreateTexture(nil, 'BORDER')
		healthbg:SetPoint('CENTER', curhealth, 'CENTER', 1, 0)
		healthbg:SetTexture(bartexture)
		healthbg:SetWidth(254)
		healthbg:SetHeight(13)
		healthbg:SetVertexColor(0, 0, 0, 0.5)

		local curpower = self.Power:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
		curpower:SetPoint('BOTTOMRIGHT', self, 0, -20)
		curpower.frequentUpdates = 0.1
		self:Tag(curpower,'[shortcurpp]')

		if (unit == 'player' and showPlayerCastBar) or unit == 'target' then
			self.Castbar = CreateFrame('StatusBar', nil, self)
			self.Castbar:SetBackdrop({bgFile = 'Interface\ChatFrame\ChatFrameBackground', insets = {top = -3, left = -3, bottom = -3, right = -3}})
			self.Castbar:SetBackdropColor(0, 0, 0)
			self.Castbar:SetWidth(254)
			self.Castbar:SetHeight(10)
			self.Castbar:SetStatusBarTexture(bartexture)
		
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
		
		if showPortait then
			self.Portrait = CreateFrame('PlayerModel', nil, self)
			self.Portrait:SetWidth(40)
			self.Portrait:SetHeight(40)
			if unit == 'target' then
			  self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
			else
			  self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
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

	if unit == 'player' then
		if self.Castbar and showPlayerCastBar then
			self.Castbar:SetStatusBarColor(1, 0.50, 0)
			self.Castbar:SetPoint('CENTER', oUF.units.player, 'CENTER', 0, playerCastBarAdjust)
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
		
		--pvp icon
		self.PvP = self.Health:CreateTexture(nil, "OVERLAY")
		self.PvP:SetHeight(30)
		self.PvP:SetWidth(30)
		self.PvP:SetPoint("CENTER", self, "TOPRIGHT", 4, -3)
		
	end

	if unit == 'target' then
		self.Castbar:SetStatusBarColor(0.80, 0.01, 0)
		self.Castbar:SetPoint('CENTER', oUF.units.target, 'CENTER', 0, playerCastBarAdjust + -35)
		
		--pvp icon
		self.PvP = self.Health:CreateTexture(nil, "OVERLAY")
		self.PvP:SetHeight(30)
		self.PvP:SetWidth(30)
		self.PvP:SetPoint("CENTER", self, "TOPRIGHT", 4, -3)
		
		if showTargetBuffs then
			self.Buffs = CreateFrame('Frame', nil, self)
			self.Buffs.size = 20
			self.Buffs:SetHeight(self.Buffs.size)
			self.Buffs:SetWidth(self.Buffs.size * 5)
			self.Buffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', -2, 5)
			self.Buffs.initialAnchor = 'BOTTOMLEFT'
			self.Buffs['growth-y'] = 'TOP'
			self.Buffs.num = maxNumTargetBuffs
			self.Buffs.spacing = 2
		end

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
			self.CPoints[i]:SetWidth(250 / MAX_COMBO_POINTS)
		end

		self.CPoints.unit = PlayerFrame.unit
		self:RegisterEvent('UNIT_COMBO_POINTS', updateCombo)
		
		self.Debuffs = CreateFrame('Frame', nil, self)
		self.Debuffs.size = 20
		self.Debuffs:SetHeight(self.Debuffs.size)
		self.Debuffs:SetWidth(self.Debuffs.size * 12)
		self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -33)
		self.Debuffs.initialAnchor = 'TOPLEFT'
		self.Debuffs['growth-y'] = 'DOWN'
		self.Debuffs.num = 11
		self.Debuffs.spacing = 2
		
	end
	
	if unit == 'focus' or unit == 'targettarget' then
	    self:SetAttribute('initial-height', 12)
	    self:SetAttribute('initial-width', 100)
		unitnames:SetPoint('LEFT', self, 0, 0)
		unitnames:SetWidth(90)
		unitnames:SetHeight(10)
	end
	self.PostCreateAuraIcon = auraIcon
	
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
	
	--plugins and additonal bars
	RuneBar(self, unit)
	TotemBar(self, unit)
	SmoothUpdate(self)
	HealComm4(self)

	--do positional updates based on bars and pet frame
	if unit == 'player' and showPlayerCastBar then
	
		if petAdjust ~= 0 then
			self.Castbar.adjust = playerCastBarAdjust + petAdjust
			self.Castbar:SetPoint('CENTER', oUF.units.player, 'CENTER', 0, playerCastBarAdjust + petAdjust)
		else
			self.Castbar.adjust = playerCastBarAdjust
		end
		
		local swapPosition = function(Castbar, unit, name, rank, text, castid)
			if unit == 'player' then
				if oUF.units.pet and oUF.units.pet:IsVisible() then
					self.Castbar:SetPoint('CENTER', oUF.units.player, 'CENTER', 0, Castbar.adjust + -40)
				else
					self.Castbar:SetPoint('CENTER', oUF.units.player, 'CENTER', 0, Castbar.adjust)
				end
			end
		end
		
		-- PostCast Start Function
		self.Castbar.PostCastStart = swapPosition
		self.Castbar.PostChannelStart = swapPosition

	end
	
end

oUF:RegisterStyle('oUF_Anubis', layout)
oUF:SetActiveStyle('oUF_Anubis')

oUF:Spawn('player'):SetPoint('CENTER', -200, -300)
oUF:Spawn('focus'):SetPoint('TOPLEFT', oUF.units.player, 0, 30)
oUF:Spawn('target'):SetPoint('CENTER', 200, -300)
oUF:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF.units.target, 0, 30)
oUF:Spawn('pet'):SetPoint('BOTTOMLEFT', oUF.units.player, 0, -55 + petAdjust)