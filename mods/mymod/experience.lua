
-- chat command to see experience
minetest.register_chatcommand("xp", {
    description = "Displays your experience",
    privs = {},
    func = function(name)
        local player = minetest.env:get_player_by_name(name)
		if player == nil then
            -- just a check to prevent the server crashing
            return false
        end
		
		if playerdata[name] == nil or playerdata[name].dig==nil then playerdata[name]={xp=0,dig=0} end		
		minetest.chat_send_player(name, "You have ".. playerdata[name].xp  .. " experience points, skill points: dig ".. playerdata[name].dig.. ", level ".. get_level(playerdata[name].dig) )
end,	
})


-- add experience and skill points on various events
local experience = {}
experience.dig_levels = {[2]=10,[3]=40,[4]=80,[5]=160,[6]=320,[7]=640,[8]=1200,[9]=2400,[10]=5000}

function get_level(xp)
local i,v,j
j=1
	for i,v in pairs(experience.dig_levels) do
		if xp>v then j = i end
	end
	return j
end

minetest.register_on_dignode(function(pos, oldnode, digger)
	if digger == nil then return end
	local name = oldnode.name
	local xp = 0;
	if 
				name == "default:stone" then xp  = 0.01
		elseif  name == "default:stone_with_coal" then xp = 1
		elseif  name == "default:stone_with_iron" then xp = 4
		elseif  name == "default:stone_with_copper" then xp = 4
		elseif  name == "default:stone_with_gold" then xp = 16
		elseif  name == "default:stone_with_mese" then xp = 32
		elseif  name == "default:stone_with_diamond" then xp = 64
		elseif  name == "moreores:mineral_mithril" then xp = 128
	end
	name = digger:get_player_name();
	if playerdata[name] == nil or playerdata[name].xp == nil then init_experience(digger) end
	local oldxp  =  playerdata[name].dig;
	local newxp  = oldxp+xp
	playerdata[name].dig  = newxp
	
	local i,v
	for i,v in pairs(experience.dig_levels) do
		if oldxp<v and newxp>=v then
			minetest.chat_send_player(name, "You have reached level "..i.." in mining.")
		end
	end
	apply_stats(digger)
	
	--APPLY LEVEL RELATED EFFECTS
	local wear -- limits uses of pickaxes
	local dig = newxp;
	
	
	local level = get_level(xp)
	local enhance = 5/level; -- pick wear will be multiplied by this	
	
	
	
	
	local def = ItemStack({name=oldnode.name}):get_definition()
	local wielded = digger:get_wielded_item()
	local tp = wielded:get_tool_capabilities()
	local dp = core.get_dig_params(def.groups, tp)
		
	wielded:add_wear(dp.wear*enhance) -- adds modified wear
	digger:set_wielded_item(wielded) -- this is needed or wear cant be observed


	--minetest.chat_send_player(name, " Wielded item = ".. wielded)
	
	-- to do: if player has enough experience it will drop extra items, maybe decrease wear of tool occasionaly,
	--	increase dig speed (start with low dig speed)
end) 

-- levelup

function apply_stats(player)

local name = player:get_player_name(); if name == nil then return end

if playerdata[name].dig == nil then return end
local dig = playerdata[name].dig;
local enhance=1.0;

if dig >= 10 then enhance = 10. end -- enhancement reward
-- THIS DOES NOTHING FOR NOW
-- minetest.override_item("default:pick_steel", 
-- {
	-- description = "Steel Pickaxe enhanced x"..enhance,
	-- infotext = "Steel Pickaxe enhanced x"..enhance,
	-- inventory_image = "default_tool_steelpick.png",
	-- tool_capabilities = {
		-- full_punch_interval = 1.0/enhance,
		-- max_drop_level=1,
		-- groupcaps={
			-- cracky = {times={[1]=4.00/enhance, [2]=1.60/enhance, [3]=0.80/enhance}, uses=80*enhance, maxlevel=2},
		-- },
		-- damage_groups = {fleshy=4},
	-- },
-- })
end

-- bookeeping functions

--initialize record for new player
minetest.register_on_newplayer(function(player)
	local file = io.open(minetest.get_worldpath().."/players/"..player:get_player_name().."_experience", "w")
	file:write("0\n0")
	file:close()
end) 

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name(); if name == nil then return end
	local file = io.open(minetest.get_worldpath().."/players/"..name.."_experience", "r")
	if not file then -- not yet existing record
		file = io.open(minetest.get_worldpath().."/players/"..name.."_experience", "w")
		file:write("0\n0");file:close()
		file = io.open(minetest.get_worldpath().."/players/"..name.."_experience", "r")
	end
	if playerdata[name] == nil then playerdata[name] = {} end
	local xp = tonumber(file:read("*line")); if xp == nil then xp = 0 end
	playerdata[name].xp  = xp
	local dig = tonumber(file:read("*line")); if dig == nil then dig = 0 end
	playerdata[name].dig = dig
	file:close();
	apply_stats(player)
end)

function init_experience(player)
	local name = player:get_player_name(); if name == nil then return end
	playerdata[name].xp = 0
	playerdata[name].dig = 0;
end

minetest.register_on_leaveplayer(function(player) -- save data when player leaves server
	local name = player:get_player_name(); if name == nil then return end
	local file =  io.open(minetest.get_worldpath().."/players/"..name.."_experience", "w")
	if playerdata[name].dig==nil then init_experience(player) end
	file:write(playerdata[name].xp .. "\n"..playerdata[name].dig);
	file:close()
end)

-- warning: this does not get called in the event of a crash so data is lost, dont want to continually save though
minetest.register_on_shutdown(function()
    for _,player in ipairs(minetest.get_connected_players()) do 
			local name = player:get_player_name();
			local file
			if name ~= nil then
				file =  io.open(minetest.get_worldpath().."/players/"..name.."_experience", "w")
				if playerdata[name].xp==nil then init_experience(player) end
				file:write(playerdata[name].xp .. "\n"..playerdata[name].dig);
				end
				file:close()
			end
	--minetest.chat_send_all("Server shutting down")
end)