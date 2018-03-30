-- create frame
pfNameplates = CreateFrame("Frame", nil, UIParent)
pfNameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
pfNameplates:RegisterEvent("UNIT_AURA")

pfNameplates.myhp = 0
pfNameplates.myhphalf = 0
pfNameplates.useHP = true -- thanks kronos
pfNameplates.loadframe = CreateFrame("Frame")
pfNameplates.loadframe:RegisterEvent("PLAYER_ENTERING_WORLD")
pfNameplates.loadframe:SetScript("OnEvent", function()
  pfNameplates.myhp = UnitHealthMax('player')
  pfNameplates.myhphalf = pfNameplates.myhp / 2
end)

local STANDARD_TEXT_FONT = "Interface\\AddOns\\HawkenPlates\\fonts\\Monda-Bold.ttf"
local ICON_CLASS = {
  ["DRUID"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_heavyMobile_small]],
  ["HUNTER"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_powershot_small]],
  ["MAGE"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_attackBoost_small]],
  ["PALADIN"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_heavyRegen_small]],
  ["PRIEST"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_repairAmplification_small]],
  ["ROGUE"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_stalker_small]],
  ["SHAMAN"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_heavyRegen_small]],
  ["WARLOCK"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_coolant_small]],
  ["WARRIOR"] = [[Interface\AddOns\HawkenPlates\img\small\icons_abilities_damageReduction_small]],
}

pfNameplates.mobs = {}
pfNameplates.targets = {}
pfNameplates.players = {}

-- catch all nameplates
pfNameplates.scanner = CreateFrame("Frame", "pfNameplateScanner", UIParent)
pfNameplates.scanner.objects = {}
pfNameplates.scanner:SetScript("OnUpdate", function()
  for _, nameplate in ipairs({WorldFrame:GetChildren()}) do
    if not nameplate.done and nameplate:GetObjectType() == "Button" then
      local regions = nameplate:GetRegions()
      if regions and regions:GetObjectType() == "Texture" and regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" then
        nameplate:Hide()
        nameplate:SetScript("OnShow", function() pfNameplates:CreateNameplate() end)
        nameplate:SetScript("OnUpdate", function() pfNameplates:UpdateNameplate() end)
        nameplate:SetScript("OnHide", function() pfNameplates:HideNameplate() end)
        nameplate:Show()
        table.insert(this.objects, nameplate)
        nameplate.done = true
      end
    end
  end
end)

