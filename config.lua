local backdrop = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local checkbox = {
  ["blueshaman"]    = "Enable Blue Shaman Class Color",
  ["clickthrough"]  = "Disable Mouse",
  ["showdebuffs"]   = "Show Debuffs on Target Nameplate",
  ["showcastbar"]   = "Show Castbar",
  ["spellname"]     = "Show Spellname On Castbar",
  -- ["players"]       = "Only Show Player Nameplates",
  ["showhp"]        = "Display HP",
  ["rightclick"]    = "Enable Mouselook on Right-Click",
  ["enemyclassc"]   = "Enable Enemy Class Colors",
  ["friendclassc"]  = "Enable Friend Class Colors",
  ["fpscamera"]     = "FPS-camera style",
  ["sound"]     	= "Sound Effects",
}

local text = {
  ["clickthreshold"] = "Right-Click Threshold",
  ["vpos"]           = "Vertical Offset",
  ["raidiconsize"]   = "Raid Icon Size",
}

-- config
pfConfigCreate = CreateFrame("Frame", nil, UIParent)
pfConfigCreate:RegisterEvent("VARIABLES_LOADED")

function pfConfigCreate:ResetConfig()
  pfNameplates_config = { }
  pfNameplates_config["blueshaman"] = "1"
  pfNameplates_config["clickthrough"] = "0"
  pfNameplates_config["raidiconsize"] = "16"
  pfNameplates_config["showdebuffs"] = "0"
  pfNameplates_config["showcastbar"] = "1"
  pfNameplates_config["spellname"] = "1"
  -- pfNameplates_config["players"] = "0"
  pfNameplates_config["showhp"] = "0"
  pfNameplates_config["vpos"] = "0"
  pfNameplates_config["rightclick"] = "1"
  pfNameplates_config["clickthreshold"] = ".5"
  pfNameplates_config["enemyclassc"] = "0"
  pfNameplates_config["friendclassc"] = "0"
  pfNameplates_config["fpscamera"] = "0"
  pfNameplates_config["sound"] = "0"
end

pfConfigCreate:SetScript("OnEvent", function()
  if not pfNameplates_config then
    pfConfigCreate:ResetConfig()
  end

  HawkenPlatesConfig:Initialize()

  if pfNameplates_config.blueshaman == "1" then
    RAID_CLASS_COLORS["SHAMAN"] = { r = 0.14, g = 0.35, b = 1.0, colorStr = "ff0070de" }
  end
end)

HawkenPlatesConfig = HawkenPlatesConfig or CreateFrame("Frame", "HawkenPlatesConfig", UIParent)
function HawkenPlatesConfig:Initialize()
  HawkenPlatesConfig:Hide()
  HawkenPlatesConfig:SetBackdrop(backdrop)
  HawkenPlatesConfig:SetBackdropColor(0,0,0,1)
  HawkenPlatesConfig:SetWidth(400)
  HawkenPlatesConfig:SetHeight(540)
  HawkenPlatesConfig:SetPoint("CENTER", 0, 0)
  HawkenPlatesConfig:SetMovable(true)
  HawkenPlatesConfig:EnableMouse(true)
  HawkenPlatesConfig:SetScript("OnMouseDown",function()
    HawkenPlatesConfig:StartMoving()
  end)

  HawkenPlatesConfig:SetScript("OnMouseUp",function()
    HawkenPlatesConfig:StopMovingOrSizing()
  end)

  HawkenPlatesConfig.vpos = 60

  HawkenPlatesConfig.title = CreateFrame("Frame", nil, HawkenPlatesConfig)
  HawkenPlatesConfig.title:SetPoint("TOP", 0, -2);
  HawkenPlatesConfig.title:SetWidth(396);
  HawkenPlatesConfig.title:SetHeight(40);
  HawkenPlatesConfig.title.tex = HawkenPlatesConfig.title:CreateTexture("LOW");
  HawkenPlatesConfig.title.tex:SetAllPoints();
  HawkenPlatesConfig.title.tex:SetTexture(0,0,0,.5);

  HawkenPlatesConfig.caption = HawkenPlatesConfig.caption or HawkenPlatesConfig.title:CreateFontString("Status", "LOW", "GameFontWhite")
  HawkenPlatesConfig.caption:SetPoint("TOP", 0, -10)
  HawkenPlatesConfig.caption:SetJustifyH("CENTER")
  HawkenPlatesConfig.caption:SetText("hawkenPlates")
  HawkenPlatesConfig.caption:SetFont("Interface\\AddOns\\HawkenPlates\\fonts\\arial.ttf", 24)
  HawkenPlatesConfig.caption:SetTextColor(.2,1,.8,1)

  for config, description in pairs(checkbox) do
    HawkenPlatesConfig:CreateEntry(config, description, "checkbox")
  end

  for config, description in pairs(text) do
    HawkenPlatesConfig:CreateEntry(config, description, "text")
  end

  HawkenPlatesConfig.reload = CreateFrame("Button", nil, HawkenPlatesConfig, "UIPanelButtonTemplate")
  HawkenPlatesConfig.reload:SetWidth(150)
  HawkenPlatesConfig.reload:SetHeight(30)
  HawkenPlatesConfig.reload:SetNormalTexture(nil)
  HawkenPlatesConfig.reload:SetHighlightTexture(nil)
  HawkenPlatesConfig.reload:SetPushedTexture(nil)
  HawkenPlatesConfig.reload:SetDisabledTexture(nil)
  HawkenPlatesConfig.reload:SetBackdrop(backdrop)
  HawkenPlatesConfig.reload:SetBackdropColor(0,0,0,1)
  HawkenPlatesConfig.reload:SetPoint("BOTTOMRIGHT", -20, 20)
  HawkenPlatesConfig.reload:SetText("Save")
  HawkenPlatesConfig.reload:SetScript("OnClick", function()
    ReloadUI()
  end)

  HawkenPlatesConfig.reset = CreateFrame("Button", nil, HawkenPlatesConfig, "UIPanelButtonTemplate")
  HawkenPlatesConfig.reset:SetWidth(150)
  HawkenPlatesConfig.reset:SetHeight(30)
  HawkenPlatesConfig.reset:SetNormalTexture(nil)
  HawkenPlatesConfig.reset:SetHighlightTexture(nil)
  HawkenPlatesConfig.reset:SetPushedTexture(nil)
  HawkenPlatesConfig.reset:SetDisabledTexture(nil)
  HawkenPlatesConfig.reset:SetBackdrop(backdrop)
  HawkenPlatesConfig.reset:SetBackdropColor(0,0,0,1)
  HawkenPlatesConfig.reset:SetPoint("BOTTOMLEFT", 20, 20)
  HawkenPlatesConfig.reset:SetText("Reset")
  HawkenPlatesConfig.reset:SetScript("OnClick", function()
    pfNameplates_config = nil
    ReloadUI()
  end)
