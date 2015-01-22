-- add experience and skill points on various events
-- 2 kinds of experience for now: experience and dig skill
local experience = {}
experience.dig_levels = {[2]=40,[3]=160,[4]=320,[5]=640,[6]=1280,[7]=2560,[8]=5120,[9]=10240,[10]=20480}
experience.dig_levels_text = ""; for i,v in pairs(experience.dig_levels) do experience.dig_levels_text = experience.dig_levels_text .. i .."/".. v .. "," end

experience.xp ={
["default:stone"]=0.01,
["default:stone_with_coal"]=1,
["default:stone_with_iron"]=4,
["default:stone_with_copper"]= 4,
["default:stone_with_gold"] = 16,
["default:stone_with_mese"] = 32,
["default:stone_with_diamond"] = 64,
["moreores:mineral_mithril"] = 128
}

function get_level(xp) -- given xp, it returns level
local i
local v
local j=1
	for i,v in pairs(experience.dig_levels) do -- maybe it doesnt go through table in presented order???
		if xp>v and i>j then j = i end
	end
	return j
end

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
		
		if playerdata[name] == nil or playerdata[name].dig==nil then return end		
		minetest.chat_send_player(name, name .." has ".. playerdata[name].xp  .. " experience points, skill points: dig ".. playerdata[name].dig.. ", level ".. get_level(playerdata[name].dig ) )
		minetest.chat_send_player(name, "level/dig skill: "..experience.dig_levels_text);
end,	
})

minetest.register_on_dieplayer(
	function(player)
		local name = player:get_player_name()
		if name == nil then return end
		playerdata[name].xp = playerdata[name].xp*0.9
		playerdata[name].dig = playerdata[name].dig*0.9
		playerdata[name].jail = 0
		minetest.chat_send_player(name,"You loose 10% of your experience and skill because you died.");
	end
)



-- minetest.register_on_punchnode(function(pos, node, puncher)


	-- minetest.chat_send_all("node name " .. node.name)
	-- if node.name == "bones:bones" then
		-- if(not is_owner(pos, puncher:get_player_name())) then
			-- return
		-- end
		
		-- --get experience by picking up bones RND
		-- local meta = minetest.get_meta(pos)
		-- local ownername = meta:get_string("owner");
		-- minetest.chat_send_all("bones by " .. owner) -- XXXXX
		-- if ownername~=nil then
			-- local name = puncher:get_player_name()
			-- if name~=nil then
					-- mymod.playerdata[name].xp=mymod.playerdata[name].xp+math.ceil(0.05*mymod.playerdata[ownername].xp*10)/10
					-- minetest.chat_send_player(name,"You collected ".. math.ceil(0.05*playerdata[ownername].xp*10)/10 .." experience from bones.");
			-- end
		-- end
		-- return
	
	-- end

-- end
-- )



