-- Scorpion that Eliminates the Millennium Enemies
-- ID: 100000027
local s,id=GetID()

-- Card Code References (Official IDs for Forbidden One pieces)
local MILLENNIUM_ANKH = 37613663 -- Placeholder ID
local MILLENNIUM_ARCHETYPE = 0x2ae -- Placeholder Archetype Code for Millennium
local EXODIA_ARCHETYPE = 0x40

function s.initial_effect(c)
	-- E0: Continuous ATK Reduction
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SET_ATTACK_FINAL)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(0, LOCATION_MZONE) -- Opponent's monsters
	e0:SetTarget(s.atkredtg)
	e0:SetValue(-500)
	c:AddEffect(e0)
	
	-- E1 (HOPT): Hand -> S/T Zone (Continuous Spell)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id) -- HOPT for this specific effect
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:AddEffect(e1)

	-- E2 (HOPT): S/T -> SS/Draw/Shuffle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.sscon2)
	e2:SetCost(s.sscost2)
	e2:SetTarget(s.sstg2)
	e2:SetOperation(s.ssop2)
	c:AddEffect(e2)
end
s.listed_names={MILLENNIUM_ANKH, EXODIA_ARCHETYPE}
s.listed_series={0x2ae}

-- E0: ATK Reduction Target
function s.atkredtg(e, c)
	return c:IsFaceup()
end

-- E1: Hand -> S/T Zone
function s.sptg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0, CATEGORY_LEAVE_HAND, e:GetHandler(), 1, 0, 0)
end
function s.spop1(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- Move to S/T Zone
		if c:MoveToField(LOCATION_SZONE, tp, POS_FACEUP, false) then
			-- Register as Continuous Spell
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			
			-- Set HOPT flag 1, which will be checked by E2
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_LIMIT_TURN_SPSUMMON)
			e2:SetTarget(Card.IsCode)
			e2:SetTargetParam(id)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2, tp)
		end
	end
end

-- E2: S/T -> SS/Draw/Shuffle
function s.sscon2(e, tp, eg, ep, ev, re, r, rp)
	-- Must be treated as a Continuous Spell
	return e:GetHandler():IsStatus(STATUS_CONTINUOUS_SPELL) and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0
end

function s.sscost2(e, tp, eg, ep, ev, re, r, rp, chk)
	local ankh_filter = Card.IsCode
	local ankh_exists = Duel.IsExistingMatchingCard(ankh_filter, tp, LOCATION_HAND, 0, 1, nil, MILLENNIUM_ANKH)
	local lp_ok = Duel.GetLP(tp) >= 2000
	
	if chk==0 then return lp_ok or ankh_exists end

	local b1 = lp_ok
	local b2 = ankh_exists
	
	if b1 and b2 then
		-- Choose whether to pay LP (Yes) or Reveal Ankh (No)
		local b3=Duel.SelectYesNo(tp, aux.Stringid(id, 2))
		if b3 then b2=false else b1=false end
	end
	
	if b1 then
		Duel.PayLPCost(tp, 2000)
	else -- Reveal Ankh
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REVEAL)
		local g=Duel.SelectMatchingCard(tp, ankh_filter, tp, LOCATION_HAND, 0, 1, 1, nil, MILLENNIUM_ANKH)
		Duel.ConfirmCards(1-tp, g)
	end
end

function s.ssfilter2(c) -- Millennium or Forbidden One monster
	return c:IsMonster() and (c:IsSetCard(MILLENNIUM_ARCHETYPE) or c:IsSetCard(EXODIA_ARCHETYPE))
end

function s.sstg2(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	
	local g=Duel.GetMatchingGroup(s.ssfilter2, tp, LOCATION_HAND+LOCATION_GRAVE, 0, nil)
	if #g>0 then
		Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.ssop2(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	-- 1. Special Summon
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) then
		-- Register HOPT SS
		Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)

		Duel.BreakEffect()
		-- 2. Shuffle/Draw
		local g=Duel.GetMatchingGroup(s.ssfilter2, tp, LOCATION_HAND+LOCATION_GRAVE, 0, nil)
		if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then -- Ask to shuffle
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
			local sg=g:Select(tp, 0, #g, nil)
			local count=#sg
			if count>0 then
				Duel.SendtoDeck(sg, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
				Duel.ShuffleDeck(tp)
				if count>0 then
					Duel.BreakEffect()
					Duel.Draw(tp, count, REASON_EFFECT)
				end
			end
		end
	end
end