-- Create Nameplate
function pfNameplates:CreateNameplate()
  local healthbar = this:GetChildren()
  local border, glow, name, level, levelicon , raidicon = this:GetRegions()
  
  this.longName = nil

  -- hide default plates
  border:Hide()

  -- remove glowing
  glow:Hide()
  glow:SetAlpha(0)
  glow.Show = function() return end

  if pfNameplates_config.players == "1" then
    if not pfNameplates.players[name:GetText()] or not pfNameplates.players[name:GetText()]["class"] then
      this:Hide()
    end
  end

  -- healthbar
  healthbar:SetStatusBarTexture("Interface\\AddOns\\HawkenPlates\\img\\bar")
  healthbar:ClearAllPoints()
  healthbar:SetPoint("TOP", this, "TOP", 0, tonumber(pfNameplates_config.vpos))
  healthbar:SetWidth(25)
  healthbar:SetHeight(5)

  if healthbar.bg == nil then
    healthbar.bg = healthbar:CreateTexture(nil, "BORDER")
    healthbar.bg:SetTexture(0,0,0,0.40)
    healthbar.bg:ClearAllPoints()
    healthbar.bg:SetPoint("CENTER", healthbar, "CENTER", 0, 0)
    healthbar.bg:SetWidth(healthbar:GetWidth() + 2)
    healthbar.bg:SetHeight(healthbar:GetHeight() + 2)
  end
  
  if healthbar.bgframe == nil then
	healthbar.bgframe = CreateFrame('Frame')
	healthbar.bgframe:ClearAllPoints()
	healthbar.bgframe:SetAllPoints(healthbar)
	healthbar.bgframe.stick = healthbar.bgframe:CreateTexture(nil, "BORDER")
	healthbar.bgframe.stick:SetTexture(255/255, 230/255, 0/255)
	healthbar.bgframe.stick:ClearAllPoints()
	healthbar.bgframe.stick:SetPoint("LEFT", healthbar, "RIGHT", 0, 0)
	healthbar.bgframe.stick:SetWidth(1)
	healthbar.bgframe.stick:SetHeight(healthbar:GetHeight())
  end
  healthbar.bgframe:Hide()
  
  healthbar.bgframe:SetBackdrop({
	edgeFile=[[Interface\Buttons\WHITE8X8]],
	edgeSize = 1,
  })
  healthbar.bgframe:SetBackdropBorderColor(255/255, 230/255, 0/255)
  
  if healthbar.chunks == nil then
    healthbar.chunks = {}
    for i = 1, 10 do
      healthbar.chunks[i] = healthbar:CreateTexture(nil, "OVERLAY")
      healthbar.chunks[i]:SetTexture(0,0,0,0.40)
      healthbar.chunks[i]:ClearAllPoints()
      healthbar.chunks[i]:SetPoint("LEFT", healthbar, "LEFT", 25 * i, 0)
      healthbar.chunks[i]:SetWidth(1)
      healthbar.chunks[i]:SetHeight(healthbar:GetHeight() + 2)
      healthbar.chunks[i]:Hide()
    end
  end

  healthbar.reaction = nil

  -- raidtarget
  raidicon:ClearAllPoints()
  raidicon:SetWidth(pfNameplates_config.raidiconsize)
  raidicon:SetHeight(pfNameplates_config.raidiconsize)
  --raidicon:SetPoint("CENTER", healthbar, "CENTER", 0, -5)
  raidicon:SetPoint("TOPRIGHT", healthbar, "LEFT", -healthbar:GetHeight(), healthbar:GetHeight() + 2)

  -- adjust font
  --name:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")
  name:SetFont(STANDARD_TEXT_FONT,14)
  name:ClearAllPoints()
  name:SetPoint("TOPLEFT", healthbar, "LEFT", 0, -10)
  level:Hide()
  --level:SetFont(STANDARD_TEXT_FONT,12, "OUTLINE")
  --level:ClearAllPoints()
  --level:SetPoint("RIGHT", healthbar, "LEFT", -1, 0)
  levelicon:ClearAllPoints()
  levelicon:SetPoint("RIGHT", healthbar, "LEFT", -1, 0)
  if levelicon:IsVisible() then
    this.boss = true
  else
    this.boss = nil
  end
  
  -- player class icon
  if healthbar.playerclass == nil then
    healthbar.playerclass = healthbar:CreateTexture(nil, "ARTWORK")
    healthbar.playerclass:ClearAllPoints()
    healthbar.playerclass:SetPoint("TOPRIGHT", healthbar, "LEFT", -healthbar:GetHeight(), healthbar:GetHeight() + 2)
    healthbar.playerclass:SetWidth(healthbar:GetHeight() * 5 + 2)
    healthbar.playerclass:SetHeight(healthbar:GetHeight() * 5 + 2)
    healthbar.playerclass:Hide()
  end
  
  -- show indicator for elite/rare mobs
  --[[if level:GetText() ~= nil then
    if pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "elite" and not string.find(level:GetText(), "+", 1) then
      level:SetText(level:GetText() .. "+")
    elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "rareelite" and not string.find(level:GetText(), "R+", 1) then
      level:SetText(level:GetText() .. "R+")
    elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "rare" and not string.find(level:GetText(), "R", 1) then
      level:SetText(level:GetText() .. "R")
    end
  end]]

  pfNameplates:CreateDebuffs(this)
  pfNameplates:CreateCastbar(healthbar)
  pfNameplates:CreateHP(healthbar)

  this.setup = true
end

function pfNameplates:HideNameplate()
	local healthbar = this:GetChildren()
	local min, max = healthbar:GetMinMaxValues()
	local cur = healthbar:GetValue()
	
	healthbar.previousValue = nil
	healthbar.bgframe:Hide()
	-- dead
	if pfNameplates_config.sound == "1" then
		if cur <= min then
			local file = {
				[[Grenade_Explosion_Concrete_1.ogg]],
				[[Grenade_Explosion_Concrete_2.ogg]],
				[[Grenade_Explosion_Concrete_3.ogg]],
				[[Explo_Death_Player_Hvt_sdlx_MONO_1a.ogg]],
				[[Explo_Death_Player_Hvt_sdlx_MONO_1b.ogg]],
				[[Explo_Death_Player_Lt_sdlx_MONO_1a.ogg]],
				[[Explo_Death_Player_Lt_sdlx_MONO_1b.ogg]],
				[[Explo_Death_Player_Med_sdlx_MONO_1a.ogg]],
				[[Explo_Death_Player_Med_sdlx_MONO_1b.ogg]]
			}
			PlaySoundFile([[Interface\AddOns\HawkenPlates\sound\explosion\]] .. file[random(1,9)])
		end
	end
	