minetest.register_on_dignode(function(pos, oldnode, digger)
	if digger == nil then return end
	local name = oldnode.name
	local xp = 0;
	local i,v

	
	for i,v in pairs(experience.xp) do
		if name == i then xp = v end
	end
	
	name = digger:get_player_name(); if name == nil then return end
	local oldxp  =  playerdata[name].dig;
	local newxp  = oldxp+xp
	playerdata[name].dig  = newxp
	
	for i,v in pairs(experience.dig_levels) do -- check if levelup
		if oldxp<v and newxp>=v then
			minetest.chat_send_player(name, "You have reached level "..get_level(newxp).." in mining.")
		end
	end
	
	
	
		
	--APPLY LEVEL RELATED EFFECTS
	local wear -- limits uses of pickaxes
	local dig = newxp;
	
	
	local level = get_level(newxp)
	local enhance = -0.5*level+4.5; -- pick wear will be multiplied by this+1	: 5, ....,0.5 at level 10
	
	if level>=10 then 
		enhance = -0.5 -- means 1-0.5 = 0.5 wear
		i = math.random(1000);
		if i<10 then  digger:set_hp(digger:get_hp()+1) end -- extra heal with levels >=10 with small probability
	end 
		
	--level = 1: en = 5, level = 10: en = 0.5
	-- level*-1/2+5.5-1 = -0.5*level+4.5
	
		
	local def = ItemStack({name=oldnode.name}):get_definition()
	local wielded = digger:get_wielded_item()
	local tp = wielded:get_tool_capabilities()
	local dp = core.get_dig_params(def.groups, tp)
		
	wielded:add_wear(dp.wear*enhance) -- adds modified wear
	digger:set_wielded_item(wielded) -- this is needed or wear is not applied correctly

	
	--minetest.chat_send_player(name, " Wielded item = ".. wielded:get_name())
	
	tp = wielded:get_name() -- for example: default:pick_steel
	-- tool level requirements: steel_pick: level 3, bronze_pick: level 4, diamond_pick: level 6, mithril pick: level 10
	
	if level < 2 and tp == "default:pick_stone" then
		wielded:add_wear(65535/4);digger:set_wielded_item(wielded)
		minetest.chat_send_player(name, " Your inexperience damages the stone pick. Need at least mining level 2, check level with /xp")
	end
	
	if level < 3 and tp == "default:pick_steel" then
		wielded:add_wear(65535/4);digger:set_wielded_item(wielded)
		minetest.chat_send_player(name, " Your inexperience damages the steel pick. Need at least mining level 3, check level with /xp")
	end
	
	if level < 4 and tp == "default:pick_bronze" then
		wielded:add_wear(65535/4);digger:set_wielded_item(wielded)
		minetest.chat_send_player(name, " Your inexperience damages the bronze pick. Need at least mining level 4, check level with /xp")
	end
	
	if level < 5 and tp == "moreores:pick_silver" then
		wielded:add_wear(65535/4);digger:set_wielded_item(wielded)
		minetest.chat_send_player(name, " Your inexperience damages the silver pick. Need at least mining level 5, check level with /xp")
	end
	
	if level < 7 and tp == "default:pick_mese" then
		wielded:add_wear(65535/4);digger:set_wielded_item(wielded)
		minetest.chat_send_player(name, " Your inexperience damages the mese pick. Need at least mining level 7, check level with /xp")
	end
	
	if level < 8 and tp == "default:pick_diamond" then
		wielded:add_wear(65535/4);digger:set_wielded_item(wielded)
		minetest.chat_send_player(name, " Your inexperience damages the diamond pick. Need at least mining level 8, check level with /xp")
	end
	
	if level < 10 and tp == "moreores:pick_mithril" then
		wielded:add_wear(65535/4);digger:set_wielded_item(wielded)
		minetest.chat_send_player(name, " Your inexperience damages the mithril pick. Need at least mining level 10, check level with /xp")
	end

	
	
	-- to do: if player has enough experience it will drop extra items, maybe decrease wear of tool occasionaly,
	--	increase dig speed (start with low dig speed)
end) 




-- levelup: nothing for now

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

--initialize record for new player: experience, dig skill
minetest.register_on_newplayer(function(player)
	write_experience(player)
end) 

function init_write_experience(player)
	local file = io.open(minetest.get_worldpath().."/players/"..player:get_player_name().."_experience", "w")
	file:write("0\n0\n0\n0") -- experience, dig skill, magic, max_mana
	file:close()
end

function init_experience(player)
	local name = player:get_player_name(); if name == nil then return end
	if playerdata[name]==nil then playerdata[name]={} end
	playerdata[name].xp = 0
	playerdata[name].dig = 0;
	playerdata[name].magic = 0;
	playerdata[name].max_mana = 0;
	playerdata[name].mana = 0;
end

minetest.register_on_joinplayer(function(player) -- read data from file or create one
	local name = player:get_player_name(); if name == nil then return end
	local file = io.open(minetest.get_worldpath().."/players/"..name.."_experience", "r")
	if not file then -- not yet existing record
		init_write_experience(player)
		file = io.open(minetest.get_worldpath().."/players/"..name.."_experience", "r")
		if not file then return end-- ERROR!
	end
	local data = tonumber(file:read("*line")); if data == nil then data = 0 end
	playerdata[name].xp  = data
	data = tonumber(file:read("*line")); if data == nil then data = 0 end
	playerdata[name].dig = data
	data = tonumber(file:read("*line")); if data == nil then data = 0 end
	playerdata[name].magic = data
	data = tonumber(file:read("*line")); if data == nil then data = 0 end
	playerdata[name].max_mana = data
	file:close();
	
	--temporary characteristics
	playerdata[name].mana = 0 -- this regenerates
	
	--apply_stats(player)
end)

function write_experience(player)
	local name = player:get_player_name(); if name == nil then return end
	local file =  io.open(minetest.get_worldpath().."/players/"..name.."_experience", "w")
	if playerdata[name].dig==nil then init_experience(player) end
	file:write(playerdata[name].xp .."\n".. playerdata[name].dig .."\n".. playerdata[name].magic .."\n".. playerdata[name].max_mana );
	file:close()
end

minetest.register_on_leaveplayer(function(player) -- save data when player leaves server
	write_experience(player)
end)

-- warning: this does not get called in the event of a crash so data is lost, dont want to continually save though
minetest.register_on_shutdown(function()
    for _,player in ipairs(minetest.get_connected_players()) do 
				write_experience(player)
	end
end)