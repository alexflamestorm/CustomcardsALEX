-- Borreload Full Armor Dragon
-- ID: 100000026
local s,id=GetID()
local BORREL_ARCHETYPE = 0x10f -- Borrel Archetype Code

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Link Summon Procedure: 2+ Effect Monsters, including a Link Monster
	Link.AddProcedure(c, s.matfilter, 2, 99)
	-- Assuming Link 4, arrows (Left, Bottom-Left, Bottom, Bottom-Right)
	c:SetLinkField(LINK_L+LINK_BL+LINK_B+LINK_BR)

	-- E1 (HOPT): Banish Column + Adjacent on Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id) -- HOPT for effect 1
	e1:SetCondition(s.linkcon1)
	e1:SetTarget(s.lstg1)
	e1:SetOperation(s.lsop1)
	c:AddEffect(e1)

	-- E2 (HOPT Quick Effect): Negate, Recycle, and Control Steal
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_SET+CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1}) -- HOPT for effect 2
	e2:SetCondition(s.negcon2)
	e2:SetTarget(s.negtg2)
	e2:SetOperation(s.negop2)
	c:AddEffect(e2)
end
s.listed_series={0x10f}

-- Link Procedure
function s.matfilter(c, sc)
	if sc and sc:IsLinkMonster() then return true end
	return c:IsType(TYPE_EFFECT) and c:IsLinkMonster()
end
function s.linkcon1(e, tp, eg, ep, ev, re, r, rp)
	-- Check if Link Summoned using a "Borrel" Link Monster
	if not e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) then return false end
	local g = e:GetHandler():GetMaterial()
	return g:IsExists(function(c) return c:IsSetCard(BORREL_ARCHETYPE) and c:IsLinkMonster() end, 1, nil)
end

-- E1: Banish Column + Adjacent
function s.lstg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, 0)
end
function s.lsop1(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local loc=c:GetSequence() -- Column of the card (0-4)
	
	-- Filter opponent's cards on field that can be banished
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, nil)
	local banished_g = Group.CreateGroup()
	
	-- 1. Banish cards in the same column
	local col_g = g:Filter(function(tc)
		-- Monster Zones (0-4) and S/T Zones (0-4) share column sequence
		local t_loc = tc:GetSequence()
		return t_loc == loc
	end, nil)
	
	if #col_g > 0 then
		Duel.Remove(col_g, POS_FACEUP, REASON_EFFECT)
		banished_g:Merge(col_g)
		
		-- 2. Banish cards in adjacent zones (columns)
		local adj_locs = {}
		if loc > 0 then table.insert(adj_locs, loc - 1) end
		if loc < 4 then table.insert(adj_locs, loc + 1) end
		
		if #adj_locs > 0 then
			local adj_g = g:Filter(function(tc)
				local t_loc = tc:GetSequence()
				-- Check if card is in an adjacent column and was not already banished
				for _, adj_loc in ipairs(adj_locs) do
					if t_loc == adj_loc and not banished_g:IsContains(tc) then return true end
				end
				return false
			end, nil)
			
			if #adj_g > 0 then
				Duel.BreakEffect()
				Duel.Remove(adj_g, POS_FACEUP, REASON_EFFECT)
			end
		end
	end
end

-- E2: Negate and Control Steal
function s.negcon2(e, tp, eg, ep, ev, re, r, rp)
	-- Must be opponent's card/effect and chain is disablable
	return Duel.IsChainDisablable(ev) and ep ~= tp
end

function s.negtg2(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	-- Target 1 monster you control (M1)
	local tg=Duel.GetMatchingGroup(nil, tp, LOCATION_MZONE, 0, c)
	if chk==0 then return #tg > 0 end
	
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local target_m = tg:Select(tp, 1, 1, nil)
	e:SetLabelObject(target_m:GetFirst()) -- Store the targeted monster (M1)
	
	Duel.SetTargetCard(eg) -- Target the chain block being negated (Negated Card)
	Duel.SetOperationInfo(ev, CATEGORY_NEGATE, eg, 1, 0, 0)
	Duel.SetOperationInfo(ev, CATEGORY_DESTROY, eg, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_CONTROL, target_m, 1, 0, 0) -- Control change for M1
end

function s.negop2(e, tp, eg, ep, ev, re, r, rp)
	local targeted_m = e:GetLabelObject() -- M1: The monster you targeted on your field
	local negated_card = eg:GetFirst() -- Negated Card
	
	local success = false
	
	if Duel.NegateActivation(ev) and negated_card:IsRelateToEffect(re) then
		-- Destruction of the negated card
		if Duel.Destroy(negated_card, REASON_EFFECT) > 0 then
			success = true
		end
	end
	
	-- Step 3: Recycle (Negated Card) - Only if successful destruction
	if success then
		-- Retrieve the destroyed card (now in GY/Extra)
		local original_card = Duel.GetDestructorCard(negated_card) 
		
		-- Check if the card can be recycled from the GY (standard location after destruction)
		if original_card and original_card:IsLocation(LOCATION_GRAVE) then
			Duel.BreakEffect()
			if original_card:IsMonster() then
				-- Special Summon to your field
				if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
					Duel.SpecialSummon(original_card, 0, tp, tp, false, false, POS_FACEUP)
				end
			elseif original_card:IsSpellTrap() then
				-- Set to your field
				if Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 then
					Duel.SSet(original_card)
				end
			end
		end
	end
	
	Duel.BreakEffect()
	
	-- Step 4: Control Change (Mandatory for the monster you targeted)
	-- Check if M1 is still on the field and under your control
	if targeted_m and targeted_m:IsControler(tp) and targeted_m:IsLocation(LOCATION_MZONE) then
		Duel.ChangeControl(targeted_m, 1-tp, 0)
	end
end