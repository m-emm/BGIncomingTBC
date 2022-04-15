local _, namespace = ...

local BGLayouter = {}
namespace.BGLayouter = BGLayouter

BGLayouter.__index = BGLayouter
setmetatable(
    BGLayouter,
    {
        __call = function(cls, ...)
            return cls.new(...)
        end
    }
)

function BGLayouter.new()
    local self = setmetatable({}, BGLayouter)
    self.geometry =  {
        frameInset = 2,
        frameEdge = 2,
        buttonSize = 40,
        buttonGap = 2,
        locationButtonFontSize = 20,
        chatButtonFontSize = 14,
        bgButtonFontSize = 10,
        topBar = 19,
        numButtons = 6
    }
    
    return self
end

function BGLayouter:placeButton(button,row,col)
    -- note: row 0 is the menu bar on top
    local ySize = self.geometry.buttonSize
    if row == 0 then
        ySize = self.geometry.topBar - 2 * self.geometry.buttonGap
    end
    BGIncomingTBC:Print("placing button, size: " .. self.geometry.buttonSize .. " , " ..ySize )
    button:SetSize(self.geometry.buttonSize,ySize)
    local yPos =  -self.geometry.frameEdge - (row-1) * self.geometry.buttonGap - self.geometry.topBar - (row-1)*self.geometry.buttonSize
    if row == 0 then
        yPos = -self.geometry.buttonGap -  self.geometry.frameEdge
    end
    button:SetPoint(
        "TOPLEFT",
        button:GetParent(),
        "TOPLEFT",
        (self.geometry.buttonSize + self.geometry.buttonGap) * (col - 1) + self.geometry.frameEdge + self.geometry.buttonGap,
        yPos
    )
    
end

function BGLayouter:placeFrame(frame)
    frame:SetSize(
        (self.geometry.numButtons) * (self.geometry.buttonSize + self.geometry.buttonGap) + self.geometry.buttonGap + 2 * self.geometry.frameEdge,
        2 * self.geometry.buttonSize + 4 * self.geometry.buttonGap + self.geometry.frameEdge + self.geometry.topBar
    )
end



local BGIncomingButton = {}
namespace.BGIncomingButton = BGIncomingButton

BGIncomingButton.__index = BGIncomingButton
setmetatable(
    BGIncomingButton,
    {
        __call = function(cls, ...)
            return cls.new(...)
        end
    }
)

function BGIncomingButton.new(frame,text,fontSize)
    local o =  CreateFrame("Button", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
    setmetatable(BGIncomingButton,getmetatable(o))
    local self = setmetatable(o, BGIncomingButton)
    self.__index = self
    self.text = text


    self:SetBackdrop(
        {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            tile = true,
            tileSize = 20,
            -- bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", tile = true, tileSize = 20,
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        }
    )

    self:SetBackdropColor(0.4, 0.4, 0.4, 0.5)

    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

    textObject = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    textObject:SetFont("Fonts\\ARIALN.TTF", fontSize)
    textObject:SetJustifyH("CENTER")
    textObject:SetPoint("CENTER")
    textObject:SetText(text)


    self:RegisterForDrag("LeftButton")

    self:SetScript("OnDragStop", BGIncomingButton.OnDragStop)
    self:SetScript("OnDragStart", BGIncomingButton.OnDragStart)

    return self
end


function BGIncomingButton:OnDragStart()
    return self:GetParent():StartMoving()
end

function BGIncomingButton:OnDragStop()
    return self:GetParent():StopMovingOrSizingOverride()
end

function BGIncomingButton:setActive(active)
    if active then
        self:SetBackdropColor(0.9, 0.2, 0.2, 1.0)
    else
        self:SetBackdropColor(0.4, 0.4, 0.4, 0.5)
    end    
end
