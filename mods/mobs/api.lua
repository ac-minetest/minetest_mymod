mobs = {}
mobs = {}
mobs.mod = "redo"
function mobs:register_mob(name, def)
	minetest.register_entity(name, {
		name = name,
		hp_min = def.hp_min or 5, --
		hp_max = def.hp_max,
		physical = true,
		owner = def.owner,
		monsterdetect = def.monsterdetect,
		monsterrange = def.monsterrange,
		collisionbox = def.collisionbox,
		visual = def.visual,
		visual_size = def.visual_size,
		mesh = def.mesh,
		textures = def.textures,
		makes_footstep_sound = def.makes_footstep_sound,
		view_range = def.view_range,
		walk_velocity = def.walk_velocity,
		run_velocity = def.run_velocity,
		damage = def.damage,
		light_damage = def.light_damage,
		water_damage = def.water_damage,
		lava_damage = def.lava_damage,
		disable_fall_damage = def.disable_fall_damage,
		drops = def.drops,
		armor = def.armor,
		drawtype = def.drawtype,
		on_rightclick = def.on_rightclick,
		type = def.type,
		attack_type = def.attack_type,
		arrow = def.arrow,
		shoot_interval = def.shoot_interval,
		sounds = def.sounds,
		animation = def.animation,
		follow = def.follow,
		jump = def.jump or true,
		exp_min = def.exp_min or 0,
		exp_max = def.exp_max or 0,
		walk_chance = def.walk_chance or 50,
		attacks_monsters = def.attacks_monsters or false,
		group_attack = def.group_attack or false,
		step = def.step or 0,
		fov = def.fov or 120,
		passive = def.passive or false,
		recovery_time = def.recovery_time or 0.5,
		knock_back = def.knock_back or 3,
		blood_offset = def.blood_offset or 0,
		blood_amount = def.blood_amount or 5, -- 15
		blood_texture = def.blood_texture or "mobs_blood.png",
		rewards = def.rewards or nil,
		animaltype = def.animaltype,
		
		stimer = 0,
		timer = 0,
		env_damage_timer = 0, -- only if state = "attack"
		attack = {player=nil, dist=nil},
		state = "stand",
		v_start = false,
		old_y = nil,
		lifetimer = 600,
		tamed = false,
		last_state = nil,
		pause_timer = 0,
		
		do_attack = function(self, player, dist)
			      if self.state ~= "attack" then
--					if self.sounds.war_cry then
--						if math.random(0,100) < 90 then
--							minetest.sound_play(self.sounds.war_cry,{ object = self.object })
--						end
--					end
				self.state = "attack"
				self.attack.player = player
				self.attack.dist = dist
				end
		end,
		
		set_velocity = function(self, v)
			local yaw = self.object:getyaw()
			if self.drawtype == "side" then
				yaw = yaw+(math.pi/2)
			end
			local x = math.sin(yaw) * -v
			local z = math.cos(yaw) * v
			self.object:setvelocity({x=x, y=self.object:getvelocity().y, z=z})
		end,
		
		get_velocity = function(self)
			local v = self.object:getvelocity()
			return (v.x^2 + v.z^2)^(0.5)
		end,
		
		in_fov = function(self,pos)
			-- checks if POS is in self's FOV
			local yaw = self.object:getyaw()
			if self.drawtype == "side" then
				yaw = yaw+(math.pi/2)
			end
			local vx = math.sin(yaw)
			local vz = math.cos(yaw)
			local ds = math.sqrt(vx^2 + vz^2)
			local ps = math.sqrt(pos.x^2 + pos.z^2)
			local d = { x = vx / ds, z = vz / ds }
			local p = { x = pos.x / ps, z = pos.z / ps }
			
			local an = ( d.x * p.x ) + ( d.z * p.z )
			
			local a = math.deg( math.acos( an ) )
			
			if a > ( self.fov / 2 ) then
				return false
			else
				return true
			end
		end,
		
		set_animation = function(self, type)
			if not self.animation then
				return
			end
			if not self.animation.current then
				self.animation.current = ""
			end
			if type == "stand" and self.animation.current ~= "stand" then
				if
					self.animation.stand_start
					and self.animation.stand_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.stand_start,y=self.animation.stand_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "stand"
				end
			elseif type == "walk" and self.animation.current ~= "walk"  then
				if
					self.animation.walk_start
					and self.animation.walk_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.walk_start,y=self.animation.walk_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "walk"
				end
			elseif type == "run" and self.animation.current ~= "run"  then
				if
					self.animation.run_start
					and self.animation.run_end
					and self.animation.speed_run
				then
					self.object:set_animation(
						{x=self.animation.run_start,y=self.animation.run_end},
						self.animation.speed_run, 0
					)
					self.animation.current = "run"
				end
			elseif type == "punch" and self.animation.current ~= "punch"  then
				if
					self.animation.punch_start
					and self.animation.punch_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.punch_start,y=self.animation.punch_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "punch"
				end
			end
		end,
		
		on_step = function(self, dtime)
			
			if self.type == "monster" and minetest.setting_getbool("only_peaceful_mobs") then
				self.object:remove()
			end
			
			self.lifetimer = self.lifetimer - dtime
			if self.lifetimer <= 0 and not self.tamed and self.type ~= "npc"  and self.type ~= "warpet" then
				local player_count = 0
				for _,obj in ipairs(minetest.get_objects_inside_radius(self.object:getpos(), 10)) do
					if obj:is_player() then
						player_count = player_count+1
					end
				end
				if player_count == 0 and self.state ~= "attack" then
					minetest.log("action","lifetimer expired, removed mob "..self.name)
					self.object:remove()
					return
				end
			end

			-- drop egg
			if self.animaltype == "clucky" then
				
				local static_spawnpoint = core.setting_get_pos("static_spawnpoint") 
				local pos = self.object:getpos()
								
				-- rnd: only lay eggs outside spawn
				if math.random(1, 1000) <= 1 and not (math.abs(pos.x-static_spawnpoint.x)<20 and math.abs(pos.y-static_spawnpoint.y)<20 and math.abs(pos.z-static_spawnpoint.z) < 20) 
				and minetest.get_node(self.object:getpos()).name == "air"
				and self.state == "stand" then
					local d = ItemStack("mobs:egg 1")
					minetest.add_item(pos,d) -- RND FIX: eggs arent placed anymore by chicken
					--minetest.set_node(self.object:getpos(), {name="mobs:egg"})
				end
			end
			
			if self.object:getvelocity().y > 0.1 then
				local yaw = self.object:getyaw()
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				local x = math.sin(yaw) * -2
				local z = math.cos(yaw) * 2
				self.object:setacceleration({x=x, y=-10, z=z})
			else
				self.object:setacceleration({x=0, y=-10, z=0})
			end
			
			if self.disable_fall_damage and self.object:getvelocity().y == 0 then
				if not self.old_y then
					self.old_y = self.object:getpos().y
				else
					local d = self.old_y - self.object:getpos().y
					if d > 5 then
						local damage = d-5
						self.object:set_hp(self.object:get_hp()-damage)
						if self.object:get_hp() == 0 then
							self.object:remove()
						end
					end
					self.old_y = self.object:getpos().y
				end
			end
			
			-- if pause state then this is where the loop ends
			-- pause is only set after a monster is hit
			if self.pause_timer > 0 then
				self.pause_timer = self.pause_timer - dtime
				if self.pause_timer <= 0 then
					self.pause_timer = 0
				end
				return
			end
			
			self.timer = self.timer+dtime
			if self.state ~= "attack" then
				if self.timer < 1 then
					return
				end
				self.timer = 0
			end
			
			if self.sounds and self.sounds.random and math.random(1, 100) <= 1 then
				minetest.sound_play(self.sounds.random, {object = self.object})
			end
			
			local do_env_damage = function(self)
				local pos = self.object:getpos()
				local n = minetest.get_node(pos)
				
				if self.light_damage and self.light_damage ~= 0
					and pos.y>0
					and minetest.get_node_light(pos)
					and minetest.get_node_light(pos) > 4
					and minetest.get_timeofday() > 0.2
					and minetest.get_timeofday() < 0.8
				then
					self.object:set_hp(self.object:get_hp()-self.light_damage)
					if self.object:get_hp() == 0 then
						self.object:remove()
					end
				end
				
				if self.water_damage and self.water_damage ~= 0 and
					minetest.get_item_group(n.name, "water") ~= 0
				then
					self.object:set_hp(self.object:get_hp()-self.water_damage)
					if self.object:get_hp() == 0 then
						self.object:remove()
					end
				end
				
				if self.lava_damage and self.lava_damage ~= 0 and
					minetest.get_item_group(n.name, "lava") ~= 0
				then
					self.object:set_hp(self.object:get_hp()-self.lava_damage)
					if self.object:get_hp() == 0 then
						self.object:remove()
					end
				end
			end
			
			self.env_damage_timer = self.env_damage_timer + dtime
			if self.state == "attack" and self.env_damage_timer > 1 then
				self.env_damage_timer = 0
				do_env_damage(self)
			elseif self.state ~= "attack" then
				do_env_damage(self)
			end
			
			-- FIND SOMEONE TO ATTACK
			if ( self.type == "monster" or self.type == "barbarian" ) and minetest.setting_getbool("enable_damage") and self.state ~= "attack" then
				local s = self.object:getpos()
				local inradius = minetest.get_objects_inside_radius(s,self.view_range)
				local player = nil
				local type = nil
				for _,oir in ipairs(inradius) do
					if oir:is_player() then
						player = oir
						type = "player"
					else
						local obj = oir:get_luaentity()
						if obj then
							player = obj.object
							type = obj.type
						end
					end
					
					if type == "player" or type == "pet" or type == "warpet" then
						local s = self.object:getpos()
						local p = player:getpos()
						local sp = s
						p.y = p.y + 1
						sp.y = sp.y + 1		-- aim higher to make looking up hills more realistic
						local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
						if dist < self.view_range and self.in_fov(self,p) then
							if minetest.line_of_sight(sp,p,2) == true then
								self.do_attack(self,player,dist)
								break
							end
						end
					end
				end
			end
			
			-- NPC FIND A MONSTER TO ATTACK
			if self.type == "warpet" and self.attacks_monsters and self.state ~= "attack" and self.following == player then
				local s = self.object:getpos()
				local inradius = minetest.get_objects_inside_radius(s,self.monsterrange)
				for _, oir in pairs(inradius) do
					local obj = oir:get_luaentity()
					if obj then
						if obj.type == "monster" and self.object:getpos().y-3 <= obj.object:getpos().y and self.object:getpos().y+3 >= obj.object:getpos().y then
							self.following = nil
							self.monsterdetect = true
							local p = obj.object:getpos()
							local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
							if self.monsterdetect == true then
								self.do_attack(self,obj.object,dist)
							else
								self.following = player
							end
							break
						else
							self.monsterdetect = false
						end
					else
						self.monsterdetect = false
						self.following = player
					end
				end
			end

			if self.follow ~= "" and not self.following or self.type == "warpet" then
				for _,player in pairs(minetest.get_connected_players()) do
					local obj = player
					local s = self.object:getpos()
					local p = player:getpos()
					local name = obj:get_player_name()
					local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
					if self.view_range and dist < self.view_range then
						if self.type == "warpet" then
							for _,player in pairs(minetest.get_connected_players()) do
								local obj = player
								local s = self.object:getpos()
								local p = player:getpos()
								local name = obj:get_player_name()
								local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
								if name == self.owner then 
									if self.monsterdetect == false and name == self.owner then
										self.following = obj
									else
										self.following = nil
									end
								end
							end
						else
							self.following = player
						end
						break
					end
				end
			end
			
			if self.following and self.following:is_player() then
				if self.following:get_wielded_item():get_name() ~= self.follow and self.type ~= "warpet" then
					self.following = nil
				else
					local s = self.object:getpos()
					local p = self.following:getpos()
					local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
					if dist > self.view_range then
						if self.monsterdetect == true then
							self.following = nil
							self.v_start = false
						end
					else
						local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
						local yaw = math.atan(vec.z/vec.x)+math.pi/2
						if self.drawtype == "side" then
							yaw = yaw+(math.pi/2)
						end
						if p.x > s.x then
							yaw = yaw+math.pi
						end
						self.object:setyaw(yaw)
						if dist > 2 then
							if not self.v_start then
								self.v_start = true
								self.set_velocity(self, self.walk_velocity)
							else
								if self.jump and self.get_velocity(self) <= 1.5 and self.object:getvelocity().y == 0 then
									local v = self.object:getvelocity()
									v.y = 8 -- rnd increased jump
									self.object:setvelocity(v)
								end
								self.set_velocity(self, self.walk_velocity)
							end
							self:set_animation("walk")
						else
							self.v_start = false
							self.set_velocity(self, 0)
							self:set_animation("stand")
						end
						return
					end
				end
			end

			local yaw = 0 -- rnd
			
			if self.state == "stand" then
				-- randomly turn
				if math.random(1, 4) == 1 then
					-- if there is a player nearby look at them
					local lp = nil
					local s = self.object:getpos()
					if self.type == "npc" then
						local o = minetest.get_objects_inside_radius(self.object:getpos(), 3)
						
						local yaw = 0
						for _,o in ipairs(o) do
							if o:is_player() then
								lp = o:getpos()
								break
							end
						end
					end
					if lp ~= nil then
						local vec = {x=lp.x-s.x, y=lp.y-s.y, z=lp.z-s.z}
						yaw = math.atan(vec.z/vec.x)+math.pi/2
						if self.drawtype == "side" then
							yaw = yaw+(math.pi/2)
						end
						if lp.x > s.x then
							yaw = yaw+math.pi
						end
					else 
						yaw = self.object:getyaw()+((math.random(0,360)-180)/180*math.pi)
					end
					self.object:setyaw(yaw)
				end
				self.set_velocity(self, 0)
				self.set_animation(self, "stand")
				if math.random(1, 100) <= self.walk_chance then
					self.set_velocity(self, self.walk_velocity)
					self.state = "walk"
					self.set_animation(self, "walk")
				end
			elseif self.state == "walk" then
				if math.random(1, 100) <= 30 then
					self.object:setyaw(self.object:getyaw()+((math.random(0,360)-180)/180*math.pi))
				end
				if self.jump and self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0 then
					local v = self.object:getvelocity()
					v.y = 5
					self.object:setvelocity(v)
				end
				self:set_animation("walk")
				self.set_velocity(self, self.walk_velocity)
				if math.random(1, 100) <= 30 then
					self.set_velocity(self, 0)
					self.state = "stand"
					self:set_animation("stand")
				end
			elseif self.state == "attack" and self.attack_type == "dogfight" then
				if not self.attack.player or not self.attack.player:getpos() then
					print("stop attacking")
					self.state = "stand"
					self:set_animation("stand")
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.v_start = false
					self.set_velocity(self, 0)
					self.attack = {player=nil, dist=nil}
					self:set_animation("stand")
					return
				else
					self.attack.dist = dist
				end
				
				local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				if self.attack.dist > 2 then
					if not self.v_start then
						self.v_start = true
						self.set_velocity(self, self.run_velocity)
					else
						if self.jump and self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0 then
							local v = self.object:getvelocity()
							v.y = 5
							self.object:setvelocity(v)
						end
						self.set_velocity(self, self.run_velocity)
					end
					self:set_animation("run")
				else
					self.set_velocity(self, 0)
					self:set_animation("punch")
					self.v_start = false
					if self.timer > 1 then
						self.timer = 0
						local p2 = p
						local s2 = s
						p2.y = p2.y + 1.5
						s2.y = s2.y + 1.5
						if minetest.line_of_sight(p2,s2) == true then
							if self.sounds and self.sounds.attack then
								minetest.sound_play(self.sounds.attack, {object = self.object})
							end
							self.attack.player:punch(self.object, 1.0,  {
								full_punch_interval=1.0,
								damage_groups = {fleshy=self.damage}
							}, vec)
							if self.attack.player:get_hp() <= 0 then
								self.state = "stand"
								self:set_animation("stand")
							end
						end
					end
				end
			elseif self.state == "attack" and self.attack_type == "shoot" then
				if not self.attack.player or not self.attack.player:is_player() then
					self.state = "stand"
					self:set_animation("stand")
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				p.y = p.y - .5
				s.y = s.y + .5
				local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.v_start = false
					self.set_velocity(self, 0)
					if self.type ~= "npc" then
						self.attack = {player=nil, dist=nil}
					end
					self:set_animation("stand")
					return
				else
					self.attack.dist = dist
				end
				
				local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				self.set_velocity(self, 0)
				
				if self.timer > self.shoot_interval and math.random(1, 100) <= 60 then
					self.timer = 0

					self:set_animation("punch")

					if self.sounds and self.sounds.attack then
						minetest.sound_play(self.sounds.attack, {object = self.object})
					end

					local p = self.object:getpos()
					p.y = p.y + (self.collisionbox[2]+self.collisionbox[5])/2
					local obj = minetest.add_entity(p, self.arrow)
					local amount = (vec.x^2+vec.y^2+vec.z^2)^0.5
					local v = obj:get_luaentity().velocity
					vec.y = vec.y+1
					vec.x = vec.x*v/amount
					vec.y = vec.y*v/amount
					vec.z = vec.z*v/amount
					obj:setvelocity(vec)
				end
			end
		end,

		on_activate = function(self, staticdata, dtime_s)
			-- reset HP
			local pos = self.object:getpos()
			local distance_rating = ( ( get_distance({x=0,y=0,z=0},pos) ) / 20000 )	
			local newHP = self.hp_min + math.floor( self.hp_max * distance_rating )
			self.object:set_hp( newHP )

			self.object:set_armor_groups({fleshy=self.armor})
			self.object:setacceleration({x=0, y=-10, z=0})
			self.state = "stand"
			self.object:setvelocity({x=0, y=self.object:getvelocity().y, z=0})
			self.object:setyaw(math.random(1, 360)/180*math.pi)
			if self.type == "monster" and minetest.setting_getbool("only_peaceful_mobs") then
				self.object:remove()
			end
			if self.type ~= "npc" then
				self.lifetimer = 600 - dtime_s
			end
			if staticdata then
				local tmp = minetest.deserialize(staticdata)
				if tmp and tmp.lifetimer then
					self.lifetimer = tmp.lifetimer - dtime_s
				end
				if tmp and tmp.tamed then
					self.tamed = tmp.tamed
				end
				--[[if tmp and tmp.textures then
					self.object:set_properties(tmp.textures)
				end]]
			end
			if self.lifetimer <= 0 and not self.tamed and self.type ~= "npc" and self.type ~= "warpet" and self.type ~= "animal" then
				self.object:remove()
			end
		end,

		get_staticdata = function(self)
			local tmp = {
				lifetimer = self.lifetimer,
				tamed = self.tamed,
				textures = { textures = self.textures },
			}
			return minetest.serialize(tmp)
		end,

		on_punch = function(self, hitter, tflp, tool_capabilities, dir)

			process_weapon(hitter,tflp,tool_capabilities)

			local pos = self.object:getpos()
			if self.object:get_hp() <= 0 then
				if hitter and hitter:is_player() and hitter:get_inventory() then
					for _,drop in ipairs(self.drops) do
						if math.random(1, drop.chance) == 1 then
							local d = ItemStack(drop.name.." "..math.random(drop.min, drop.max))
--							default.drop_item(pos,d)
							local pos2 = pos
							pos2.y = pos2.y + 0.5 -- drop items half block higher
							minetest.add_item(pos2,d)
						end
					end

					--rnd 
					local static_spawnpoint = core.setting_get_pos("static_spawnpoint") 
					local distance =  math.sqrt(math.abs(static_spawnpoint.x-pos.x)^2+math.abs(static_spawnpoint.y-pos.y)^2+math.abs(static_spawnpoint.z-pos.z)^2)
					distance = math.ceil(distance/100*100)/100
					local name = hitter:get_player_name();
					playerdata[name].xp = playerdata[name].xp + distance
					
--					if self.sounds.death ~= nil then
--						minetest.sound_play(self.sounds.death,{
--							object = self.object,
--						})
--					end
--					if minetest.get_modpath("skills") and minetest.get_modpath("experience") then
--						-- DROP experience
--						local distance_rating = ( ( get_distance({x=0,y=0,z=0},pos) ) / ( skills.get_player_level(hitter:get_player_name()).level * 1000 ) )
--						local emax = math.floor( self.exp_min + ( distance_rating * self.exp_max ) )
--						local expGained = math.random(self.exp_min, emax)
--						skills.add_exp(hitter:get_player_name(),expGained)
--						local expStack = experience.exp_to_items(expGained)
--						for _,stack in ipairs(expStack) do
--							default.drop_item(pos,stack)
--						end
--					end

--					-- see if there are any NPCs to shower you with rewards
--					if self.type ~= "npc" then
--						local inradius = minetest.get_objects_inside_radius(hitter:getpos(),10)
--						for _, oir in pairs(inradius) do
--							local obj = oir:get_luaentity()
--							if obj then	
--								if obj.type == "npc" and obj.rewards ~= nil then
--									local yaw = nil
--									local lp = hitter:getpos()
--									local s = obj.object:getpos()
--									local vec = {x=lp.x-s.x, y=1, z=lp.z-s.z}
--									yaw = math.atan(vec.z/vec.x)+math.pi/2
--									if self.drawtype == "side" then
--										yaw = yaw+(math.pi/2)
--									end
--									if lp.x > s.x then
--										yaw = yaw+math.pi
--									end
--									obj.object:setyaw(yaw)
--									local x = math.sin(yaw) * -2
--									local z = math.cos(yaw) * 2
--									acc = {x=x, y=-5, z=z}
--									for _, r in pairs(obj.rewards) do
--										if math.random(0,100) < r.chance then
--											default.drop_item(obj.object:getpos(),r.item, vec, acc)
--										end
--									end
--								end
--							end
--						end
--					end
					
				end
			end

			--blood_particles

			if self.blood_amount > 0 and pos then
				local p = pos
				p.y = p.y + self.blood_offset

				minetest.add_particlespawner(
					5, --blood_amount, --amount
					0.25, --time
					{x=p.x-0.2, y=p.y-0.2, z=p.z-0.2}, --minpos
					{x=p.x+0.2, y=p.y+0.2, z=p.z+0.2}, --maxpos
					{x=0, y=-2, z=0}, --minvel
					{x=2, y=2, z=2}, --maxvel
					{x=-4,y=-4,z=-4}, --minacc
					{x=4,y=-4,z=4}, --maxacc
					0.1, --minexptime
					1, --maxexptime
					0.5, --minsize
					1, --maxsize
					false, --collisiondetection
					self.blood_texture --texture
				)
			end

			-- knock back effect, adapted from blockmen's pyramids mod
			-- https://github.com/BlockMen/pyramids
			local kb = self.knock_back
			local r = self.recovery_time

			if tflp < tool_capabilities.full_punch_interval then
				kb = kb * ( tflp / tool_capabilities.full_punch_interval )
				r = r * ( tflp / tool_capabilities.full_punch_interval )
			end

			local ykb=2
			local v = self.object:getvelocity()
			if v.y ~= 0 then
				ykb = 0
			end 

			self.object:setvelocity({x=dir.x*kb,y=ykb,z=dir.z*kb})
			self.pause_timer = r

			-- attack puncher and call other mobs for help
			if self.passive == false then
				if self.state ~= "attack" then
					self.do_attack(self,hitter,1)
				end
				-- alert other NPCs to the attack
				local inradius = minetest.get_objects_inside_radius(hitter:getpos(),5)
				for _, oir in pairs(inradius) do
					local obj = oir:get_luaentity()
					if obj then
						if obj.group_attack == true and obj.state ~= "attack" then
							obj.do_attack(obj,hitter,1)
						end
					end
				end
			end
		end,
		
	})