end

function pfNameplates:CreateDebuffs(frame)
  if pfNameplates_config["showdebuffs"] ~= "1" then return end

  if frame.debuffs == nil then frame.debuffs = {} end
  for j=1, 16, 1 do
    if frame.debuffs[j] == nil then
      frame.debuffs[j] = this:CreateTexture(nil, "BORDER")
      frame.debuffs[j]:SetTexture(0,0,0,0)
      frame.debuffs[j]:ClearAllPoints()
      frame.debuffs[j]:SetWidth(12)
      frame.debuffs[j]:SetHeight(12)
      if j == 1 then
        frame.debuffs[j]:SetPoint("BOTTOMLEFT", healthbar, "TOPLEFT", 0, 3)
      elseif j <= 8 then
        frame.debuffs[j]:SetPoint("LEFT", frame.debuffs[j-1], "RIGHT", 1, 0)
      elseif j > 8 then
        frame.debuffs[j]:SetPoint("TOPLEFT", frame.debuffs[1], "BOTTOMLEFT", (j-9) * 13, -1)
      end
    end
  end
end

function pfNameplates:CreateCastbar(healthbar)
  -- create frames
  if healthbar.castbar == nil then
    healthbar.castbar = CreateFrame("StatusBar", nil, healthbar)
    healthbar.castbar:Hide()
    healthbar.castbar:SetWidth(110)
    healthbar.castbar:SetHeight(7)
    healthbar.castbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -5)
    healthbar.castbar:SetBackdrop({  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                                     insets = {left = -1, right = -1, top = -1, bottom = -1} })
    healthbar.castbar:SetBackdropColor(0,0,0,1)
    healthbar.castbar:SetStatusBarTexture("Interface\\AddOns\\HawkenPlates\\img\\bar")
    healthbar.castbar:SetStatusBarColor(.9,.8,0,1)

    if healthbar.castbar.bg == nil then
      healthbar.castbar.bg = healthbar.castbar:CreateTexture(nil, "BACKGROUND")
      healthbar.castbar.bg:SetTexture(0,0,0,0.90)
      healthbar.castbar.bg:ClearAllPoints()
      healthbar.castbar.bg:SetPoint("CENTER", healthbar.castbar, "CENTER", 0, 0)
      healthbar.castbar.bg:SetWidth(healthbar.castbar:GetWidth() + 3)
      healthbar.castbar.bg:SetHeight(healthbar.castbar:GetHeight() + 3)
    end

    if healthbar.castbar.text == nil then
      healthbar.castbar.text = healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      healthbar.castbar.text:SetPoint("RIGHT", healthbar.castbar, "LEFT")
      healthbar.castbar.text:SetNonSpaceWrap(false)
      healthbar.castbar.text:SetFontObject(GameFontWhite)
      healthbar.castbar.text:SetTextColor(1,1,1,.5)
      healthbar.castbar.text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    end

    if healthbar.castbar.spell == nil then
      healthbar.castbar.spell = healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      healthbar.castbar.spell:SetPoint("CENTER", healthbar.castbar, "CENTER")
      healthbar.castbar.spell:SetNonSpaceWrap(false)
      healthbar.castbar.spell:SetFontObject(GameFontWhite)
      healthbar.castbar.spell:SetTextColor(1,1,1,1)
      healthbar.castbar.spell:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    end

    if healthbar.castbar.icon == nil then
      healthbar.castbar.icon = healthbar.castbar:CreateTexture(nil, "BORDER")
      healthbar.castbar.icon:ClearAllPoints()
      healthbar.castbar.icon:SetPoint("BOTTOMLEFT", healthbar.castbar, "BOTTOMRIGHT", 5, 0)
      healthbar.castbar.icon:SetWidth(18)
      healthbar.castbar.icon:SetHeight(18)
    end

    if healthbar.castbar.icon.bg == nil then
      healthbar.castbar.icon.bg = healthbar.castbar:CreateTexture(nil, "BACKGROUND")
      healthbar.castbar.icon.bg:SetTexture(0,0,0,0.90)
      healthbar.castbar.icon.bg:ClearAllPoints()
      healthbar.castbar.icon.bg:SetPoint("CENTER", healthbar.castbar.icon, "CENTER", 0, 0)
      healthbar.castbar.icon.bg:SetWidth(healthbar.castbar.icon:GetWidth() + 3)
      healthbar.castbar.icon.bg:SetHeight(healthbar.castbar.icon:GetHeight() + 3)
    end
  end
