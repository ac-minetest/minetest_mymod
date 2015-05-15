Minetest mymod ( first try at minetest modding ) by ac

-redesign of minetest game to include skill system with experience points and magic spells, advanced farming
-added tool/weapons skill requirements
-can only dig certain ores/blocks with certain tools
-mobs overhaul ( much stronger, do more damage away from spawn, give more xp when killed away from spawn)
-improved jail, gravity effect with height, speed adjustment effect
-bone mechanics ( craft everything from bones), start in barren rocky world
-special blocks: bone extractor gives random ores, slow down mine is mese activated and cripples players speed, chicken breeder, game_of_life block,
sokoban level loader block
-new player commands: /maze: generates maze using deep first search backtracking algorithm, /searchlog searches log debug.txt for nearby events, ...
-magic spells: heal spell, fireball spell, slow spell, float spell
- farming: now seed has a quality, dependent on farming skill. Seed quality is directly related to probability of failure during seed growth.
	In case of failure seed devolves back to original state ( when planted ).
- huge amount of tweaks and bug corrections
--------------------------------------------
DETAILED DESCRIPTION OF SERVER

SKILL SYSTEM: 

each action by player ( mining, killing, farming) raises the relevant skill (dig skill, experience, farming skill). Skills determine how well
player can function.
	
	Experience: 
		limits how well can player function in the enviroment:
			-limits efficient usage of weapons ( stone sword - lvl2, steel sword - lvl3, bronze sword - lvl4, silver sword,guns - lvl5, ..)
			-With too little experience player will walk slowly far away from spawn ( speed reduction (7./5)/(distance/500.+1.), this is corrected by
			experience
			-Also there is a limit how far from spawn player can wander (max_dist = 500+(magic+experience)/10), before effects of exhaustion
			set in. Effects include damage while player is in strong light ( 90% of max light).
			-can be used to reduce other player's jail sentence by 1 ( costs 100 xp)
		Experience is obtained by killing monsters ( farther from spawn more experience, monsters with more max hp/armor give more xp)
		
	Magic:
		
		-player can invest experience points into magic points and mana points. 
		-To cast magic spell player needs enough mana, which regenerates on its own ( (magic skill/200+1)*0.1 mana regenerated every 2 seconds).
		Mana points are limited by max_mana quantity.
		-Magic skill directly affects the power of spells and duration of spell effect.
		
		Available spells: heal, fireball, slow, float

	
	Mining skill: 
		limits how deep underground players are able do dig stone (max_depth =  dig skill/5 +200). Also with larger dig skill players
		have access to better pickaxes, otherwise they break quickly. Larger dig skill will additionaly enhance durability of pickaxes.
		Mining skill is gained by (duh) mining. Mining better ores gives more xp (stone<coal<iron=copper<silver<gold<mese<diamond<mithril).

	Farming skill: 

		Plants can grow on wet farming dirt or wet farming sand.

		When seed is planted it is given quality equal to 20 + player farming skill. During growing plant grows larger, with 
		probability 10/quality it fails to do so and grows one step back toward seed. If plant fails completely ( back to seed ),
		block under it turns to dirt and plant changes to grass.

		Each application of hoe during plant growth increases quality by 4. Additionally, on each step of growth quality decreases 
		by 3. So to grow crops successfuly you either need high farming skill OR need to work on plant with hoe during growth.

		Farming skill increases when player harvest succesfuly grown plant. Once plant fully grows it will change block under it
		into dirt.


ENVIROMENT:

	Harsh desert populated by monsters, which become  more dangerous ( more attack damage, better armor, more health) as player moves away
	from spawn. Enviroment imposes extra difficulties on inexperienced players should they wander too far away from spawn.
	
	Gravity changes with height, above height=y=50 its reduced by factor 2/((y/50)^2+1.)
	
	Diving in water becomes dangerous when player dives below depth 10 and damage increases with depth. More shallow water ( >=depth 5) 
	imposes movement speed decrease.
	
	Players are encouraged to place protector which will make their homes into hard to get into fortresses. Any non authorised player
	is interrupted and reminded upon digging and slowed. If he doesnt stop digging he is sent to jail (after 3rd warning). Players that
	spam locked chests without protecting them ( using protector ) can loose their chests either by tnt destruction or takeover (other player
	places protector nearby and attempts to takeover, has 2/3 chance to succeed or 1/3 chance to loose protector).
	
	Players can place city block to punish players killing inside city area. Upon 3rd kill suspected player goes to jail. It is impossible
	to get out of jail until sentence has been served. After that player must wander through small labyrinth to freedom or get another
	player to open jail door from outside.

MOBS: 
	
	Grow stronger with distance from spawn, but give you more xp when killed. Mobs special to this server:
	-rats attack and drop can drop small pieces of wood when dead
	- bees will attack nearby players and can fly up in air. They can be picked up and placed ( in that case they wont attack owner).
	 They can spawn from beehives and attack intruders.
	-soldiers will shoot from far away and drop steel/bread
	-water monster spawns inside water and can swim or follow player outside water. It is capable of basic short distance flight.
	
	
NEW BUILDING BLOCKS:

-landmine: mese activated, it slows all nearby players and reduces their hp (gradually) to 1hp.
-gravity machine : can alter gravity when mese activated, it can be used with deadly effects by hurling player high in air after which he
	falls to his doom or for deadly drop traps with increased fall damage.
-chicken spawner: spawns chickens as long its placed on top of working furnace).
..

		
		
zlib/libpng License
  
Copyright (c) <2015> <ac>

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgement in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