end

mobs.spawning_mobs = {}
function mobs:register_spawn(name, nodes, max_light, min_light, chance, active_object_count, max_height, min_dist, max_dist, spawn_func)
	mobs.spawning_mobs[name] = true	
	minetest.register_abm({
		nodenames = nodes,
		neighbors = {"air"},
		interval = 30,
		chance = chance,
		action = function(pos, node, _, active_object_count_wider)
			if active_object_count_wider > active_object_count then
				return
			end
			if not mobs.spawning_mobs[name] then
				return
			end
			
			pos.y = pos.y+1
			if not minetest.get_node_light(pos) then
				return
			end
			if minetest.get_node_light(pos) > max_light then
				return
			end
			if minetest.get_node_light(pos) < min_light then
				return
			end
			if pos.y > max_height then
				return
			end

			if not minetest.registered_nodes[minetest.get_node(pos).name] then return end
			if minetest.registered_nodes[minetest.get_node(pos).name].walkable then return end

			pos.y = pos.y+1

			if not minetest.registered_nodes[minetest.get_node(pos).name] then return end
			if minetest.registered_nodes[minetest.get_node(pos).name].walkable then return end

			if min_dist == nil then
				min_dist = {x=-1,z=-1}
			end
			if max_dist == nil then
				max_dist = {x=33000,z=33000}
			end
	
			if math.abs(pos.x) < min_dist.x or math.abs(pos.z) < min_dist.z then
				return
			end
			
			if math.abs(pos.x) > max_dist.x or math.abs(pos.z) > max_dist.z then
				return
			end
		
			if spawn_func and not spawn_func(pos, node) then
				return
			end

			if minetest.setting_getbool("display_mob_spawn") then
				minetest.chat_send_all("[mobs] Add "..name.." at "..minetest.pos_to_string(pos))
			end
			local mob = minetest.add_entity(pos, name)

			-- setup the hp, armor, drops, etc... for this specific mob
			local distance_rating = ( ( get_distance({x=0,y=0,z=0},pos) ) / 15000 )	
			if mob then
				mob = mob:get_luaentity()
				local newHP = mob.hp_min + math.floor( mob.hp_max * distance_rating )
				mob.object:set_hp( newHP )
				-- rnd change: make monsters with tougher armor away from spawn or deeper:)
				local spawnpoint = core.setting_get_pos("static_spawnpoint")
				local mult = math.sqrt((pos.x-spawnpoint.x)^2+(pos.y-spawnpoint.y)^2+(pos.z-spawnpoint.z)^2)
				if pos.y-spawnpoint.y>-50 then -- on surface distance from spawn
					mult = 1/(mult/500+1.) -- at distance 0 armor is normal, at 500 it 50% (smaller the better)
				else
					mult = math.abs(pos.y-spawnpoint.y); -- deep enough only depth
					mult = 1/(mult/300+1.) -- depth 300, double armor
				end
				local new_armor = math.max(mob.armor*mult,1);
				mob.object:set_armor_groups({fleshy=new_armor})
				
				-- rnd DOESNT SEEM TO WORK CORRECTLY! drops everything ??
				-- local dropst = mob.drops;
				-- for i,_ in pairs(dropst) do -- more probability of drops, DOES THIS WORK CORRECTLY?
					-- mob.drops[i].chance=math.max(1,math.ceil(dropst[i].chance*mult))
				-- end
				 --TO DO make dungeon master info "stonemonster king with flaming crown on its head"
				
				
			end
		end
	})