end

function pfNameplates:CreateHP(healthbar)
  if pfNameplates_config.showhp == "1" and not healthbar.hptext then
    healthbar.hptext = healthbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    healthbar.hptext:SetPoint("RIGHT", healthbar, "RIGHT")
    healthbar.hptext:SetNonSpaceWrap(false)
    healthbar.hptext:SetFontObject(GameFontWhite)
    healthbar.hptext:SetTextColor(1,1,1,1)
    healthbar.hptext:SetFont(STANDARD_TEXT_FONT, 10)
  end
end

-- Update Nameplate
function pfNameplates:UpdateNameplate()
  if not this.setup then pfNameplates:CreateNameplate() return end

  local healthbar = this:GetChildren()
  local border, glow, name, level, levelicon , raidicon = this:GetRegions()
  
  if this.longName then name:SetText(this.longName) end -- so we don't have to rewrite all name-sensitive stuff

  if pfNameplates_config.players == "1" then
    if not pfNameplates.players[name:GetText()] or not pfNameplates.players[name:GetText()]["class"] then
      this:Hide()
    end
  end
  
  if this.boss then
    levelicon:Show()
    if raidicon:IsVisible() then
      levelicon:Hide()
    end
  end

  pfNameplates:UpdatePlayer(name)
  pfNameplates:UpdateColors(name, level, healthbar, levelicon)
  pfNameplates:UpdateCastbar(this, name, healthbar)
  pfNameplates:UpdateDebuffs(this, healthbar)
  pfNameplates:UpdateHP(healthbar, level, this.boss)
  pfNameplates:UpdateClickHandler(this)
  pfNameplates:ShortenName(name, this)
end

function pfNameplates:UpdatePlayer(name)
  local name = name:GetText()

  -- target
  if not pfNameplates.players[name] and pfNameplates.targets[name] == nil and UnitName("target") == nil then
    TargetByName(name, true)
    if UnitIsPlayer("target") then
      local _, class = UnitClass("target")
      pfNameplates.players[name] = {}
      pfNameplates.players[name]["class"] = class
    elseif UnitClassification("target") ~= "normal" then
      local elite = UnitClassification("target")
      pfNameplates.mobs[name] = elite
    end
    pfNameplates.targets[name] = "OK"
    ClearTarget()
  end

  -- mouseover
  if not pfNameplates.players[name] and pfNameplates.targets[name] == nil and UnitName("mouseover") == name then
    if UnitIsPlayer("mouseover") then
      local _, class = UnitClass("mouseover")
      pfNameplates.players[name] = {}
      pfNameplates.players[name]["class"] = class
    elseif UnitClassification("mouseover") ~= "normal" then
      local elite = UnitClassification("mouseover")
      pfNameplates.mobs[name] = elite
    end
    pfNameplates.targets[name] = "OK"
  end
end

local pfLocaleNames = pfLocaleNames
local shortNamesLookup = {}
function pfNameplates:ShortenName(name, obj)
	local nameString = name:GetText()
  
  -- speed up
  if shortNamesLookup[nameString] then
    obj.longName = nameString
    name:SetText(shortNamesLookup[nameString])
    return
  end
  
  local nameSplit = {}
  local nameLength = 0
  local shortName
  
  for token in string.gfind(nameString, "%S+") do
    table.insert(nameSplit, token)
  end
  
  shortName = nameSplit[1]
  nameLength = getn(nameSplit)
  
  for index,name in pfLocaleNames do
    if name.at <= nameLength and name.replaceWith <= nameLength then
    
      local at, replaceAt
      at = name.at
      replaceAt = name.replaceWith
      
      if at == -1 then at = nameLength end
      if replaceAt == -1 then replaceAt = nameLength end
      
      if nameSplit[at] == name.word then
        shortName = nameSplit[replaceAt]
        break
      end
      
    end
  end
  
  shortNamesLookup[nameString] = shortName
  
  obj.longName = nameString
  name:SetText(shortName)
