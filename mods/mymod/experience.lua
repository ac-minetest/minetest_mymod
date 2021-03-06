-- add experience and skill points on various events
-- 3 kinds of experience for now: experience (fighting), dig skill, magic skill & max_mana
local experience = {}

-- level requirements swords: 2:stone, 3:steel, 4:bronze, 5:silver, 7:mese or guns, 8:diamond, 10: mithril
experience.levels = {[2]=40,[3]=100,[4]=200,[5]=400,[6]=1000,[7]=2000,[8]=4000, [9] = 8000, [10] = 16000}
experience.levels_text = ""; for i,v in pairs(experience.levels) do experience.levels_text = experience.levels_text .. i .."/".. v .. "," end

-- level requirements picks: 2:stone, 3:steel, 4:bronze, 5:silver, 7:mese: 8:diamond, 10 mithril
experience.dig_levels = {[2]=15,[3]=120,[4]=360,[5]=1000,[6]=2000,[7]=4000,[8]=8000,[9]=16000,[10]=32000}
experience.dig_levels_text = ""; for i,v in pairs(experience.dig_levels) do experience.dig_levels_text = experience.dig_levels_text .. i .."/".. v .. "," end


experience.xp ={
["default:stone"]=0.1,
["default:desert_stone"]=0.5,
["default:stone_with_coal"] = 1,
["moreores:mineral_tin"] = 2,
["default:stone_with_copper"]= 4,
["default:stone_with_iron"]= 4,
["moreores:mineral_silver"] = 6,
["default:stone_with_gold"] = 8,
["default:obsidian"] = 16,
["default:stone_with_mese"] = 16,
["default:stone_with_diamond"] = 24,
["moreores:mineral_mithril"] = 32,
["default:mese"] = 32,
["default:nyancat_rainbow"] = 32,
["default:nyancat"] = 64
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





-- -- rnd : changed gui (inside armor mod)

minetest.register_on_player_receive_fields(function(player, formname, fields) 

	--minetest.chat_send_all("formname " .. formname .. " fields " .. dump(fields))
	
	local name = player:get_player_name(); if name==nil then return end;
	if playerdata[name] == nil or playerdata[name].dig==nil then return end	
	
	--custom inventory gui defined in armor.lua
	if formname == "" and fields.xp~=nil then
		if fields.xp == "XP" then		
		local text = "Experience: points " ..playerdata[name].xp .. "/level " ..get_level(playerdata[name].xp) .."\n"..
		"SKILLS\ndig skill points " .. playerdata[name].dig .. "/level " ..get_dig_level(playerdata[name].dig) ..
		"\nmagic skill points " .. playerdata[name].magic .. ", maximum mana " ..playerdata[name].max_mana ..", farming " .. playerdata[name].farming .. "\n"..
		"\nLEVELS for experience: " ..experience.levels_text.."\n"..
		"LEVELS for dig skill: " ..experience.dig_levels_text..
		"\nRULES: To use good weapons you need enough experience. To use good ".. -- removed newlines cause maybe there's autowrap?
		" tools you need enough dig skill. To cast magic you need mana points" .. 
		" (max_mana) and magic skill. Mana regenerates on its own, each 200"..
		" magic skill adds 0.1 mana regenerated per 2 seconds. When you kill monster"..
		" you get experience, it depends on monster health and how away from"..
		"spawn you are. You get dig skill by digging ores. Better ores give "..
		"more skill" ..
		"\n\nfarming: when seed is planted it has quality = farming+20. Each time plant grows there is 1:(0.1*quality) probability it will "..
		"devolve one step back to seed. If it devolves completely it changes to grass. Quality decreases by 2 each grow step. " ..
		"Each time you farm fully grown crop you get extra 0.2 farm skill."..
		" Application of hoe on plant during growth increases seed quality by 3. Hence to successfuly grow plants you must work on filed with hoe."
		
		local form  = 
		"size[8,3.5]" ..  -- width, height
		"textarea[0,0;8.5,3.5;text1;Player "..name.. " STATISTICS;".. text.."]".. -- maybe textlist would enable scroll?
		"button[0,3;4,1;button1;Convert 100 XP to 100 magic skill]"..
		"button[4,3;3.7,1;button2;Convert 100 XP to 0.5 max_mana]"
		
		minetest.show_formspec(name, "mymod:form_experience", form) -- displays form
		end
		return
	end
	
	if formname == "" and fields.chatlog~=nil then
		if fields.chatlog == "chatlog" then
			local text = "";
			local i,v,j
			
			j = chatlog.ind -1;	if j == -1 then j = chatlog.len-1 end -- cant know if server just started but wth..
			
			for i = 0,j do 
				text = text..chatlog.msg[j-i].."\n"
			end
			
			j = chatlog.len-chatlog.ind-2;
			--if chatlog.ind == chatlog.len-1 then j = -1 end
			
			for i = 0,j do 
				text = text..chatlog.msg[chatlog.len-1-i].."\n" 
			end
			
			local form  = 
				"size[9,6.5]" ..  -- width, height
				"textarea[0,0;9.5,8;text1;chat log;"..text.."]";
			minetest.show_formspec(name, "mymod:chatlog", form) -- displays form
		end
		return
	end
	
end)


function show_help(name)

	local text = "TIPS for new players:\n1. read signs at spawn \n2. kill mobs to get stuff and bones \n3. craft dirt and tree saplings from bones \n4. look in craft guide for recipes \n5. dig to get dig skill, kill monsters to get experience, grow farm plants to get farming skill... read more details in xp menu (inventory screen) \n6. sleep in bed to set home\n\npress escape to close this menu "
	local form  = 
			"size[8,3.5]" ..  -- width, height
			"textarea[0,0;8.5,4;text1;introduction;"..text.."]";
	minetest.show_formspec(name, "mymod:form_help", form) -- displays form
end


-- chat command to see experience
minetest.register_chatcommand("xp", {
    description = "Displays your experience, /xp NAME displays other players experience",
    privs = {},
    func = function(name,param)
        local player = minetest.env:get_player_by_name(name)
		local privs = minetest.get_player_privs(name);
		if player == nil then
            -- just a check to prevent the server crashing
            return false
        end
		
		
		if param=="" or param==nil then param = name end
		
		if playerdata[param] == nil or playerdata[param].dig==nil then return end	
		minetest.chat_send_player(name,"XP ".. playerdata[param].xp .."/level ".. get_level(playerdata[param].xp) .. ", dig skill " ..playerdata[param].dig .. "/level " ..get_dig_level(playerdata[param].dig) .. ", farming " .. playerdata[param].farming )
		minetest.chat_send_player(name,"magic "..playerdata[param].magic .. ", max_mana ".. playerdata[param].max_mana)
		if not minetest.get_player_ip(param) then return end
		if privs.kick then minetest.chat_send_player(name,"ip " .. minetest.get_player_ip(param)) end
end,	
})

-- process form output
minetest.register_on_player_receive_fields(function(player, formname, fields) -- this gets called if text sent from form or form exit
    
	
	if formname == "mymod:form_experience" then -- Replace this with your form name
		
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
			playerdata[name].xp = playerdata[name].xp-t; t = math.ceil(0.5*t/100*10)/10
			playerdata[name].max_mana = playerdata[name].max_mana+t; 
			minetest.chat_send_player(name,"Converted xp to "..t.." additional maximum mana");
		end
	return	
	end
	
	 if string.find(formname,"mymod:form_chest_takeover")~=nil then
			if fields["OK"]~=nil then
				local name = player:get_player_name(); if name == nil then return end
				--minetest.chat_send_all("Player "..player:get_player_name().." submitted fields "..dump(fields))
				local param = {};
				for w in formname:gmatch("%S+") do 
					--minetest.chat_send_all(1+#param .. " : " .. w)
					param[1+#param] = tonumber(w);
					
				end
				local pos = {x = param[1],y = param[2] , z= param[3]}
				local ppos = {x = param[4],y = param[5] , z = param[6]}
				--minetest.chat_send_all(pos.x .. " " .. pos.y .. " " .. pos.z)
				--minetest.chat_send_all(ppos.x .. " " .. ppos.y .. " " .. ppos.z)
				local meta = minetest.get_meta(pos)
				local i = math.random(3);
				if i==1 then minetest.set_node(ppos,{name="air"}); minetest.chat_send_player(name,"Take over fail.") return end
				meta:set_string("owner", name) 
				meta:set_string("infotext", "chest taken over by " ..name) 
				minetest.chat_send_player(name,"Congratulations, chest is yours now");
			end
	 end
	 
end)



minetest.register_on_dieplayer(
	function(player)
		local name = player:get_player_name()
		if name == nil then return end
		if playerdata == nil then return end -- ERROR!
		if playerdata[name] == nil then return end -- ERROR!
		if playerdata[name].xp == nil then return end -- ERROR!
		playerdata[name].xp = math.ceil(10*playerdata[name].xp*0.9)/10
		playerdata[name].dig = math.ceil(10*playerdata[name].dig*0.9)/10
		playerdata[name].magic = math.ceil(10*playerdata[name].magic*0.9)/10
		playerdata[name].slow = {time=0, mag = 0}
		playerdata[name].float = {time=0, mag = 0}
		playerdata[name].poison = {time=0, mag = 0}
		playerdata[name].gravity = false
		playerdata[name].jail = 0
		player:set_physics_override({speed =  1.0})
		playerdata[player:get_player_name()].speed = false;  
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

	-- farming related
	
	if oldnode.name=="farming:wheat_8" or oldnode.name== "farming:cotton_8" then
		playerdata[name].farming = playerdata[name].farming + 0.2;
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
	file:write("0\n0\n0\n0\n0") -- experience, dig skill, magic, max_mana, farming
	file:close()
end

function init_experience(player)
	local name = player:get_player_name(); if name == nil then return end
	if playerdata[name]==nil then playerdata[name]={} end
	playerdata[name].xp = 0
	playerdata[name].dig = 0;
	playerdata[name].magic = 0;
	playerdata[name].max_mana = 0;
	playerdata[name].farming = 0;
	
	playerdata[name].mana = 0.;

	playerdata[name].slow = {time=0.,mag=0.}; -- 1st number duration, 2nd magnitude, if 0 no effect, otherwise duration
	playerdata[name].poison = {time=0.,mag=0.}; -- if 0 no effect, otherwise duration in seconds
	playerdata[name].float = {time=0.,mag=0.};
	
	end

	
minetest.register_on_joinplayer(function(player) -- read data from file or create one
	local name = player:get_player_name(); if name == nil then return end
	
	--temporary characteristics
	playerdata[name].mana = 0 -- this regenerates
	playerdata[name].spelltime = minetest.get_gametime();
	playerdata[name].slow = {time=0.,mag=0.};  -- speed == true
	playerdata[name].poison = {time=0.,mag=0.};
	playerdata[name].float = {time=0.,mag=0.}; -- gravity ==  true
	playerdata[name].farming = 0;
	
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
	data = tonumber(file:read("*line")); if data == nil then data = 0 end
	playerdata[name].farming = data;
	file:close();
		
	
	if player:get_hp()<=0 then 
		player:set_hp(20);
		local static_spawnpoint = core.setting_get_pos("static_spawnpoint") ;
		player:setpos(static_spawnpoint)
	end
	
	show_help(name)
	
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
	file:write(playerdata[name].xp .."\n".. playerdata[name].dig .."\n".. playerdata[name].magic .."\n".. playerdata[name].max_mana .."\n".. playerdata[name].farming );
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
	output = "mymod:spell_heal",
	recipe = {
		{"bones:bones", "bones:bones","bones:bones"},
		{"bones:bones", "default:diamond","bones:bones"},
		{"bones:bones", "bones:bones","bones:bones"}
	}
})


minetest.register_node("mymod:spell_heal", {
	description = "beginner healing spell: heal 5 hp for 1 mana, removes basic ill effects",
	wield_image = "health.png",
	wield_scale = {x=0.8,y=0.8,z=0.8}, 
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
	wield_scale = {x=0.8,y=0.8,z=0.8}, 
	drawtype = "allfaces",
	paramtype = "light",
	light_source = 10,
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
		
		if object:is_player() then
			name = object:get_player_name(); if name == nil then return end
			playerdata[name].mana = playerdata[name].mana-2
			playerdata[name].slow.time = playerdata[name].slow.time + 3+math.ceil(10*skill/500)/10
			minetest.chat_send_player(user:get_player_name(),"<SPELL> target slowed 50% for ".. playerdata[name].slow.time .. " seconds.")
			minetest.chat_send_player(name,"<EFFECT> slowed 50% for ".. playerdata[name].slow.time .. " seconds.")
			playerdata[name].slow.mag  = 0.5
			playerdata[name].speed = true
			minetest.sound_play("magic", {pos=user:getpos(),gain=1.0,max_hear_distance = 32,})
			return
		end
		
		if object:get_luaentity() == nil then return end
		if object:get_luaentity().type == "monster" then
			playerdata[name].mana = playerdata[name].mana-2
			object = object:get_luaentity();
			object.slow.time = object.slow.time+3+math.ceil(10*skill/500)/10
			object.slow.mag = 0.5
			minetest.chat_send_player(user:get_player_name(),"<SPELL> target slowed 50% for ".. object.slow.time .. " seconds.")
			minetest.sound_play("magic", {pos=user:getpos(),gain=1.0,max_hear_distance = 32,})
			return
		end
	end
	,
})

-- SPELL FLOAT

minetest.register_craft({
	output = "mymod:spell_float",
	recipe = {
		{"bones:bones", "bones:bones","bones:bones"},
		{"bones:bones", "homedecor:power_crystal","bones:bones"},
		{"bones:bones", "bones:bones","bones:bones"}
	}
})


minetest.register_node("mymod:spell_float", {
	description = "float spell: enable glitch climbing and reduce gravity to max(0.75-magic_skill/5000,0.15) for 5+min(magic_skill/1000,5) seconds",
	wield_image = "bubble.png",
	wield_scale = {x=0.8,y=0.8,z=0.8}, 
	drawtype = "allfaces",
	paramtype = "light",
	light_source = 10,
	tiles = {"bubble.png"},
	groups = {oddly_breakable_by_hand=1},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name(); if name == nil then return end
	
		local t = minetest.get_gametime();
	
		if t-playerdata[name].spelltime<10 then return end;playerdata[name].spelltime = t;  -- only at least 10s after last spell

		if playerdata[name].mana<2 then
			minetest.chat_send_player(name,"Need at least 2 mana"); return
		end
		
		local skill = playerdata[name].magic;
		playerdata[name].float.time = playerdata[name].float.time + 5+math.min(skill/1000,10)
		playerdata[name].float.mag = math.max(0.75-skill/10000,0.15);
		user:set_physics_override({gravity = playerdata[name].float.mag, sneak_glitch = true});
		playerdata[name].gravity = true;
		minetest.sound_play("magic", {pos=user:getpos(),gain=1.0,max_hear_distance = 32,})
		minetest.chat_send_player(name,"[EFFECT] ".. playerdata[name].float.mag  .. " gravity reduction for " .. playerdata[name].float.time .. "s. Hold shift to safely grab the ledge while falling.")
	end
	,
})

-- SPELL HASTE

minetest.register_craft({
	output = "mymod:spell_haste",
	recipe = {
		{"default:diamond", "default:diamond","default:diamond"},
		{"default:diamond", "homedecor:power_crystal","default:diamond"},
		{"default:diamond", "default:diamond","default:diamond"}
	}
})


minetest.register_node("mymod:spell_haste", {
	description = "haste spell: speeds up player 2x for 2+min(magic_skill/500,20) seconds",
	wield_image = "3d_armor_inv_boots_gold.png",
	wield_scale = {x=0.8,y=0.8,z=0.8}, 
	drawtype = "allfaces",
	paramtype = "light",
	light_source = 10,
	tiles = {"3d_armor_inv_boots_gold.png"},
	groups = {oddly_breakable_by_hand=1},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name(); if name == nil then return end
	
		local t = minetest.get_gametime();
	
		if t-playerdata[name].spelltime<10 then return end;playerdata[name].spelltime = t;  -- only at least 10s after last spell

		if playerdata[name].mana<2 then
			minetest.chat_send_player(name,"Need at least 2 mana"); return
		end
		
		local skill = playerdata[name].magic;
		playerdata[name].slow.time =  2+math.min(skill/500,10)
		playerdata[name].slow.mag = 2;
		user:set_physics_override({speed = playerdata[name].slow.mag});
		playerdata[name].speed = true;
		minetest.sound_play("magic", {pos=user:getpos(),gain=1.0,max_hear_distance = 32,})
		minetest.chat_send_player(name,"[EFFECT] ".. playerdata[name].slow.mag  .. "x speed increase for " .. playerdata[name].slow.time .. "s.")
	end
	,
})

-- ARTIFICIAL GRAVITY

minetest.register_node("mymod:gravitator_on", {
	description = "artificial gravity",
	inventory_image = "bubble.png",
	drawtype = "allfaces",
	paramtype = "light",
	light_source = 12,
	wield_image = "bubble.png",
	wield_scale = {x=0.8,y=2.5,z=1.3},
	tiles = {"bubble.png","side_on.png","side_on.png"},
	stack_max = 1,
	groups = {oddly_breakable_by_hand=1,mesecon_effector_on = 1},
	mesecons = {effector = {
		action_off = function (pos, node)
			minetest.swap_node(pos, {name = "mymod:gravitator_off"})
				
			-- turn off gravity effect immidiately
			local objects = minetest.get_objects_inside_radius(pos, 8) -- radius
			for _,obj in ipairs(objects) do
				if (obj:is_player()) then
					local obj_pos = obj:getpos()
					local name = obj:get_player_name();
					playerdata[name].float.time = 0
					playerdata[name].float.mag = 1
					obj:set_physics_override({gravity = 1, sneak_glitch = false});
					playerdata[name].gravity = false;
				end
			end
			
		end
	}}
	}
)

minetest.register_node("mymod:gravitator_off", {
	description = "artificial gravity",
	inventory_image = "bubble.png",
	drawtype = "allfaces",
	paramtype = "light",
	wield_image = "bubble.png",
	wield_scale = {x=0.8,y=2.5,z=1.3},
	tiles = {"bubble.png","side_off.png","side_off.png"},
	stack_max = 1,
	groups = {oddly_breakable_by_hand=1,mesecon_effector_on = 1},
	mesecons = {effector = {
		action_on = function (pos, node)
			minetest.swap_node(pos, {name = "mymod:gravitator_on"})
		end
	}},
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above;
		minetest.set_node(pos,{name = "mymod:gravitator_off"})
		local meta = minetest.get_meta(pos)
		local mag = 1.0
		local form = "size[2,1]".."field[0,0.5;2.5,1;gravitator;set magnitude;"..mag.."]"
		meta:set_string("formspec",form); meta:set_float("mag",mag)
		meta:set_string("owner",placer:get_player_name());
		itemstack:take_item() 
		return itemstack
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.gravitator then
			local meta = minetest.get_meta(pos);
			if sender:get_player_name()~=meta:get_string("owner") then return end		
			 meta:set_float("mag",tonumber(fields.gravitator))
			 meta:set_string("infotext", "Gravity setting : " .. meta:get_string("mag") .. ". Placed by " .. meta:get_string("owner"));
		end
	end,
	}
)

minetest.register_abm(
	{nodenames = {"mymod:gravitator_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos);
		local mag = meta:get_float("mag");
		local objects = minetest.get_objects_inside_radius(pos, 8) -- radius
		for _,obj in ipairs(objects) do
			if (obj:is_player()) then
				local obj_pos = obj:getpos()
				local name = obj:get_player_name();
				playerdata[name].float.time = playerdata[name].float.time + 1
				playerdata[name].float.mag = mag
				obj:set_physics_override({gravity = mag, sneak_glitch = true});
				playerdata[name].gravity = true;
			end
		end
	end
	});

minetest.register_craft({
	output = "mymod:gravitator_off", --"mymod:spell_float"
	recipe = {
		{"", "default:mese",""},
		{"default:mese", "mymod:spell_float","default:mese"},
		{"", "default:mese",""}
	}
})