-- cripple land mine, activated by mese


LANDMINE_RANGE = 4

minetest.register_abm(
	{nodenames = {"mymod:landmine_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos)

	local objects = minetest.get_objects_inside_radius(pos, LANDMINE_RANGE) -- radius
	for _,obj in ipairs(objects) do
		if (obj:is_player()) then
			local obj_pos = obj:getpos()
			local dist = vector.distance(obj_pos, pos)
			local damage = 1
			if dist > 0 and obj:get_hp()>1 then -- no damage if hp<=1
				if playerdata[obj:get_player_name()].speed==false then -- player not yet affected
					minetest.chat_send_player(obj:get_player_name(), "<EFFECT> slowed by mine")
				end
				obj:set_physics_override({speed =  0.1});
				local name = obj:get_player_name();
				playerdata[name].speed = true; -- remember that speed was changed
				if	 playerdata[name].slow ~= nil then
					playerdata[name].slow.time = playerdata[name].slow.time + 60
				end
				obj:punch(obj, 1.0, {
						 full_punch_interval = 1.0,
						 damage_groups = {fleshy=damage},
					})
				
			end
		end
	end 
	end,
}) 



minetest.register_node("mymod:landmine_on", {
	description = "landmine on",
	inventory_image = "side_on.png",
	wield_image = "side_on.png",
	wield_scale = {x=0.8,y=2.5,z=1.3},
	tiles = {"side_on.png","side_on.png","side_on.png"},
	stack_max = 1,
	groups = {oddly_breakable_by_hand=1,mesecon_effector_on = 1},
	mesecons = {effector = {
		action_off = function (pos, node)
			minetest.swap_node(pos, {name = "mymod:landmine_off"})
		end
	}}
	}
)



minetest.register_node("mymod:landmine_off", {
	description = "landmine off",
	inventory_image = "side_off.png",
	wield_image = "side_off.png",
	wield_scale = {x=0.8,y=2.5,z=1.3},
	tiles = {"side_off.png","side_off.png","side_off.png"},
	stack_max = 1,
	groups = {oddly_breakable_by_hand=1,mesecon_effector_on = 1},
	mesecons = {effector = {
		action_on = function (pos, node)
			minetest.swap_node(pos, {name = "mymod:landmine_on"})
			local objects = minetest.get_objects_inside_radius(pos, LANDMINE_RANGE) -- radius
			for _,obj in ipairs(objects) do
				if (obj:is_player()) then
					local obj_pos = obj:getpos()
					local dist = vector.distance(obj_pos, pos)
					if dist > 0 then -- restore movement speed, whatever....
						obj:set_physics_override({speed =  0.1});
					end
				end
			end		
		end
	}}
	}
)

 
 minetest.register_on_dieplayer(function(player) -- restore ill effects with death
	player:set_physics_override({speed =  1.0})
	playerdata[player:get_player_name()].speed = false; 
 end)
 
 
 minetest.register_craft({
	output = "mymod:landmine_off",
	recipe = {
		{"","default:mese_crystal",""},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})