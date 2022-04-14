local _, namespace = ...

local DEFAULT_SETTINGS = {
	char = { frameXPos = 0, frameYPos = 0, framePoint = "CENTER", frameRelativePoint = "CENTER" } 
}



BGIncomingTBC = LibStub("AceAddon-3.0"):NewAddon("BGIncomingTBC", "AceConsole-3.0","AceEvent-3.0")


function LocationButton_OnClick(self, mouseButton)
    BGIncomingTBC:Print("Clicked ")
end

function BGIncomingTBC:OnInitialize()
    BGIncomingTBC:Print("BGIncomingTBC Initialize")

    self.db = LibStub("AceDB-3.0"):New("BGIncomingTBCDB",DEFAULT_SETTINGS)
    -- self.frame = CreateFrame("Frame",nil,UIParent)

    self.bgm = namespace.BattleGroundModel:new()

    self.frame = CreateFrame('Frame', "BGIncomingTBCFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

    local frameInset = 2
    local frameEdge = 2
    local buttonSize = 40
    local buttonGap = 2
    local locationButtonFontSize = 22
    local chatButtonFontSize = 15

    local topBar = 19
    local numButtons = 6

    -- self.frame:SetSize(2*buttonSize+4*buttonGap+frameEdge, (numButtons)*(buttonSize+buttonGap)+buttonGap+2*frameEdge+topBar)
    self.frame:SetSize((numButtons)*(buttonSize+buttonGap)+buttonGap+2*frameEdge+topBar, 2*buttonSize+4*buttonGap+frameEdge + topBar)

    self.frame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8", tile = true, tileSize = 20,        		
                -- bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", tile = true, tileSize = 20,
                edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = frameEdge,
                insets = { left = frameInset, right = frameInset, top = frameInset, bottom = frameInset }
                })
    self.frame:SetBackdropColor(0.4,0.4,0.4,0.5)
    self.frame:SetClampedToScreen(true)

    for index, locationDescription in pairs(self.bgm:getAllLocations()) do
        BGIncomingTBC:Print("Location: " .. locationDescription.locationKey .. " index " .. locationDescription.index .. " bgKey = " .. locationDescription.bgKey )
    
        local button = CreateFrame("Button", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate") -- , "SecureActionButtonTemplate")
  
        button:SetSize(buttonSize, buttonSize)
        -- button:SetPoint("TOPLEFT",self.frame,"TOPLEFT", frameEdge+buttonGap, -(buttonSize+buttonGap)*(locationDescription.index-1)- frameEdge - buttonGap - topBar) 
        button:SetPoint("TOPLEFT",self.frame,"TOPLEFT",  (buttonSize+buttonGap)*(locationDescription.index-1)+ frameEdge + buttonGap  ,  -frameEdge-2*buttonGap-buttonSize  - topBar) 


       -- button:SetNormalTexture("Interface\\Buttons\\WHITE8x8")

        button:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8", tile = true, tileSize = 20,        		
            -- bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", tile = true, tileSize = 20,
            edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })  
            
        button:SetBackdropColor(0.4,0.4,0.4,0.5)

    
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        
    
        -- Store the location name on the button:
        button.locationKey = locationDescription.locationKey
        button.bgm = self.bgm
        
        -- Apply the specified texture:
        -- button:SetNormalTexture("Interface\\AddOns\\BGCallouts\\Icons\\purple")
        -- button:SetHighlightTexture("Interface\\AddOns\\BGCallouts\\Icons\\highlight")

        text = button:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
        text:SetFont("Fonts\\ARIALN.TTF",locationButtonFontSize)
        text:SetJustifyH("CENTER")
        text:SetPoint("CENTER")
        text:SetText(button.locationKey)
        
--         button:SetPoint("TOPRIGHT", -49, -10)

        button:RegisterForDrag("LeftButton")


        function button:OnDragStart()
            return self:GetParent():StartMoving()
        end	

        function button:OnDragStop()
            return self:GetParent():StopMovingOrSizing()
        end	

        function button:update(model)
            -- BGIncomingTBC:Print("Update called for button " .. self.locationKey)
            if model:locationCurrentlyActive(self.locationKey) then
                self:Show(true)
            else
                self:Hide(true)
            end

            if model.currentLocationKey == self.locationKey then
               -- button:SetNormalTexture("Interface\\Buttons\\GREEN8x8")
                button:SetBackdropColor(0.4,0.9,0.4,1.0)
            else
                --button:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
                button:SetBackdropColor(0.4,0.4,0.4,0.5)
            end

        end

        function button:onClick(mouseButton)
            -- BGIncomingTBC:Print("Clicked " .. self.locationKey)  
            self.bgm:setCurrentLocationKey(self.locationKey)      
        end

        self.bgm:observe(button)
        
        button:SetScript("OnClick", button.onClick)
        button:SetScript('OnDragStop', button.OnDragStop)
        button:SetScript('OnDragStart', button.OnDragStart)
                
    end


    for index, message in ipairs(self.bgm.messages) do 
        local button = CreateFrame("Button", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate") -- , "SecureActionButtonTemplate")
  
        button:SetSize(buttonSize, buttonSize)

       -- button:SetNormalTexture("Interface\\Buttons\\WHITE8x8")

        button:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8", tile = true, tileSize = 20,        		
            -- bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", tile = true, tileSize = 20,
            edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })  
            
        button:SetBackdropColor(0.4,0.4,0.4,0.5)
    
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        
    
        -- Store the location name on the button:
        button.messageKey = message.messageKey
        button.messageInfo = message
        button.bgm = self.bgm
        

        text = button:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
        text:SetFont("Fonts\\ARIALN.TTF",chatButtonFontSize)
        text:SetJustifyH("CENTER")
        text:SetPoint("CENTER")
        text:SetText(message.messageKey)
        
        

        --- button:SetPoint("TOPLEFT",self.frame,"TOPLEFT", frameEdge+2*buttonGap+buttonSize, -(buttonSize+buttonGap)*(index-1)- frameEdge - buttonGap - topBar) 
        button:SetPoint("TOPLEFT",self.frame,"TOPLEFT", (buttonSize+buttonGap)*(index-1)+ frameEdge + buttonGap,  -frameEdge-buttonGap   - topBar) 
        button:RegisterForDrag("LeftButton")


        function button:OnDragStart()
            return self:GetParent():StartMoving()
        end	

        function button:OnDragStop()
            return self:GetParent():StopMovingOrSizing()
        end	

        function button:onClick(mouseButton)
            -- BGIncomingTBC:Print("Clicked " .. self.messageKey)  
            self.bgm:sendMessage(self.messageInfo)      
        end

        
        button:SetScript("OnClick", button.onClick)
        button:SetScript('OnDragStop', button.OnDragStop)
        button:SetScript('OnDragStart', button.OnDragStart)

    end

    self.frame:SetScale(0.7)

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

    self.bgm:setBattleground("ab")



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





