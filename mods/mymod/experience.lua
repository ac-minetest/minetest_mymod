-- add experience and skill points on various events
-- 2 kinds of experience for now: experience and dig skill
local experience = {}

-- level requirements swords: 2:stone, 3:steel, 4:bronze, 5:silver, 7:mese or guns, 8:diamond, 10: mithril
experience.levels = {[2]=40,[3]=100,[4]=200,[5]=400,[6]=1000,[7]=2000,[8]=4000, [9] = 8000, [10] = 16000}
experience.levels_text = ""; for i,v in pairs(experience.levels) do experience.levels_text = experience.levels_text .. i .."/".. v .. "," end

-- level requirements picks: 2:stone, 3:steel, 4:bronze, 5:silver, 7:mese: 8:diamond, 10 mithril
experience.dig_levels = {[2]=15,[3]=120,[4]=320,[5]=640,[6]=1280,[7]=2560,[8]=5120,[9]=10240,[10]=20480}
experience.dig_levels_text = ""; for i,v in pairs(experience.dig_levels) do experience.dig_levels_text = experience.dig_levels_text .. i .."/".. v .. "," end


experience.xp ={
["default:stone"]=0.1,
["default:stone_with_coal"] = 1,
["moreores:mineral_tin"] = 2,
["default:stone_with_copper"]= 4,
["default:stone_with_iron"]= 4,
["moreores:mineral_silver"] = 6,
["default:stone_with_gold"] = 8,
["default:stone_with_mese"] = 16,
["default:stone_with_diamond"] = 24,
["moreores:mineral_mithril"] = 32
}

function get_level(xp) -- given xp, it returns level
local i
local v
local j=1
	for i,v in pairs(experience.levels) do -- maybe it doesnt go through table in presented order???
		if xp>v and i>j then j = i end
	end
	return j
end

function get_dig_level(xp) -- given xp, it returns level
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
    description = "Displays your experience, /xp NAME displays other players experience",
    privs = {},
    func = function(name,param)
        local player = minetest.env:get_player_by_name(name)
		if player == nil then
            -- just a check to prevent the server crashing
            return false
        end
		if param~="" and param~=nil then -- display others xp
			if playerdata[param] == nil or playerdata[param].dig==nil then return end	
			minetest.chat_send_player(name,"XP ".. playerdata[param].xp .."/level ".. get_level(playerdata[param].xp) .. ", dig skill " ..playerdata[param].dig .. "/level " ..get_dig_level(playerdata[param].dig) )
			minetest.chat_send_player(name,"magic "..playerdata[param].magic .. ", max_mana ".. playerdata[param].max_mana)
		return
		end
		
		if playerdata[name] == nil or playerdata[name].dig==nil then return end	
		-- TO DO: paste form here..
		
		local text = "Experience: points " ..playerdata[name].xp .. "/level " ..get_level(playerdata[name].xp) .."\n"..
		"SKILLS\ndig skill points " .. playerdata[name].dig .. "/level " ..get_dig_level(playerdata[name].dig) ..
		"\nmagic skill points " .. playerdata[name].magic .. ", maximum mana " ..playerdata[name].max_mana .."\n"..
		"\nLEVELS for experience: " ..experience.levels_text.."\n"..
		"LEVELS for dig skill: " ..experience.dig_levels_text..
		"\nRULES: To use good weapons you need enough experience. To use good ".. -- removed newlines cause maybe there's autowrap?
		"tools you need enough dig skill. To cast magic you need mana points" .. 
		"(max_mana) and magic skill. Mana regenerates on its own, each 100"..
		"magic skill adds 0.1 mana regenerated per step. When you kill monster"..
		"you get experience, it depends on monster health and how away from"..
		"spawn you are. You get dig skill by digging ores. Better ores give"..
		"more skill"
		
		local form  = 
		"size[8,3.5]" ..  -- width, height
		"textarea[0,0;8.5,3.5;text1;Player "..name.. " STATISTICS;".. text.."]".. -- maybe textlist would enable scroll?
		"button[0,3;4,1;button1;Convert 100 XP to 100 magic skill]"..
		"button[4,3;3.7,1;button2;Convert 100 XP to 1 max_mana]"
		
		minetest.show_formspec(name, "mymod:form_experience", form) -- displays form
end,	
})

-- process form output
minetest.register_on_player_receive_fields(function(player, formname, fields) -- this gets called if text sent from form or form exit
    if formname == "mymod:form_experience" then -- Replace this with your form name
		--minetest.chat_send_all("Player "..player:get_player_name().." submitted fields "..dump(fields))
		
		if fields["button1"]~=nil then 
			local name = player:get_player_name(); if name == nil then return end
			local t = playerdata[name].xp; if t>100 then t=100	end
			playerdata[name].magic = playerdata[name].magic+t; playerdata[name].xp = playerdata[name].xp-t
			minetest.chat_send_player(name,"Converted " .. t .. " xp to magic skill ");
		end
		
		if fields["button2"]~=nil then 
			local name = player:get_player_name(); if name == nil then return end
			local t = playerdata[name].xp; 
			if t>100 then t=100 end
			playerdata[name].xp = playerdata[name].xp-t; t = math.ceil(t/100*10)/10
			playerdata[name].max_mana = playerdata[name].max_mana+t; 
			minetest.chat_send_player(name,"Converted xp to "..t.." additional maximum mana");
		end
		
		
	end
end)



