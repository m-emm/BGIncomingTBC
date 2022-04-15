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
    self.geometry = {
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

function BGLayouter:placeButton(button, row, col)
    -- note: row 0 is the menu bar on top
    local ySize = self.geometry.buttonSize
    if row == 0 then
        ySize = self.geometry.topBar - 2 * self.geometry.buttonGap
    end

    button:SetSize(self.geometry.buttonSize, ySize)
    local yPos =
        -self.geometry.frameEdge - (row - 1) * self.geometry.buttonGap - self.geometry.topBar -
        (row - 1) * self.geometry.buttonSize
    if row == 0 then
        yPos = -self.geometry.buttonGap - self.geometry.frameEdge
    end
    button:SetPoint(
        "TOPLEFT",
        button:GetParent(),
        "TOPLEFT",
        (self.geometry.buttonSize + self.geometry.buttonGap) * (col - 1) + self.geometry.frameEdge +
            self.geometry.buttonGap,
        yPos
    )
end

function BGLayouter:placeFrame(frame)
    frame:SetSize(
        (self.geometry.numButtons) * (self.geometry.buttonSize + self.geometry.buttonGap) + self.geometry.buttonGap +
            2 * self.geometry.frameEdge,
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

function BGIncomingButton.new(frame, text, fontSize)
    local o = CreateFrame("Button", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
    setmetatable(BGIncomingButton, getmetatable(o))
    local self = setmetatable(o, BGIncomingButton)
    self.__index = self
    self.text = text
    self.activeColors = {bg = {r = 1.0, g = 0.5, b = 0.1}, rw = {r = 1.0, g = 0, b = 0.0}}

    self.activeColor = self.activeColors.bg

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

    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    self:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")

    textObject = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    textObject:SetFont("Fonts\\ARIALN.TTF", fontSize)
    textObject:SetJustifyH("CENTER")
    textObject:SetPoint("CENTER")
    textObject:SetText(text)
    self.textObject = textObject
    self:setActive(false)

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
    self.active = active
    if active then
        self:SetBackdropColor(self.activeColor.r, self.activeColor.g, self.activeColor.b, 1.0)
        self.textObject:SetTextColor(0.3, 0.3, 0.3, 1.0)
    else
        self:SetBackdropColor(0.4, 0.4, 0.4, 0.5)
        self.textObject:SetTextColor(1.0, 1.0, 0.0, 1.0)
    end
end

function BGIncomingButton:setRaidWarning(raidWarning)
    if raidWarning then
        self.activeColor = self.activeColors.rw
    else
        self.activeColor = self.activeColors.bg
    end
    if self.active then
        self:SetBackdropColor(self.activeColor.r, self.activeColor.g, self.activeColor.b, 1.0)
    end
end
