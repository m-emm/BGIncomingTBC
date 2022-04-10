local _, namespace = ...

local DEFAULT_SETTINGS = {
	char = { frameXPos = 0, frameYPos = 0, framePoint = "CENTER", frameRelativePoint = "CENTER" } 
}


BGIncomingTBC = LibStub("AceAddon-3.0"):NewAddon("BGIncomingTBC", "AceConsole-3.0","AceEvent-3.0")


function LocationButton_OnClick(self, mouseButton)
    BGIncomingTBC:Print("Clicked")
end

function BGIncomingTBC:OnInitialize()
    BGIncomingTBC:Print("BGIncomingTBC Initialize")

    self.db = LibStub("AceDB-3.0"):New("BGIncomingTBCDB",DEFAULT_SETTINGS)
    -- self.frame = CreateFrame("Frame",nil,UIParent)

    self.bgm = namespace.BattleGroundModel:new()

    self.frame = CreateFrame('Frame', "BGIncomingTBCFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

    self.frame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8", tile = true, tileSize = 20,        		
                -- bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", tile = true, tileSize = 20,
                edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 7,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
                })
    self.frame:SetBackdropColor(0.4,0.4,0.4,0.5)
    self.frame:SetSize(2*40+18, 2*40+18)  
    self.frame:SetClampedToScreen(true)

    local button = CreateFrame("Button", nil, self.frame, "SecureActionButtonTemplate")
	button:SetSize(48, 40)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", LocationButton_OnClick)

    local name ="GM"
    local keytext ="GM"

	-- Store the location name on the button:
	button.location = name
	button.keytext = keytext
	

	-- Apply the specified texture:
	-- button:SetNormalTexture("Interface\\AddOns\\BGCallouts\\Icons\\purple")
	-- button:SetHighlightTexture("Interface\\AddOns\\BGCallouts\\Icons\\highlight")

	text = button:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
	text:SetFont("Fonts\\ARIALN.TTF",24)
	text:SetJustifyH("CENTER")
	text:SetPoint("CENTER")
	text:SetText(keytext)
    
    button:SetPoint("TOPRIGHT", -49, -10)
    button:RegisterForDrag("LeftButton")


    function button:OnDragStart()
		return self:GetParent():StartMoving()
	end	

    function button:OnDragStop()
		return self:GetParent():StopMovingOrSizing()
	end	
    button:SetScript('OnDragStop', button.OnDragStop)
    button:SetScript('OnDragStart', button.OnDragStart)
 

end
  
function BGIncomingTBC:OnEnable()
    BGIncomingTBC:Print(" BGIncomingTBC Enable")
    
    self.frame:SetMovable(true)
	self.frame:EnableMouse(true)
	self.frame:RegisterForDrag("LeftButton")
	self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    function self.frame:StopMovingOrSizingOverride()
        self.that:EndDrag()
        self:StopMovingOrSizing()
    end

	self.frame:SetScript("OnDragStop", self.frame.StopMovingOrSizingOverride)
    self.frame.that = self

    self.frame:Show(true)

    local z = "UIParent"
  

    local p, r = self.db.char.framePoint, self.db.char.frameRelativePoint
    local x, y = self.db.char.frameXPos, self.db.char.frameYPos

    self.frame:SetPoint(p,z,r,x,y)

    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ZONE_CHANGED")


    -- Called when the addon is enabled
end

function BGIncomingTBC:EndDrag()
    local point, relativeTo, relativePoint, xOfs, yOfs = self.frame:GetPoint()
    self.db.char.framePoint = point
    self.db.char.frameRelativePoint = relativePoint
    self.db.char.frameXPos = xOfs
    self.db.char.frameYPos = yOfs

    self.frame:StopMovingOrSizing()

end

function BGIncomingTBC:OnDisable()
    -- Called when the addon is disabled
end


function BGIncomingTBC:ZONE_CHANGED_NEW_AREA()
	func(select(2,GetInstanceInfo()))
	self.bgm:setBattlegroundByZoneId(C_Map.GetBestMapForUnit("player"))

	DEFAULT_CHAT_FRAME:AddMessage("subzone: " .. GetSubZoneText() .." map zone id " .. tostring(C_Map.GetBestMapForUnit("player")))

end


function BGIncomingTBC:ZONE_CHANGED()
	local subzoneText = GetSubZoneText()
	-- DEFAULT_CHAT_FRAME:AddMessage("New area, zone " .. GetZoneText() .. " subzone: " ..subzoneText)
	DEFAULT_CHAT_FRAME:AddMessage("subzone: " .. GetSubZoneText() .." map zone id " .. tostring(C_Map.GetBestMapForUnit("player")))

	if subzoneText ~= nil then
		self.bgm:setCurrentLocationName(subzoneText)
	end
end





