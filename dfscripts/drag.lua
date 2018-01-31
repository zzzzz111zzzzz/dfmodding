-- Drags a creature

local args = {...}

function drag ()

	local adv=df.global.world.units.active[0]
	local xp,yp,zp=dfhack.units.getPosition(adv)
	local valuetype
	local target
	local i
	local ie
	
	local function  makedrag(ad,tr)
		print('GOT SOME')
		ad.relationship_ids.Draggee=tr.id
		tr.relationship_ids.Dragger=ad.id
	end
	
	local function  familycheck(ad,fam)
		print('familycheck')
		local hf = df.historical_figure.find(ad.hist_figure_id)
		local relathfid = df.historical_figure.find(fam.hist_figure_id)
		for j = #hf.histfig_links-1,0,-1 do
		print(hf.histfig_links[j].target_hf)
			if (hf.histfig_links[j]._type == df.histfig_hf_link_spousest or hf.histfig_links[j]._type == df.histfig_hf_link_childst or hf.histfig_links[j]._type == df.histfig_hf_link_motherst or hf.histfig_links[j]._type == df.histfig_hf_link_fatherst)and(hf.histfig_links[j].target_hf==relathfid.id)
			then				
				print('family!')
				return true
			end
		end
		print('not family!')
		return false
	end
	
	local function  lovecheck(ad,lov)
		print('lovecheck')
		--if (ad.sex~=lov.sex)
		local hf = df.historical_figure.find(ad.hist_figure_id)
		for j = #hf.histfig_links-1,0,-1 do
			if hf.histfig_links[i]._type == df.histfig_hf_link_loverst or 
				hf.histfig_links[i]._type == df.histfig_hf_link_childst or
				hf.histfig_links[i]._type == df.histfig_hf_link_motherst or
				hf.histfig_links[i]._type == df.histfig_hf_link_fatherst
			then
				return true
			else
				return false
			end
		end
		return false
	end
  
	for _,u in ipairs(dfhack.units.getUnitsInBox(xp-1,yp-1,zp,xp+1,yp+1,zp)) do
		if (u~=adv) then
			
			if (u.flags1.drowning==true) or (u.flags1.coward==true) or (u.flags1.caged==true) or (u.flags1.tame==true) or --simple checks
			((adv.flags1.hidden_in_ambush==true)and(u.opponent.unit_id~=adv.id)and(u.relationship_ids.LastAttacker~=adv.id)) or (u.flags3.adv_yield==true) or
			(u.counters.soldier_mood==4) or (u.counters.unconscious>0) or (u.counters.webbed>0) or (u.counters2.sleepiness_timer>1000000)
			then
				print('flag check')
				target=u
				makedrag(adv,target)
				break
			end
			
			--u.status.current_soul.personality.traits	--50
			
			i=0
			ie=#u.status.current_soul.personality.values-1
			while(i<=ie) do
				valuetype = u.status.current_soul.personality.values[i].type
				if familycheck(adv,u) then
					target=u
					break					
				end
				--if (valuetype==2) then	--FAMILY
				--	if	(u.status.current_soul.personality.values[i].strength>-30)and(familycheck(ad,u)) then
				--		target=u
				--		break
				--	end
				--end
				if (valuetype==3) then	--FRIENDSHIP
					if	u.status.current_soul.personality.values[i].strength>10 then
						target=u
						break
					end
				end
				if (valuetype==6) then	--CUNNING
					if	u.status.current_soul.personality.values[i].strength>40 then
						target=u
						break
					end
				end
				if (valuetype==12) then	--COOPERATION
					if	u.status.current_soul.personality.values[i].strength>35 then
						target=u
						break
					end
				end
				if (valuetype==13) then	--INDEPENDENCE
					if	u.status.current_soul.personality.values[i].strength<-25 then
						target=u
						break
					end
				end
				if (valuetype==19) then	--MERRIMENT
					--break
				end
				if (valuetype==24) then	--SACRIFICE
					if	u.status.current_soul.personality.values[i].strength>35 then
						target=u
						break
					end
				end
				if (valuetype==29) then	--ROMANCE
					--break
				end
				if (valuetype==31) then	--PEACE
					if	u.status.current_soul.personality.values[i].strength>35 then
						target=u
						break
					end
				end
				i=i+1
			end
			
			if (target~=nil) then
				makedrag(adv,target)
				break
			end
		end
	end
  

  
end

dfhack.with_suspend(drag)