end

function pfNameplates:UpdateColors(name, level, healthbar, levelicon)
  -- name color
  local red, green, blue, _ = name:GetTextColor()
  if red > 0.99 and green == 0 and blue == 0 then
    name:SetTextColor(1,0.4,0.2,0.85)
  elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
    name:SetTextColor(1,1,1,0.85)
  end

  -- level colors
  --[[local red, green, blue, _ = level:GetTextColor()
  if red > 0.99 and green == 0 and blue == 0 then
    level:SetTextColor(1,0.4,0.2,0.85)
  elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
    level:SetTextColor(1,1,1,0.85)
  end]]
  level:Hide()

  -- healthbar color
  -- reaction: 0 enemy ; 1 neutral ; 2 player ; 3 npc
  local red, green, blue, _ = healthbar:GetStatusBarColor()
  if red > 0.9 and green < 0.2 and blue < 0.2 then
    healthbar.reaction = 0
    healthbar:SetStatusBarColor(.982,.270,.035,1)
  elseif red > 0.9 and green > 0.9 and blue < 0.2 then
    healthbar.reaction = 1
    healthbar:SetStatusBarColor(0.368,0.780,0.733,1)
  elseif ( blue > 0.9 and red == 0 and green == 0 ) then
    healthbar.reaction = 2
    healthbar:SetStatusBarColor(0.368,0.780,0.733,1)
  elseif red == 0 and green > 0.99 and blue == 0 then
    healthbar.reaction = 3
    healthbar:SetStatusBarColor(0.368,0.780,0.733,1)
  end

  local nameLabel = name
  local name = name:GetText()
  healthbar.playerclass:Hide()

  if healthbar.reaction == 0 then
    nameLabel:SetTextColor(.982,.270,.035)
    if pfNameplates_config["enemyclassc"] == "1"
    and pfNameplates.players[name]
    and pfNameplates.players[name]["class"]
    and RAID_CLASS_COLORS[pfNameplates.players[name]["class"]]
    then
      healthbar:SetStatusBarColor(
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].r,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].g,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].b,
        0.9)
    end
    
    if pfNameplates.players[name]
    and pfNameplates.players[name]["class"]
    and ICON_CLASS[pfNameplates.players[name]["class"]]
    then
      healthbar.playerclass:SetTexture(ICON_CLASS[pfNameplates.players[name]["class"]])
      healthbar.playerclass:SetVertexColor(.982,.270,.035,1)
      healthbar.playerclass:Show()
      levelicon:Hide()
    end
  elseif healthbar.reaction == 1 then
    nameLabel:SetTextColor(0.368,0.780,0.733)
  elseif healthbar.reaction == 2 then
    nameLabel:SetTextColor(0.368,0.780,0.733)
    if pfNameplates_config["friendclassc"] == "1"
    and pfNameplates.players[name]
    and pfNameplates.players[name]["class"]
    and RAID_CLASS_COLORS[pfNameplates.players[name]["class"]]
    then
      healthbar:SetStatusBarColor(
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].r,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].g,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].b,
        0.9)
    end
    if pfNameplates.players[name]
    and pfNameplates.players[name]["class"]
    and ICON_CLASS[pfNameplates.players[name]["class"]]
    then
      healthbar.playerclass:SetTexture(ICON_CLASS[pfNameplates.players[name]["class"]])
      healthbar.playerclass:SetVertexColor(0.368,0.780,0.733,1)
      healthbar.playerclass:Show()
      levelicon:Hide()
    end
  elseif healthbar.reaction == 3 then
    nameLabel:SetTextColor(0.368,0.780,0.733)
  end
end

