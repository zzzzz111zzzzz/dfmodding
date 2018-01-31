-- Impregnates

local args = {...}
local utils=require 'utils'

local function  allocateNewChunk(hist_entity)
  hist_entity.save_file_id=df.global.unit_chunk_next_id
  df.global.unit_chunk_next_id=df.global.unit_chunk_next_id+1
  hist_entity.next_member_idx=0
  print("allocating chunk:",hist_entity.save_file_id)
end

local function allocateIds(nemesis_record,hist_entity)
  if hist_entity.next_member_idx==100 then
    allocateNewChunk(hist_entity)
  end
  nemesis_record.save_file_id=hist_entity.save_file_id
  nemesis_record.member_idx=hist_entity.next_member_idx
  hist_entity.next_member_idx=hist_entity.next_member_idx+1
end

local function createFigure(trgunit,he,he_group)
  local hf=df.historical_figure:new()
  hf.id=df.global.hist_figure_next_id
  hf.race=trgunit.race
  hf.caste=trgunit.caste
  hf.profession = trgunit.profession
  hf.sex = trgunit.sex
  df.global.hist_figure_next_id=df.global.hist_figure_next_id+1
  hf.appeared_year = df.global.cur_year

  hf.born_year = trgunit.birth_year
  hf.born_seconds = trgunit.birth_time
  hf.curse_year = trgunit.curse_year
  hf.curse_seconds = trgunit.curse_time
  hf.birth_year_bias = trgunit.birth_year_bias
  hf.birth_time_bias = trgunit.birth_time_bias
  hf.old_year = trgunit.old_year
  hf.old_seconds = trgunit.old_time
  hf.died_year = -1
  hf.died_seconds = -1
  hf.name:assign(trgunit.name)
  hf.civ_id = trgunit.civ_id
  hf.population_id = trgunit.population_id
  hf.breed_id = -1
  hf.unit_id = trgunit.id

  df.global.world.history.figures:insert("#",hf)

  hf.info = df.historical_figure_info:new()
  hf.info.unk_14 = df.historical_figure_info.T_unk_14:new() -- hf state?
  --unk_14.region_id = -1; unk_14.beast_id = -1; unk_14.unk_14 = 0
  hf.info.unk_14.unk_18 = -1; hf.info.unk_14.unk_1c = -1
  -- set values that seem related to state and do event
  --change_state(hf, dfg.ui.site_id, region_pos)


  --lets skip skills for now
  --local skills = df.historical_figure_info.T_skills:new() -- skills snap shot
  -- ...
  -- note that innate skills are automaticaly set by DF
  hf.info.skills = {new=true}

  if (he and he~=-1) then
    he.histfig_ids:insert('#', hf.id)
    he.hist_figures:insert('#', hf)
  end
  if (he_group and he_group~=-1) then
    he_group.histfig_ids:insert('#', hf.id)
    he_group.hist_figures:insert('#', hf)
    hf.entity_links:insert("#",{new=df.histfig_entity_link_memberst,entity_id=he_group.id,link_strength=100})
  end
  trgunit.flags1.important_historical_figure = true
  trgunit.flags2.important_historical_figure = true
  trgunit.hist_figure_id = hf.id
  trgunit.hist_figure_id2 = hf.id

  if (he and he~=-1)and(he_group and he_group~=-1) then
    hf.entity_links:insert("#",{new=df.histfig_entity_link_memberst,entity_id=trgunit.civ_id,link_strength=100})
    --add entity event
    local hf_event_id=df.global.hist_event_next_id
    df.global.hist_event_next_id=df.global.hist_event_next_id+1
    df.global.world.history.events:insert("#",{new=df.history_event_add_hf_entity_linkst,year=trgunit.birth_year,
    seconds=trgunit.birth_time,id=hf_event_id,civ=hf.civ_id,histfig=hf.id,link_type=0})
  end
  return hf
end

local function createNemesis(trgunit,civ_id,group_id)
  local id=df.global.nemesis_next_id
  local nem=df.nemesis_record:new()

  nem.id=id
  nem.unit_id=trgunit.id
  nem.unit=trgunit
  nem.flags:resize(4)
  --not sure about these flags...
  -- [[
  nem.flags[4]=true
  nem.flags[5]=true
  nem.flags[6]=true
  nem.flags[7]=true
  nem.flags[8]=true
  nem.flags[9]=true
  --]]
  --[[for k=4,8 do
      nem.flags[k]=true
  end]]
  nem.unk10=-1
  nem.unk11=-1
  nem.unk12=-1
  df.global.world.nemesis.all:insert("#",nem)
  df.global.nemesis_next_id=id+1
  trgunit.general_refs:insert("#",{new=df.general_ref_is_nemesisst,nemesis_id=id})
  trgunit.flags1.important_historical_figure=true

  nem.save_file_id=-1
  
  if (civ_id and civ_id~=-1) then
    local he=df.historical_entity.find(civ_id)
    he.nemesis_ids:insert("#",id)
    he.nemesis:insert("#",nem)
  end
  
  local he_group
  if group_id and group_id~=-1 then
      he_group=df.historical_entity.find(group_id)
  end
  if he_group then
      he_group.nemesis_ids:insert("#",id)
      he_group.nemesis:insert("#",nem)
  end
  allocateIds(nem,he)
  nem.figure=createFigure(trgunit,he,he_group)
end


local function getRandomCasteId(race_id)
	local cr = df.creature_raw.find(race_id)
	local caste_id, casteMax

	casteMax = #cr.caste - 1

	if casteMax > 0 then
		return math.random(0, casteMax)
	end
	return 0
end

local function doimpregnation(cause,birther)
	if (birther.pregnancy_timer > 0) then
		print('Already pregnant!')
		return false
	else
		print('Birther:',birther.hist_figure_id)
        if (birther.hist_figure_id==-1)and(dfhack.units.getNemesis(birther)==nil) then
			createNemesis(birther, birther.civ_id, -1)
        end
        print('Birther check:',birther.hist_figure_id)
		
	  	print('Cause:',cause.hist_figure_id)
	    if (cause.hist_figure_id==-1)and(dfhack.units.getNemesis(cause)==nil) then
			createNemesis(cause, cause.civ_id, -1)
	    end
	    print('Cause check:',cause.hist_figure_id)
		
	    local genes = cause.appearance.genes:new()
		birther.pregnancy_spouse=cause.hist_figure_id	
		birther.pregnancy_genes = genes;
		birther.pregnancy_timer = 30;
		birther.pregnancy_caste = getRandomCasteId(birther.race);
		return true
	end
	return false
end		  

function impregnate ()

	local target = dfhack.gui.getSelectedUnit()
	local check = -1
  
	if (target == nil) then
		print('No Selection!')
		return
	end
  
	local xp,yp,zp=dfhack.units.getPosition(target)
  
	for _,partner in ipairs(dfhack.units.getUnitsInBox(xp-1,yp-1,zp,xp+1,yp+1,zp)) do
		if (partner~=target) then	--1 = male
			if (target.sex==1)and(partner.sex~=1) then
				if doimpregnation(target,partner) then
					check=1
					break
				end
			else
				if (target.sex==0)and(partner.sex~=0) then
					if doimpregnation(partner,target) then
						check=1
						break
					end
				end
			end
		end
	end
  
  if (check==1) then
    print('Success')
  else
	print('Fail')
  end
  
end

dfhack.with_suspend(impregnate)