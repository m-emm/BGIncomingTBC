local _, namespace = ...

local battlefields = {
	ab = { 
		mapid = 1461,
        locations = {
		    ST = { names = { "Ställe", "Stables" } },
		    BS = { names = {"Schmiede", "Blacksmith" } },
		    GM = { names= {"Goldmine", "Gold Mine" }},
		    LM = { names = {"Sägewerk", "Lumber Mill"} },
            FAR = { names = { "Hof", "Farm" } , chatText = "Farm" },
        }
	},
	eots = {
		mapid = 1956,
        locations = {
		    DR = { names = {"Draeneiruinen","Draenei ruin"}},	
		    MT = { names = {"Magierturm","Mage Tower"}},	
		    BE =  { names = {"Blutelfenturm","Bloodelf Tower"}},	
		    FR = { names = {"Teufelshäscherruinen","Fel Reaver Carcass"}},	
        }
	}
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
    self.bf_desc = battlefields
    for bg_key, bg_desc in pairs(self.bf_desc) do
        self.map_id_to_bg[bg_desc.mapid] = bg_key
        
        for loc_key, loc_desc in pairs(bg_desc.locations) do
            table.insert(self.allLocations,loc_key)
            for index, name in pairs(loc_desc.names) do
                self.name_to_location_key[name] = loc_key
                
            end
        end 
    end
    
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
        print("Changing battleground to " .. bgKey)
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
    local currentLocation = self:locations()[locationKey]
    if currentLocation ~= nil then
        print("Setting current location to " .. locationKey)
        self.currentLocationKey = locationKey
        self:update()
    end
end

function BattleGroundModel:setCurrentLocationName(locationName)
    local locationKey = self:locationKey(locationName)
    if locationKey ~= nil then
        self:setCurrentLocationKey(locationKey)
        self:update()
    end        
end

function BattleGroundModel:locationChatText()
    if self.currentLocationKey ~= nil then
        local currentLocation = self:locations()[self.currentLocationKey]
        if currentLocation.chatText ~= nil then
            return currentLocation.chatText
        else
            return self.currentLocationKey
        end
    end
end

function BattleGroundModel:locations()
    local bg_desc =  self.bf_desc[self.current_bg]    
    if bg_desc ~= nil then
        return bg_desc.locations
    end
    return {}
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





namespace.BattleGroundModel = BattleGroundModel


