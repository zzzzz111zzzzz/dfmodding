-- Turn children of unit into adventurers

local args = {...}

function changesite ()


	local site-- = df.global.world.world_data.sites
	for _,s in ipairs(df.global.world.world_data.sites) do
	--print(dfhack.TranslateName(s.name),'..',s.id)
	if s.id==10
	then
		--s.flags[3]=1
		--s.type=5
		for _,b in ipairs(s.realization.buildings) do
			--print(b.type)
			if (b.type==4)or(b.type==7)or(b.type==8)
			then
				b.type=13
			end
		end
		
		--for _,b in ipairs(s.buildings) do
		--	print(b.type)
		--end
		
		--for _,b in ipairs(s.buildings) do
		--	site = b.getType
		--	print(_site)
		--end
	end
	--print(dfhack.TranslateName(s.name),'..',s.id)
	

	end
	--local nem = dfhack.units.getNemesis(target)
	--if (nem==nil)or(nem==-1) then
	--	createNemesis(target, target.civ_id, -1)
	--end
	--nem=dfhack.units.getNemesis(target)
	--nem.flags.RETIRED_ADVENTURER=true
	
	--df.global.world.nemesis.all[index].flags.RETIRED_ADVENTURER = true
  
end

dfhack.with_suspend(changesite)