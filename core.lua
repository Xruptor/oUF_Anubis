local bartexture = 'Interface\\AddOns\\oUF_Anubis\\texture\\statusbar'
local bufftexture = 'Interface\\AddOns\\oUF_Anubis\\texture\\buff'
local _, PlayerClass = UnitClass("player")
local petAdjust = 0

--Settings
local showPortait = true

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

local function layout(self, unit)

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
	self.Health:SetPoint'TOP'
	self.Health:SetPoint'LEFT'
	self.Health:SetPoint'RIGHT'

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

	if unit == 'player' or unit == 'target' then
		self:SetAttribute('initial-height', 20)
	    self:SetAttribute('initial-width', 250)

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
	
		local curhealth = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
		curhealth:SetPoint('BOTTOM', self, 0, -20)
		self:Tag(curhealth,'[shortcurhp]')
	
		local perhealth = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
		perhealth:SetPoint('BOTTOMLEFT', self, 0, -20)
		self:Tag(perhealth,'[perhp]%')

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

		self.Castbar = CreateFrame('StatusBar', nil, self)
		self.Castbar:SetBackdrop({bgFile = 'Interface\ChatFrame\ChatFrameBackground', insets = {top = -3, left = -3, bottom = -3, right = -3}})
		self.Castbar:SetBackdropColor(0, 0, 0)
		self.Castbar:SetWidth(254)
		self.Castbar:SetHeight(8)
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
		
	end

	if unit == 'player' then
		self.Castbar:SetPoint('CENTER', oUF.units.player, 'CENTER', 0, -80)
		self.Castbar:SetStatusBarColor(1, 0.50, 0)
	end
	
	if unit == 'target' then
		self.Castbar:SetPoint('CENTER', oUF.units.target, 'CENTER', 0, -80)
		self.Castbar:SetStatusBarColor(0.80, 0.01, 0)
	end
	
	local unitnames = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
	self:Tag(unitnames,'[name]')

	if unit == 'target' then
		unitnames:SetPoint('LEFT', self, -1, 20)

		self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetHeight(16)
		self.RaidIcon:SetWidth(16)
		self.RaidIcon:SetPoint('TOP', self, 0, 9)
		self.RaidIcon:SetTexture'Interface\\TargetingFrame\\UI-RaidTargetingIcons'
	
		self.Buffs = CreateFrame('Frame', nil, self)
		self.Buffs.size = 20
		self.Buffs:SetHeight(self.Buffs.size)
		self.Buffs:SetWidth(self.Buffs.size * 5)
		self.Buffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', -2, 20)
		self.Buffs.initialAnchor = 'BOTTOMLEFT'
		self.Buffs['growth-y'] = 'TOP'
		self.Buffs.num = 20
		self.Buffs.spacing = 2

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

	if unit == 'target' then
		self.CPoints = {}
		for id = 1, MAX_COMBO_POINTS do
			self.CPoints[id] = CreateFrame('StatusBar', nil, self)

			if (id > 1) then
				self.CPoints[id]:SetPoint('TOPLEFT', self.CPoints[id-1], 'TOPRIGHT', 1, 0)
			else
				self.CPoints[id]:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', -1, -25)
			end

			self.CPoints[id]:SetStatusBarTexture(bartexture)
			self.CPoints[id]:SetStatusBarColor(1, 0.8, 0)
			self.CPoints[id]:SetHeight(6)
			self.CPoints[id]:SetWidth(250 / MAX_COMBO_POINTS)
		end

		self.CPoints.unit = PlayerFrame.unit
		self:RegisterEvent('UNIT_COMBO_POINTS', updateCombo)
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
	
	if(PlayerClass == "DEATHKNIGHT") then
		if unit == 'player' then
			self.Runes = CreateFrame("Frame", nil, self)
			for id = 1, 6 do
				self.Runes[id] = CreateFrame('StatusBar', nil, self)

				if (id > 1) then
					self.Runes[id]:SetPoint('TOPLEFT', self.Runes[id-1], 'TOPRIGHT', 1, 0)
				else
					self.Runes[id]:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', -1, -25)
				end

				self.Runes[id]:SetStatusBarTexture(bartexture)
				self.Runes[id]:SetStatusBarColor(1, 0.8, 0)
				self.Runes[id]:SetHeight(6)
				self.Runes[id]:SetWidth(248 / 6)
				
				self.Runes[id].bg = self.Runes[id]:CreateTexture(nil, "BORDER")
				self.Runes[id].bg:SetTexture(bartexture)
				self.Runes[id].bg:SetPoint("TOPLEFT", self.Runes[id], "TOPLEFT", -1, 1)
				self.Runes[id].bg:SetPoint("BOTTOMRIGHT", self.Runes[id], "BOTTOMRIGHT", 1, -1)
				self.Runes[id].bg.multiplier = 0.3
			end
		elseif unit == 'pet' then
			petAdjust = -10
		end
	end
		
end

oUF:RegisterStyle('oUF_Anubis', layout)
oUF:SetActiveStyle('oUF_Anubis')

oUF:Spawn('player'):SetPoint('CENTER', -200, -300)
oUF:Spawn('focus'):SetPoint('TOPLEFT', oUF.units.player, 0, 30)
oUF:Spawn('target'):SetPoint('CENTER', 200, -300)
oUF:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF.units.target, 0, 30)
oUF:Spawn('pet'):SetPoint('BOTTOMLEFT', oUF.units.player, 0, -55 + petAdjust)