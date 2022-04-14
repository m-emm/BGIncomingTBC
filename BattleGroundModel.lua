local _, namespace = ...

local battlefields = {
	ab = { 
		mapid = 1461,
        locations = {
		     { locationKey="ST" , names = { "Ställe", "Stables" } },
		     { locationKey="BS" , names = {"Schmiede", "Blacksmith" } },
		     { locationKey="GM" ,names= {"Goldmine", "Gold Mine" }},
		     { locationKey="LM" , names = {"Sägewerk", "Lumber Mill"} },
             { locationKey="FAR" ,names = { "Hof", "Farm" } , chatText = "Farm" },
        }
	},
	eots = {
		mapid = 1956,
        locations = {
		     { locationKey ="DR" , names = {"Draeneiruinen","Draenei ruin"}},	
		     { locationKey ="MT" , names = {"Magierturm","Mage Tower"}},	
		     { locationKey ="BE", names = {"Blutelfenturm","Bloodelf Tower"}},	
		     { locationKey ="FR",  names = {"Teufelshäscherruinen","Fel Reaver Carcass"}},	
        }
	}
}

local messages = { 
    { messageKey ="1" , isIncoming = true},
    { messageKey ="2" , isIncoming = true},
    { messageKey ="4" , isIncoming = true},
    { messageKey ="BIG" , isIncoming = true},
    { messageKey ="PUSH" , isIncoming = false, isSafe = false, isPush = true },
    { messageKey ="SAFE" , isIncoming = false, isSafe = true}

}

local local_location_key_to_chat_text = {
	["FAR"] = "Farm",
	["FL"] = "Flag"
}


local BattleGroundModel = {}
BattleGroundModel.__index = BattleGroundModel
setmetatable(BattleGroundModel, {
    __call = function (cls, ...)
      return cls.new(...)
    end,
  })
  

function BattleGroundModel.new ()
    local self = setmetatable({}, BattleGroundModel)
    self.observers = {}
    self.map_id_to_bg = {}
    self.name_to_location_key = {}    
    self.allLocations = {} 
    self.allLocationsByKey = {}
    self.bf_desc = battlefields
    for bgKey, bg_desc in pairs(self.bf_desc) do
        self.map_id_to_bg[bg_desc.mapid] = bgKey
        
        for locationIndex=1, #bg_desc.locations do
            local currentLocationDesc = bg_desc.locations[locationIndex]
            local chatText = local_location_key_to_chat_text[currentLocationDesc.locationKey] or currentLocationDesc.locationKey
            local currentLocation = { locationKey =currentLocationDesc.locationKey ,  index = locationIndex, bgKey = bgKey,chatText = chatText  }
            table.insert(self.allLocations,currentLocation)
            self.allLocationsByKey[currentLocationDesc.locationKey] = currentLocation
            for index, name in pairs(currentLocationDesc.names) do
                self.name_to_location_key[name] = currentLocationDesc.locationKey                
            end
        end 
    end
    
    self.messages = messages
    return self
end

function BattleGroundModel:update()
    for index, observer in pairs(self.observers) do
        observer:update(self)
    end
end

function BattleGroundModel:observe(observer)
    table.insert(self.observers,observer)
end

function BattleGroundModel:locationKey(name)
    return self.name_to_location_key[name]
end

function BattleGroundModel:battleGroundKeyByZoneId(zoneId)
    return self.map_id_to_bg[zoneId]
end

function BattleGroundModel:setBattleground(bgKey)
    local bg_desc =  self.bf_desc[bgKey]    
    if bg_desc ~= nil then
        self.current_bg = bgKey    
        -- print("Changing battleground to " .. bgKey)
        self:update()
    else
        print("Ignoring unknown bg " .. bgKey)
    end
end

function BattleGroundModel:setBattlegroundByZoneId(zoneId)
    local bgKey = self:battleGroundKeyByZoneId(zoneId)
    if bgKey ~= nil then
        self:setBattleground(bgKey)
    end
end


function BattleGroundModel:setCurrentLocationKey(locationKey)
    local currentLocation = self:getLocationByKey(locationKey)
    if currentLocation ~= nil then
        if currentLocation.bgKey == self.current_bg then
            -- print("Setting current location to " .. locationKey)
            self.currentLocationKey = locationKey
            self:update()
        end
    end
end

function BattleGroundModel:setCurrentLocationName(locationName)
    local locationKey = self:locationKey(locationName)
    if locationKey ~= nil then
        self:setCurrentLocationKey(locationKey)
    end        
end



function BattleGroundModel:locationChatText()
    if self.currentLocationKey ~= nil then
        
        local currentLocation = self:getLocationByKey(self.currentLocationKey)
        if currentLocation.bgKey == self.current_bg then
            if currentLocation.chatText ~= nil then
                return currentLocation.chatText
            else
                return self.currentLocationKey
            end
        end
    end
end

function BattleGroundModel:locations()
    local bg_desc =  self.bf_desc[self.current_bg]    
    if bg_desc ~= nil then
        retval = {}
        for i=1,#bg_desc.locations do
            local currentLocation =  bg_desc.locations[i]
            retval[currentLocation.locationKey] = {locationKey = currentLocation.locationKey , index=currentLocation.index}
        end
        return retval
    end
    return {}
end

function BattleGroundModel:getLocationByKey(locationKey)
    return self.allLocationsByKey[locationKey]
end

function BattleGroundModel:location_keys()    
    local bg_desc =  self.bf_desc[self.current_bg]    
    local retval = {}
    if bg_desc ~= nil then
        for loc_key, loc_desc in pairs(bg_desc.locations) do
            table.insert(retval,loc_key)
        end
        return retval
    end
    return nil
end

function BattleGroundModel:locationCurrentlyActive(locationKey)   
    return self:locations()[locationKey] ~= nil
end

function BattleGroundModel:getAllLocations()
    return self.allLocations
end


function BattleGroundModel:sendMessage(messageInfo)
    
    local message = ""
    local locationChatText =  self:locationChatText()

    if locationChatText ~= nil then
        if messageInfo.isIncoming then
            message = self:locationChatText() .." inc " .. messageInfo.messageKey
        end
        if messageInfo.isPush then
            message = "Push " .. self:locationChatText() .."!"
        end
        if messageInfo.isSafe then
            message = self:locationChatText() .." is safe"
        end
        BGIncomingTBC:Print("sending: ".. message)
        SendChatMessage(message,"INSTANCE_CHAT")
    end
end


namespace.BattleGroundModel = BattleGroundModel


