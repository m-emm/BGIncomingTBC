
function tprint (tbl, indent)
    if not indent then 
        indent = 0 
    end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent+1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))      
        else
            print(formatting .. v)
        end
    end
end

  

function dofile_ns (filename,name,namespace)
    local f = assert (loadfile (filename))
    return f (name,namespace)
end

local namespace = {}
local name = "test"

-- dofile_ns("wowmock.lua",name,namespace)
dofile_ns("BattleGroundModel.lua",name,namespace)




local bgm = namespace.BattleGroundModel:new()

for index, locationDescription in pairs(bgm:getAllLocations()) do
    print("Location: " .. locationDescription.locationKey .. " index " .. locationDescription.index .. " bgKey = " .. locationDescription.bgKey )
    print("Location retrieved chat text: " .. bgm:getLocationByKey(locationDescription.locationKey).chatText  )
end



assert(bgm:locationKey("Blacksmith") == "BS")
assert(bgm:locationKey("Schmiede") == "BS")
assert(bgm:locationKey("Draeneiruinen") == "DR")
assert(bgm:locationKey("Hof") == "FAR")
assert(bgm:locationKey("Farm") == "FAR")


assert(bgm:battleGroundKeyByZoneId(1956) == "eots")
assert(bgm:battleGroundKeyByZoneId(1461) == "ab")

observer = {}

function observer.update(self,model)    
    print("Observer update called with currentLocationKey=" .. ( model.currentLocationKey or "" ) .. " current_bg=" ..  ( model.current_bg or "" ) )
    observer.currentLoc = model.currentLocationKey
    observer.called = true
end

bgm:observe(observer)

bgm:setBattleground("eots")
assert(observer.called)


--tprint(bgm:location_keys())
--tprint(bgm:locations())


bgm:setBattleground("ab")
--tprint(bgm:location_keys())
--tprint(bgm:locations())

bgm:setBattlegroundByZoneId(1956)
assert(bgm.current_bg == "eots")

bgm:setBattlegroundByZoneId(1461)
assert(bgm.current_bg == "ab")


bgm:setCurrentLocationKey("BS")
assert(bgm.currentLocationKey == "BS")

assert(bgm:locationChatText() == "BS")
assert(observer.currentLoc == "BS")

bgm:setCurrentLocationKey("FAR")
assert(bgm:locationChatText() == "Farm")

bgm:setCurrentLocationName("Schmiede")
assert(bgm:locationChatText() == "BS")

bgm:setCurrentLocationName("Draeneiruinen")
assert(bgm:locationChatText() == "BS") -- wrong BG!

print("Stage 0 completed")

bgm:setBattleground("eots")
bgm:setCurrentLocationName("Draeneiruinen")
for index, value in pairs(bgm:location_keys()) do
    print("location key: " .. value)
end

assert(bgm:locationChatText() == "DR") 
assert(bgm:locationCurrentlyActive("DR")) 
assert(bgm:locationCurrentlyActive("FR")) 
assert(bgm:locationCurrentlyActive("MT")) 


assert(not bgm:locationCurrentlyActive("FAR")) 
assert(not bgm:locationCurrentlyActive("BS")) 

bgm:setBattleground("ab")
assert(bgm:locationCurrentlyActive("FAR")) 
assert(bgm:locationCurrentlyActive("BS")) 

assert(not bgm:locationCurrentlyActive("DR")) 
assert(not bgm:locationCurrentlyActive("FR")) 
assert(not bgm:locationCurrentlyActive("MT")) 




print("Test completed")