function pfNameplates:UpdateCastbar(frame, name, healthbar)
  if not healthbar.castbar then return end

  -- show castbar
  if pfNameplates_config["showcastbar"] == "1" and pfCastbar.casterDB[name:GetText()] ~= nil and pfCastbar.casterDB[name:GetText()]["cast"] ~= nil then
    if pfCastbar.casterDB[name:GetText()]["starttime"] + pfCastbar.casterDB[name:GetText()]["casttime"] <= GetTime() then
      pfCastbar.casterDB[name:GetText()] = nil
      healthbar.castbar:Hide()
    else
      healthbar.castbar:SetMinMaxValues(0,  pfCastbar.casterDB[name:GetText()]["casttime"])
      healthbar.castbar:SetValue(GetTime() -  pfCastbar.casterDB[name:GetText()]["starttime"])
      healthbar.castbar.text:SetText(round( pfCastbar.casterDB[name:GetText()]["starttime"] +  pfCastbar.casterDB[name:GetText()]["casttime"] - GetTime(),1))
      if pfNameplates_config.spellname == "1" and healthbar.castbar.spell then
        healthbar.castbar.spell:SetText(pfCastbar.casterDB[name:GetText()]["cast"])
      else
        healthbar.castbar.spell:SetText("")
      end
      healthbar.castbar:Show()
      if frame.debuffs then
        frame.debuffs[1]:SetPoint("BOTTOMLEFT", healthbar.castbar, "TOPLEFT", 0, 3)
      end

      if pfCastbar.casterDB[name:GetText()]["icon"] then
        healthbar.castbar.icon:SetTexture("Interface\\Icons\\" ..  pfCastbar.casterDB[name:GetText()]["icon"])
        healthbar.castbar.icon:SetTexCoord(.1,.9,.1,.9)
      end
    end
  else
    healthbar.castbar:Hide()
    if frame.debuffs then
      frame.debuffs[1]:SetPoint("BOTTOMLEFT", healthbar, "TOPLEFT", 0, 3)
    end
  end
end

function pfNameplates:UpdateDebuffs(frame, healthbar)
  if not frame.debuffs or pfNameplates_config["showdebuffs"] ~= "1" then return end

  if UnitExists("target") and healthbar:GetAlpha() == 1 then
  local j = 1
    local k = 1
    for j, e in ipairs(pfNameplates.debuffs) do
      frame.debuffs[j]:SetTexture(pfNameplates.debuffs[j])
      frame.debuffs[j]:SetTexCoord(.078, .92, .079, .937)
      frame.debuffs[j]:SetAlpha(0.9)
      k = k + 1
    end
    for j = k, 16, 1 do
      frame.debuffs[j]:SetTexture(nil)
    end
  elseif frame.debuffs then
    for j = 1, 16, 1 do
      frame.debuffs[j]:SetTexture(nil)
    end
  end
end

function pfNameplates:UpdateHP(healthbar, level, isBoss)
  local min, max = healthbar:GetMinMaxValues()
  local cur = healthbar:GetValue()
  
  healthbar.bgframe.stick:SetPoint("LEFT", healthbar, "LEFT", (healthbar:GetWidth() * (cur/max)) , 0)
  
  if not healthbar.previousValue then
	healthbar.previousValue = healthbar:GetValue()
  end
  
  if pfNameplates_config.showhp == "1" and healthbar.hptext then
    healthbar.hptext:SetText(cur .. " / " .. max)
  end
  
  local chunks
  if pfNameplates.useHP then
	if max ~= 100 then
		chunks = (max / pfNameplates.myhphalf)
	else
		-- thanks kronos
		chunks = 3
	end
  else
	chunks = 3
  end
  
  healthbar:SetWidth(pfNameplates:NormalizeHP(25 * chunks))
  healthbar.bg:SetWidth(healthbar:GetWidth() + 2)
  healthbar.bg:SetHeight(healthbar:GetHeight() + 2)
  chunks = math.floor(chunks)
  for i = 1, 10 do
    if i > chunks then
      healthbar.chunks[i]:Hide()
    else
      healthbar.chunks[i]:Show()
    end
  end
  
  this:SetWidth(healthbar:GetWidth() + 2)
  
  -- flash if hp dropped
  if cur < healthbar.previousValue then
	local fadeInfo = {}
	fadeInfo.mode = "IN"
	fadeInfo.timeToFade = 0.1
	fadeInfo.fadeHoldTime = 0.3
	fadeInfo.startAlpha = 0
	fadeInfo.endAlpha = 1
	fadeInfo.finishedArg1 = healthbar.bgframe
	fadeInfo.finishedFunc = function(this)
		this:Hide()
	end
	UIFrameFade(healthbar.bgframe, fadeInfo)
  end
  healthbar.previousValue = cur
end

function pfNameplates:NormalizeHP(value)
  local min = 25
  local max = min * 10
  if value < min then
    return min
  elseif value > max then
    return max
  else
    return value
  end
end