minetest.register_on_dieplayer(
	function(player)
		local name = player:get_player_name()
		if name == nil then return end
		playerdata[name].xp = math.ceil(10*playerdata[name].xp*0.9)/10
		playerdata[name].dig = math.ceil(10*playerdata[name].dig*0.9)/10
		playerdata[name].magic = math.ceil(10*playerdata[name].magic*0.9)/10
		playerdata[name].slow = {time=0, mag = 0}
		playerdata[name].poison = {time=0, mag = 0}
		playerdata[name].jail = 0
		minetest.chat_send_player(name,"You loose 10% of your experience and skills because you died.");
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
			minetest.chat_send_player(name, "You have reached level "..get_dig_level(newxp).." in mining.")
		end
	end
	
	
	
		
	--APPLY LEVEL RELATED EFFECTS
	local wear -- limits uses of pickaxes
	local dig = newxp;
	
	
	local level = get_dig_level(newxp)
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
	init_experience(player)
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
	playerdata[name].mana = 0.;

	playerdata[name].slow = {time=0.,mag=0.}; -- 1st number duration, 2nd magnitude, if 0 no effect, otherwise duration
	playerdata[name].poison = {time=0.,mag=0.}; -- if 0 no effect, otherwise duration in seconds

	
	end

	
minetest.register_on_joinplayer(function(player) -- read data from file or create one
	local name = player:get_player_name(); if name == nil then return end
	
	--temporary characteristics
	playerdata[name].mana = 0 -- this regenerates
	playerdata[name].spelltime = minetest.get_gametime();
	playerdata[name].slow = {time=0.,mag=0.}; 
	playerdata[name].poison = {time=0.,mag=0.};
	
	-- read saved characteristics
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
	
	--apply_stats(player)
end)

function write_experience(player)
	local name = player:get_player_name(); if name == nil then return end
	local file =  io.open(minetest.get_worldpath().."/players/"..name.."_experience", "w")
	if playerdata[name].dig==nil then 
		minetest.chat_send_all("ERROR WRITING EXPERIENCE!")
		return 
	end
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

-- MAGIC SPELLS

-- HEALING

minetest.register_craft({
	output = "mymod:spell_heal_beginner",
	recipe = {
		{"bones:bones", "bones:bones","bones:bones"},
		{"bones:bones", "default:diamond","bones:bones"},
		{"bones:bones", "bones:bones","bones:bones"}
	}
})


minetest.register_node("mymod:spell_heal_beginner", {
	description = "beginner healing spell: heal 5 hp for 1 mana, removes basic ill effects",
	wield_image = "health.png",
	wield_scale = {x=0.8,y=2.5,z=1.3}, 
	tiles = {"health.png"},
	groups = {oddly_breakable_by_hand=1},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name(); if name == nil then return end
		local t = minetest.get_gametime();if t-playerdata[name].spelltime<2 then return end;playerdata[name].spelltime = t; -- only heal every 2 seconds
		
		if playerdata[name].mana<1 then
			minetest.chat_send_player(name,"Need at least 1 mana"); return
		end
		if user:get_hp()<20 then
			playerdata[name].mana = playerdata[name].mana-1
			playerdata[name].speed = false -- neutralize ill speed effect
			user:set_hp(user:get_hp()+5)
			minetest.chat_send_player(name,"Healed 5 hp.")	
			minetest.sound_play("magic", {pos=user:getpos(),gain=1.0,max_hear_distance = 32,})
		else minetest.chat_send_player(name,"Full health already.")	
		end
	end
	,
})

-- SLOW

minetest.register_craft({
	output = "mymod:spell_slow",
	recipe = {
		{"bones:bones", "bones:bones","bones:bones"},
		{"bones:bones", "mobs:cobweb","bones:bones"},
		{"bones:bones", "bones:bones","bones:bones"}
	}
})


minetest.register_node("mymod:spell_slow", {
	description = "slow spell: slow 50% for 3+magic skill/500 seconds",
	wield_image = "slow.png",
	wield_scale = {x=0.8,y=2.5,z=1.3}, 
	tiles = {"slow.png"},
	groups = {oddly_breakable_by_hand=1},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name(); if name == nil then return end
		local t = minetest.get_gametime();if t-playerdata[name].spelltime<5 then return end;playerdata[name].spelltime = t; -- only at least 5s after last spell

		if playerdata[name].mana<2 then
			minetest.chat_send_player(name,"Need at least 2 mana"); return
		end
		
		local skill = playerdata[name].magic;
		
		if pointed_thing.type ~= "object" then return end -- only slow objects
		local object = pointed_thing.ref
		if not object:is_player() then return end
		name = object:get_player_name(); if name == nil then return end
		playerdata[name].slow.time = playerdata[name].slow.time + 3+skill/500 -- ERROR READING table entry
		minetest.chat_send_player(name,"<EFFECT> slowed for ".. playerdata[name].slow.time .. " seconds.")
		playerdata[name].slow.mag  = 0.5
		playerdata[name].speed = true
		minetest.sound_play("magic", {pos=user:getpos(),gain=1.0,max_hear_distance = 32,})
	end
	,
})




