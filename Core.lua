local _, namespace = ...

local DEFAULT_SETTINGS = {
    char = {frameXPos = 0, frameYPos = 0, framePoint = "CENTER", frameRelativePoint = "CENTER"}
}

BGIncomingTBC = LibStub("AceAddon-3.0"):NewAddon("BGIncomingTBC", "AceConsole-3.0", "AceEvent-3.0")



local function setActive(self,active)
    if active then
        self:SetBackdropColor(0.7, 0.9, 0.4, 1.0)
    else
        self:SetBackdropColor(0.4, 0.4, 0.4, 0.5)
    end    
end

function BGIncomingTBC:OnInitialize()
    BGIncomingTBC:Print("BGIncomingTBC Initialize")

    self.db = LibStub("AceDB-3.0"):New("BGIncomingTBCDB", DEFAULT_SETTINGS)

    BGIncomingTBC:Print("frame pos at load: " .. self.db.char.frameXPos ..  " , " .. self.db.char.frameXPos)

    -- self.frame = CreateFrame("Frame",nil,UIParent)

    local frameInset = 2
    local frameEdge = 2
    local buttonSize = 40
    local buttonGap = 2
    local locationButtonFontSize = 20
    local chatButtonFontSize = 14

    local topBar = 19
    local numButtons = 6


    self.bgm = namespace.BattleGroundModel:new()

    self.layouter = namespace.BGLayouter:new()

    self.frame = CreateFrame("Frame", "BGIncomingTBCFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

    self.layouter:placeFrame(self.frame)

    self.frame:SetBackdrop(
        {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            tile = true,
            tileSize = 20,
            -- bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", tile = true, tileSize = 20,
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = frameEdge,
            insets = {left = frameInset, right = frameInset, top = frameInset, bottom = frameInset}
        }
    )
    self.frame:SetBackdropColor(0.4, 0.4, 0.4, 0.5)
    self.frame:SetClampedToScreen(true)

    for index, locationDescription in pairs(self.bgm:getAllLocations()) do
        -- BGIncomingTBC:Print("Location: " .. locationDescription.locationKey .. " index " .. locationDescription.index .. " bgKey = " .. locationDescription.bgKey )


        local button = namespace.BGIncomingButton.new(self.frame,locationDescription.locationKey,self.layouter.geometry.locationButtonFontSize)

        self.layouter:placeButton(button,2,locationDescription.index)

        -- Store the location name on the button:
        button.locationKey = locationDescription.locationKey
        button.bgm = self.bgm

        function button:update(model)
            -- BGIncomingTBC:Print("Update called for button " .. self.locationKey)
            if model:locationCurrentlyActive(self.locationKey) then
                self:Show(true)
            else
                self:Hide(true)
            end

            self:setActive(model.currentLocationKey == self.locationKey)            
        end

        function button:onClick(mouseButton)
            -- BGIncomingTBC:Print("Clicked " .. self.locationKey)
            self.bgm:setCurrentLocationKey(self.locationKey)
        end

        self.bgm:observe(button)

        button:SetScript("OnClick", button.onClick)
    end

    for index, message in ipairs(self.bgm.messages) do

        local button = namespace.BGIncomingButton.new(self.frame,message.messageKey,self.layouter.geometry.chatButtonFontSize)


        self.layouter:placeButton(button,1,index)
        
        button:setActive(false)

        
        -- Store the location name on the button:
        button.messageKey = message.messageKey
        button.messageInfo = message
        button.bgm = self.bgm


        function button:onClick(mouseButton)
            -- BGIncomingTBC:Print("Clicked " .. self.messageKey)
            self:setActive(true)
            self.bgm:sendMessage(self.messageInfo)
            self:setActive(false)
        end

        button:SetScript("OnClick", button.onClick)

    end

    local bgButtonFontSize = 10
    for index, battleground in ipairs({{bgKey = "ab", text = "AB"}, {bgKey = "eots", text = "EOTS"}}) do

        local button = namespace.BGIncomingButton.new(self.frame,battleground.text,self.layouter.geometry.bgButtonFontSize)
        self.layouter:placeButton(button,0,index)

        
        button.bgKey = battleground.bgKey
        button.bgm = self.bgm

        function button:onClick(mouseButton)
            -- BGIncomingTBC:Print("Clicked " .. self.messageKey)
            self.bgm:setBattleground(self.bgKey)
        end

        function button:update(model)
            -- BGIncomingTBC:Print("Update called for button " .. self.locationKey)

            self:setActive(model.current_bg == self.bgKey)

        end

        self.bgm:observe(button)

        button:SetScript("OnClick", button.onClick)
    end


    local button = namespace.BGIncomingButton.new(self.frame,"RW",self.layouter.geometry.bgButtonFontSize)



    self.layouter:placeButton(button,0,6)
    

    function button:onClick(mouseButton)
        -- BGIncomingTBC:Print("Clicked " .. self.messageKey)
        if self.bgm.raidWarning then
            self.bgm:setRaidWarning(false)
        else
            self.bgm:setRaidWarning(true)
        end    
    end

    function button:update(model)
        self:setActive(model.raidWarning)
    end

    button.bgm = self.bgm
    self.bgm:observe(button)

    button:SetScript("OnClick", button.onClick)


    self.frame:SetScale(0.6)
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

    self.frame:SetPoint(p, z, r, x, y)

    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("ZONE_CHANGED")

    self.bgm:setBattleground("ab")

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

    -- DEFAULT_CHAT_FRAME:AddMessage("subzone: " .. GetSubZoneText() .." map zone id " .. tostring(C_Map.GetBestMapForUnit("player")))
end

function BGIncomingTBC:ZONE_CHANGED()
    local subzoneText = GetSubZoneText()
    -- DEFAULT_CHAT_FRAME:AddMessage("New area, zone " .. GetZoneText() .. " subzone: " ..subzoneText)
    -- DEFAULT_CHAT_FRAME:AddMessage("subzone: " .. GetSubZoneText() .." map zone id " .. tostring(C_Map.GetBestMapForUnit("player")))

    if subzoneText ~= nil then
        self.bgm:setCurrentLocationName(subzoneText)
    end
end
