-- admins search tool
	
	local logfile
	
	minetest.register_chatcommand("searchlog", {
    description = "/searchlog text : searches log(debug.txt) for events in the neighborhood (radius 32) containing text",
    privs = {},
    func = function(name,param)
		local player = minetest.env:get_player_by_name(name)
		local privs = minetest.get_player_privs(name);
		local pos=player:getpos()
		if not privs.kick then return end
		
		if param == "" then minetest.chat_send_player(name,"type text to search for: /searchlog text") end
		
		param = param:gsub("[^%w%s]","") -- remove nasty characters
		logfile = io.open( "debug.txt", "r" );
		if not logfile then minetest.chat_send_player(name,"failed to open debug.txt") return end
		local str = logfile:read( "*all" ); logfile:close();
		local part;
		local p=0;
				
		local i,j,k; i=0;
		local step = 0; local maxsteps = 10; -- return first 10 hits
		
		while step<maxsteps and p<string.len(str) do
		step = step+1
		p=string.find(str, param,p+1)
		if p==nil then minetest.chat_send_player(name," search: nothing else found") return end

		i=p;
		j=string.find(str, "\n",i-80); if j==nil or j>=i then j = math.max(i-80,1) end --find line containing pos i
		k=string.find(str, "\n",i); if k==nil then k =i+80 end; k= math.min(k,i+80);k = math.min(k,string.len(str));
		j=j+1;k=k-1;
		part = string.sub(str,j,k) -- extract part of string to search for coordinates
		--minetest.chat_send_all(part)
		
		local x,y,z,dist
		i=string.find(part,"at %(",1); 
		if i ~= nil then -- look for coordinates
			i=i+4;
			--print (i .. " : " ..string.sub(part,i))
			j=i
			j=string.find(part,",",i);
			x = tonumber(string.sub(part,i,j-1))
			i=string.find(part,",",j+1);
			y=tonumber(string.sub(part,j+1,i-1))
			j=string.find(part,"%)",i+1);
			z=tonumber(string.sub(part,i+1,j-1))
			--minetest.chat_send_player(name," coordinates " .. x.." " .. y .. " " .. z)
			dist = math.max(math.abs(pos.x-x),math.abs(pos.y-y),math.abs(pos.z-z));
			if dist <=32 then minetest.chat_send_player(name,part) end
		end
		
		end	
		minetest.chat_send_player(name," search: nothing else found")
	
	end
	})