end

function HawkenPlatesConfig:CreateEntry(config, description, type)
  -- sanity check
  if not pfNameplates_config[config] then
    pfConfigCreate:ResetConfig()
  end

  -- basic frame
  local frame = getglobal("SPC" .. config) or CreateFrame("Frame", "SPC" .. config, HawkenPlatesConfig)
  frame:SetWidth(400)
  frame:SetHeight(25)
  frame:SetPoint("TOP", 0, -HawkenPlatesConfig.vpos)

  -- caption
  frame.caption = frame.caption or frame:CreateFontString("Status", "LOW", "GameFontWhite")
  frame.caption:SetFont("Interface\\AddOns\\HawkenPlates\\fonts\\arial.ttf", 14)
  frame.caption:SetPoint("LEFT", 20, 0)
  frame.caption:SetJustifyH("LEFT")
  frame.caption:SetText(description)

  -- checkbox
  if type == "checkbox" then
    frame.input = frame.input or CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.input:SetWidth(24)
    frame.input:SetHeight(24)
    frame.input:SetPoint("RIGHT" , -20, 0)

    frame.input.config = config
    if pfNameplates_config[config] == "1" then
      frame.input:SetChecked()
    end

    frame.input:SetScript("OnClick", function ()
      if this:GetChecked() then
        pfNameplates_config[this.config] = "1"
      else
        pfNameplates_config[this.config] = "0"
      end
    end)

  elseif type == "text" then
    -- input field
    frame.input = frame.input or CreateFrame("EditBox", nil, frame)
    frame.input:SetTextColor(.2,1,.8,1)
    frame.input:SetJustifyH("RIGHT")

    frame.input:SetWidth(50)
    frame.input:SetHeight(20)
    frame.input:SetPoint("RIGHT" , -20, 0)
    frame.input:SetFontObject(GameFontNormal)
    frame.input:SetAutoFocus(false)
    frame.input:SetScript("OnEscapePressed", function(self)
      this:ClearFocus()
    end)

    frame.input.config = config
    frame.input:SetText(pfNameplates_config[config])

    frame.input:SetScript("OnTextChanged", function(self)
      pfNameplates_config[this.config] = this:GetText()
    end)
  end

  HawkenPlatesConfig.vpos = HawkenPlatesConfig.vpos + 30
end

SLASH_SHAGUPLATES1 = '/hawkenplates'
SLASH_SHAGUPLATES2 = '/hp'

function SlashCmdList.SHAGUPLATES(msg)
  if HawkenPlatesConfig:IsShown() then
    HawkenPlatesConfig:Hide()
  else
    HawkenPlatesConfig:Show()
  end
end