end

function mobs:register_arrow(name, def)
	minetest.register_entity(name, {
		physical = false,
		visual = def.visual,
		visual_size = def.visual_size,
		textures = def.textures,
		velocity = def.velocity,
		hit_player = def.hit_player,
		hit_node = def.hit_node,
		collisionbox = {0,0,0,0,0,0}, -- remove box around arrows

		on_step = function(self, dtime)
			local pos = self.object:getpos()
			if minetest.get_node(self.object:getpos()).name ~= "air" then
				self.hit_node(self, pos, node)
				self.object:remove()
				return
			end
			-- pos.y = pos.y-1.0
			for _,player in pairs(minetest.get_objects_inside_radius(pos, 2)) do
				if player:is_player() then
					self.hit_player(self, player)
					self.object:remove()
					return
				end
			end
		end
	})
end

function get_distance(pos1,pos2)
	if ( pos1 ~= nil and pos2 ~= nil ) then
		return math.abs(math.floor(math.sqrt( (pos1.x - pos2.x)^2 + (pos1.z - pos2.z)^2 )))
	else
		return 0
	end
end

function process_weapon(player, time_from_last_punch, tool_capabilities)
local weapon = player:get_wielded_item()
	if tool_capabilities ~= nil then
		--local wear = ( tool_capabilities.full_punch_interval / 75 ) * 65535
		-- rnd change: wear when hitting monsters
		local wear
		if tool_capabilities.groupcaps.snappy~=nil then
			wear = 65535/(tool_capabilities.groupcaps.snappy.uses)
			else wear = 65535/50
		end
		weapon:add_wear(wear)
		player:set_wielded_item(weapon)
	end
	
--	if weapon:get_definition().sounds ~= nil then
--		local s = math.random(0,#weapon:get_definition().sounds)
--		minetest.sound_play(weapon:get_definition().sounds[s], {
--			object=player,
--		})
--	else
--		minetest.sound_play("default_sword_wood", {
--			object = player,
--		})
--	end	
end


