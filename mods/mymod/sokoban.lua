-- sokoban push mechanics by rnd
local push_time = 0
minetest.register_node("mymod:crate", {
	description = "sokoban crate",
	tiles = {"crate.png"},
	is_ground_content = false,
	groups = {immortal = 1},
	sounds = default.node_sound_wood_defaults(),
	on_punch = function(pos, node, player)
		local time = push_time; local t = minetest.get_gametime();
		if t-time<1 then return end;push_time = t
		--minetest.chat_send_all("time "..t-time)
		local p=player:getpos();local q={x=pos.x,y=pos.y,z=pos.z}
		p.x=p.x-q.x;p.y=p.y-q.y;p.z=p.z-q.z
		--minetest.chat_send_all(" dx " .. p.x .. "  dz " .. p.z .. " dy " .. p.y	)
		if math.abs(p.y+0.5)>0 then return end
		if math.abs(p.x)>math.abs(p.z) then
			--minetest.chat_send_all("direction x")
			if p.z<-0.5 or p.z>0.5 or math.abs(p.x)>1.5 then return end
			if p.x+q.x>q.x then q.x= q.x-1 
				else q.x = q.x+1
			end
		else
			--minetest.chat_send_all("direction z")
			if p.x<-0.5 or p.x>0.5 or  math.abs(p.z)>1.5 then return end
			if p.z+q.z>q.z then q.z= q.z-1 
				else q.z = q.z+1
			end
		end
		if minetest.get_node(q).name=="air" then
			minetest.set_node(pos,{name="air"})
			minetest.set_node(q,{name="mymod:crate"})
			minetest.sound_play("default_dig_dig_immediate", {pos=q,gain=1.0,max_hear_distance = 24,})
		end
	end,
})
