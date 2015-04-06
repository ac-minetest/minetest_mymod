-- road generator
-- definitions: rectangle is defined as R={x1=x1,y1=y1,x2=x2,y2=y2}, road is defined similiarly, but with starting/ending point
-- 1.rectangle_list: initially contains one whole rectangle
-- 2.loop rectangle list, subdivide each rectangle. From newly obtained 2 rectangles add those that can be further subdivided to new list rectangle_list. Remember the lines.
-- 3. if rectangle_list nonempty, go to 2.
-- subdivision: take whole rectangle, randomly decide to split it vertically or horizontally ( if enough thickness).

-- maybe at end: idea: apply minimal spanning tree algorithm on graph ( prim's ), then randomly add some of remaining streets

local rectangle = {}
rectangle.pos = {x=0,y=0,z=0} -- position in minetest to draw from

rectangle.min_width = 0.25
rectangle.min_height = 0.25



local function is_subdivideable(R) 
    --print("dim " ..R.x2-R.x1 .. " " .. R.y2-R.y1)
    if R.x2-R.x1<rectangle.min_width or R.y2-R.y1< rectangle.min_height then return false end
    return true
end



local function genroads()
	local maxsteps = 100;
	rectangle.list = { {x1=0,y1=0,x2=1,y2=1} };rectangle.roads = {};
	local R; local newlist; local steps = 0; 
	while steps<maxsteps and #rectangle.list>0 do
	  steps=steps+1
	  newlist = {};
	  math.randomseed(minetest.get_gametime());
	  for i = 1,#rectangle.list do
		R = rectangle.list[i];
		local is_sub, mode;
		is_sub = is_subdivideable(R)
		--print(" mode " ..mode)
		if is_sub then
		  local f = math.random();
		  local mode = math.random(2);
		local x1,y1,x2,y2; 
		x1 = R.x1;y1=R.y1; x2=R.x2;y2=R.y2;	
		if mode == 1 then -- divide vertically
			local t = R.x1*f+R.x2*(1-f);
			newlist[1+#newlist] = {x1=x1,y1=y1,x2=t,y2=y2}
			newlist[1+#newlist] = {x1=t,y1=y1,x2=x2,y2=y2}
			rectangle.roads[1+#rectangle.roads] = {x1=t,y1=y1,x2=t,y2=y2, step = steps}
			--if steps==1 then print("road " .. t .. " " .. y1 .. " " .. t .. " " ..y2) end
		  else
			local t = R.y1*f+R.y2*(1-f);
			newlist[1+#newlist] = {x1=x1,y1=y1,x2=x2,y2=t};
			newlist[1+#newlist] = {x1=x1,y1=t,x2=x2,y2=y2};
			rectangle.roads[1+#rectangle.roads] = {x1=x1,y1=t,x2=x2,y2=t, step = steps}
			--if steps==1 then print("road " .. x1 .. " " .. t .. " " .. x2 .. " " .. t) end
		  end
		end
	  end
	  rectangle.list = {}; 
	  for i = 1,#newlist do
      rectangle.list[i] = newlist[i];
    end
    
	end
print("step " .. steps)
print ("roads " .. #rectangle.roads)
print(rectangle.roads[#rectangle.roads].step)


end


local function render_line(L,width,height) -- discrete line renderer for minetest
  local x1,y1,x2,y2;
  x1 = L.x1; x2=L.x2; y1=L.y1; y2 = L.y2;
  x1 = math.ceil(x1*width);x2 = math.ceil(x2*width);
  y1 = math.ceil(y1*height);y2 = math.ceil(y2*height);
  local vertical; if x2-x1>0 then vertical = false else vertical = true end
  
  --minetest.chat_send_all("road " .. x1 .. " " .. y1 .. " " .. x2 .. " " .. y2)
  if vertical == false then
    for i = x1, x2 do 
      minetest.set_node({x=rectangle.pos.x + i,y=rectangle.pos.y,z=rectangle.pos.z + y1},{name = "mymod:stone_maze"});
    end
  else
    for i = y1, y2 do 
      minetest.set_node({x=rectangle.pos.x + x1,y=rectangle.pos.y,z=rectangle.pos.z + i},{name = "mymod:stone_maze"});
    end
  end
end


minetest.register_chatcommand("roadgen", {
   description = "roadgenerator",
   privs = {kick = true},
   func = function(name,param)
       local player = minetest.env:get_player_by_name(name)
		if player == nil then return false end
		if param=="" or param==nil then param = name end
		
		rectangle.pos = player:getpos();
		genroads(); local L; local width = 50; local height = 50;
		
		for i = 1,#rectangle.roads do
			L = rectangle.roads[i];
			render_line(L,width,height);
		end
		
		minetest.chat_send_all("done. ".. #rectangle.roads .. " added ");
		
end,	
})

