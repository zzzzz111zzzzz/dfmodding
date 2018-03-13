-- Drag a creature

--This script allows you to drag living creatures behind you(just like in butchering)
--Think of this script as of a demand to follow you rather than physical dragging
--Your target must be either unable to resist, or not wanting to
--Script respects values and personality of the target
--Your target must be in the same tile as your adventurer or nearest tile
--Just call the script and it will check nearest tiles trying to find a target, you don't need to select anybody
--"drag -r" = releases the dragged creature 
--Creatures can break free
--You can attack creatures or speak with them while dragging them
--Fast traveling make them free, but just entering travel screen won't

--SIMPLE CONDITIONS FOR DRAGGING
--being:drowning, coward, caged, tame, yielded, depressed, unconscious, webbed, baby, family member
--you can drag creatures while in stealth mode ignoring those above if they are not attacking you when you try to START dragging them

--COMPLEX CONDITIONS FOR DRAGGING
--something close to a real life demand to follow you

--local args = {...}
local utils=require 'utils'
local confirmation = false

validArgs = --[[validArgs or]]utils.invert({
  'r'
})

local args = utils.processArgs({...}, validArgs)
local rem = false
if args.r then
  rem = true
end

local function  makedrag(ad,tr)
	print('Dragging...')
	ad.relationship_ids.Draggee=tr.id
	tr.relationship_ids.Dragger=ad.id
	tr.unk_238=8
	confirmation = true
end

local function  undrag(ad)
	print('Undragging...')
	local xp,yp,zp=dfhack.units.getPosition(ad)
	for _,tr in ipairs(dfhack.units.getUnitsInBox(xp-1,yp-1,zp,xp+1,yp+1,zp)) do
		if (tr~=ad) then
			if (ad.relationship_ids.Draggee==tr.id)and(tr.relationship_ids.Dragger==ad.id) then
				ad.relationship_ids.Draggee=-1
				tr.relationship_ids.Dragger=-1
				tr.unk_238=0
			end
		end
	end
end

local function  familycheck(ad,fam)
	print('family status check...')
	if (ad.hist_figure_id~=-1)and(fam.hist_figure_id~=-1) then
	
		local hf = df.historical_figure.find(ad.hist_figure_id)
		local relathfid = df.historical_figure.find(fam.hist_figure_id)
		for j = #hf.histfig_links-1,0,-1 do
			if (hf.histfig_links[j]._type == df.histfig_hf_link_spousest or hf.histfig_links[j]._type == df.histfig_hf_link_childst or hf.histfig_links[j]._type == df.histfig_hf_link_motherst or hf.histfig_links[j]._type == df.histfig_hf_link_fatherst)and(hf.histfig_links[j].target_hf==relathfid.id)
			then				
				print('by family...')
				return true
			end
		end
	end
	print('not family...')
	return false
end

local function  lovecheck(ad,lov)
	print('love status check...')
	if (ad.hist_figure_id~=-1)and(lov.hist_figure_id~=-1) then
		local hf = df.historical_figure.find(ad.hist_figure_id)
		local lovfid = df.historical_figure.find(lov.hist_figure_id)
		for j = #hf.histfig_links-1,0,-1 do
			if (hf.histfig_links[j]._type == df.histfig_hf_link_loverst or hf.histfig_links[j]._type == df.histfig_hf_link_spousest)and(hf.histfig_links[j].target_hf==lovfid.id)
			then
				print('by love...')
				return true
			end
		end
	end
	print('no love...')
	return false
end

local function  orientcheck(ad,lov)
	print('orientation check...')
	if (ad.sex==1)and(lov.sex~=1) then
		if (lov.status.current_soul.orientation_flags.marry_male == true)or(lov.status.current_soul.orientation_flags.romance_male == true)
		then
			print('acceptable...')
			return true
		end
	else
		if (ad.sex==0)and(lov.sex~=0) then
			if (lov.status.current_soul.orientation_flags.marry_female == true)or(lov.status.current_soul.orientation_flags.romance_female == true)
			then
				print('acceptable...')
				return true
			end
		end
	end
	print('unacceptable...')
	return false
end


