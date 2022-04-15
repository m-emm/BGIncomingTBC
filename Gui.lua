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
        topBar = 19,
        numButtons = 6
    }
    
    return self
end

function BGLayouter:placeButton(button,row,col)
    -- note: row 0 is the menu bar on top
    local ySize = buttonSize
    if row == 0 then
        ySize = self.geometry.topBar - 2 * self.geometry.buttonGap
    end
    button:SetSize(self.geometry.buttonSize)
    local yPos =  -self.geometry - row * self.geometry.buttonGap - self.geometry.buttonSize - self.geometry.topBar - (row-1)*self.geometry.buttonSize
    if row == 0 then
        yPos = - self.geometry.topBar -self.geometry.buttonGap -  self.geometry.frameEdge
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