function pfNameplates:UpdateClickHandler(frame)
  -- enable clickthrough
  if pfNameplates_config["clickthrough"] == "0" then
    frame:EnableMouse(true)
    if pfNameplates_config["rightclick"] == "1" then
      frame:SetScript("OnMouseDown", function()
        if arg1 and arg1 == "RightButton" then
          MouselookStart()

          -- start detection of the rightclick emulation
          pfNameplates.emulateRightClick.time = GetTime()
          pfNameplates.emulateRightClick.frame = this
          pfNameplates.emulateRightClick:Show()
        end
      end)
    end
  else
    frame:EnableMouse(false)
  end
end

-- debuff detection
pfNameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
pfNameplates:RegisterEvent("UNIT_AURA")
pfNameplates:SetScript("OnEvent", function()
  pfNameplates.debuffs = {}
  local i = 1
  local debuff = UnitDebuff("target", i)
  while debuff do
    pfNameplates.debuffs[i] = debuff
    i = i + 1
    debuff = UnitDebuff("target", i)
  end
end)

-- combat tracker
pfNameplates.combat = CreateFrame("Frame")
pfNameplates.combat:RegisterEvent("PLAYER_ENTER_COMBAT")
pfNameplates.combat:RegisterEvent("PLAYER_LEAVE_COMBAT")
pfNameplates.combat:SetScript("OnEvent", function()
  if event == "PLAYER_ENTER_COMBAT" then
    this.inCombat = 1
  elseif event == "PLAYER_LEAVE_COMBAT" then
    this.inCombat = nil
  end
end)

-- emulate fake rightclick
pfNameplates.emulateRightClick = CreateFrame("Frame", nil, UIParent)
pfNameplates.emulateRightClick.time = nil
pfNameplates.emulateRightClick.frame = nil
pfNameplates.emulateRightClick:SetScript("OnUpdate", function()
  -- break here if nothing to do
  if not pfNameplates.emulateRightClick.time or not pfNameplates.emulateRightClick.frame then
    this:Hide()
    return
  end

  -- if threshold is reached (0.5 second) no click action will follow
  if not IsMouselooking() and pfNameplates.emulateRightClick.time + tonumber(pfNameplates_config["clickthreshold"]) < GetTime() then
    pfNameplates.emulateRightClick:Hide()
    return
  end

  -- run a usual nameplate rightclick action
  if not IsMouselooking() then
    pfNameplates.emulateRightClick.frame:Click("LeftButton")
    if UnitCanAttack("player", "target") and not pfNameplates.combat.inCombat then AttackTarget() end
    pfNameplates.emulateRightClick:Hide()
    return
  end
end)

pfNameplates.fpscamera = CreateFrame("Frame", nil, UIParent)
pfNameplates.fpscamera.lookingaround = nil
pfNameplates.fpscamera.enable = nil

pfNameplates.hook_worldframe_onMouseUp = WorldFrame:GetScript("OnMouseUp")
WorldFrame:SetScript("OnMouseUp", function()
  if pfNameplates.hook_worldframe_onMouseUp then
    pfNameplates.hook_worldframe_onMouseUp()
  end
  
  if arg1 == "RightButton" and not IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown() then
    if pfNameplates.fpscamera.enable then
      pfNameplates.fpscamera.enable = nil
    else
      pfNameplates.fpscamera.enable = true
    end
  end
  
end)

pfNameplates.fpscamera:SetScript("OnUpdate", function()
  if pfNameplates_config.fpscamera ~= "1" then return end
  
  local visible, frame
  
  for index, value in UISpecialFrames do
		frame = getglobal(value)
		if frame and frame:IsVisible() then
			visible = 1
      break
		end
	end
  
  if visible
  or GameMenuFrame:IsVisible()
  or ChatFrameEditBox:IsVisible()
  or SpellBookFrame:IsVisible()
  or MerchantFrame:IsVisible()
  or FriendsFrame:IsVisible()
  or OptionsFrame:IsVisible()
  or SoundOptionsFrame:IsVisible()
  or KeyBindingFrame and KeyBindingFrame:IsVisible()
  or MacroFrame and MacroFrame:IsVisible()
  or UIOptionsFrame:IsVisible()
  or HawkenPlatesConfig:IsVisible()
  then
    if IsMouselooking() and pfNameplates.fpscamera.lookingaround then
      pfNameplates.fpscamera.lookingaround = false
      MouselookStop()
    end
  else
    if not IsMouselooking() and pfNameplates.fpscamera.enable then
      pfNameplates.fpscamera.lookingaround = true
      MouselookStart()
    end
  end
  
end)