function drag ()

	local adv=df.global.world.units.active[0]
	local xp,yp,zp=dfhack.units.getPosition(adv)
	local valuetype
	local target
	local i
	local ie
	
	for _,u in ipairs(dfhack.units.getUnitsInBox(xp-1,yp-1,zp,xp+1,yp+1,zp)) do
		if (u~=adv) then
			
			if (u.flags1.drowning==true) or (u.flags1.coward==true) or (u.flags1.caged==true) or (u.flags1.tame==true) or --Simple checks
			((adv.flags1.hidden_in_ambush==true)and(u.opponent.unit_id~=adv.id)and(u.relationship_ids.LastAttacker~=adv.id)) or 
			(u.profession==104 and u.profession2==104)	or
			(u.flags3.adv_yield==true) or
			(u.counters.soldier_mood==4) or (u.counters.unconscious>0) or (u.counters.webbed>0)
			then
				print('by unit state...')
				target=u
				makedrag(adv,target)
				break
			end
			
			--Simple personality check
			if	(u.opponent.unit_id~=adv.id)
				and(u.status.current_soul.personality.traits[15]>55)and(u.status.current_soul.personality.traits[19]>40)and(u.status.current_soul.personality.traits[28]<50)
				and(u.status.current_soul.personality.traits[30]>50)and(u.status.current_soul.personality.traits[32]>50)and(u.status.current_soul.personality.traits[40]>55)
				and(u.status.current_soul.personality.traits[42]>40)and(u.status.current_soul.personality.traits[43]>50)and(u.status.current_soul.personality.traits[45]>50)
				and(u.status.current_soul.personality.traits[46]>65)
				then
					print('by personality check...')
					target=u
					makedrag(adv,target)
					break
			end
			
			--Family status check
			print('family status and interest check...')
			if	(u.opponent.unit_id~=adv.id)and(u.status.current_soul.personality.traits[12]<90)and
			(u.status.current_soul.personality.traits[15]>15)and(u.status.current_soul.personality.traits[17]<90)and
			(familycheck(adv,u)) then
						print('Family status and interest confirmed!')
						target=u
						makedrag(adv,target)
						break
			end
			
			i=0
			ie=#u.status.current_soul.personality.values-1
			while(i<=ie)and(i<33) do								--Complex personality checks
			
				valuetype = u.status.current_soul.personality.values[i].type
				
				--[[if (valuetype==2) then	--FAMILY
					print('family interest check...')
					if	(u.status.current_soul.personality.values[i].strength>-25)and(u.opponent.unit_id~=adv.id)
					and(u.status.current_soul.personality.traits[12]<90)and(u.status.current_soul.personality.traits[15]>15)and(u.status.current_soul.personality.traits[17]<90)
					and(familycheck(adv,u)) then
						print('Family interest confirmed!')
						target=u
						break
					end
				end]]--
				if (valuetype==3) then	--FRIENDSHIP
					print('friendliness check...')
					if	(u.status.current_soul.personality.values[i].strength>10)and(u.opponent.unit_id~=adv.id)
					and(u.status.current_soul.personality.traits[12]<90)and(u.status.current_soul.personality.traits[15]>45)and(u.status.current_soul.personality.traits[43]>45)
					and(u.status.current_soul.personality.traits[32]>35)
					then
						print('Friendliness confirmed!')
						target=u
						break
					end
				end
				if (valuetype==6) then	--CUNNING
					print('cunning nature check...')
					if	(u.status.current_soul.personality.values[i].strength>40)and(u.opponent.unit_id==adv.id) 
					and(u.status.current_soul.personality.traits[29]>80)
					then
						print('Cunning confirmed!')
						target=u
						break
					end
				end
				if (valuetype==7) then	--ELOQUENCE
					print('persuasion check...')
					if	(u.status.current_soul.personality.values[i].strength>15)and(u.opponent.unit_id~=adv.id)
					and(u.status.current_soul.personality.traits[15]>35)and(u.status.current_soul.personality.traits[23]>40)and(u.status.current_soul.personality.traits[24]>55)
					and(u.status.current_soul.personality.traits[20]>55)and(u.status.current_soul.personality.traits[32]>50)and(u.status.current_soul.personality.traits[36]>55)
					and(u.status.current_soul.personality.traits[37]>55)
					then
						print('Persuaded!')
						target=u
						break
					end
				end
				if (valuetype==12) then	--COOPERATION
					print('cooperativeness check...')
					if	u.status.current_soul.personality.values[i].strength>10 
					and(u.status.current_soul.personality.traits[15]>35)and(u.status.current_soul.personality.traits[43]>65)and(u.status.current_soul.personality.traits[48]>50)
					then
						print('Cooperativeness confirmed!')
						target=u
						break
					end
				end
				if (valuetype==13) then	--INDEPENDENCE
					print('controllability check...')
					if	u.status.current_soul.personality.values[i].strength<-15 
					and(u.status.current_soul.personality.traits[46]<25)and(u.status.current_soul.personality.traits[19]<35)and(u.status.current_soul.personality.traits[18]<35)
					and(u.status.current_soul.personality.traits[16]>40)and(u.status.current_soul.personality.traits[32]>10)
					then
						print('Controllability confirmed!')
						target=u
						break
					end
				end
				if (valuetype==19) then	--MERRIMENT
					print('merriment interest check...')
					if orientcheck(adv,u)and(u.status.current_soul.personality.values[i].strength>65) 
					and(u.status.current_soul.personality.traits[0]>75)and(u.opponent.unit_id~=adv.id)
					then
						print('Interest confirmed!')
						target=u
						break
					end
				end
				if (valuetype==26) then	--PERSEVERANCE
					print('flexibility check...')
					if	u.status.current_soul.personality.values[i].strength<-15 
					and(u.status.current_soul.personality.traits[12]<15)and(u.status.current_soul.personality.traits[42]>60)
					then
						print('Flexibility confirmed!')
						target=u
						break
					end
				end
				if (valuetype==29) then	--ROMANCE
					print('romance interest check...')
					if (lovecheck(adv,u)and(u.opponent.unit_id~=adv.id)) or 
					(orientcheck(adv,u)and(u.status.current_soul.personality.values[i].strength>15)and(u.status.current_soul.personality.traits[7]>60)and(u.opponent.unit_id~=adv.id)) then
						print('Interest confirmed!')
						target=u
						break
					end
				end
				if (valuetype==31) then	--PEACE
					print('peacefulness check...')
					if	(u.status.current_soul.personality.values[i].strength>25) 
					and(u.status.current_soul.personality.traits[1]<40)and(u.status.current_soul.personality.traits[5]<40)and(u.status.current_soul.personality.traits[27]<40)
					and(u.status.current_soul.personality.traits[38]>65)
					then
						print('Peaceful!')
						target=u
						break
					end
				end
				i=i+1
			end
			
			if (target~=nil) then
				print('by complex condition...')
				makedrag(adv,target)
				break
			end
		end
	end
	if (confirmation==true) then
		print('Success!')
	else
		print('Conditional fail!')
	end
end

function predrag()
	if	(rem==true)	then
		local adv=df.global.world.units.active[0]
		undrag(adv)
		return
	else
		drag()
		return
	end
	return
end

dfhack.with_suspend(predrag)