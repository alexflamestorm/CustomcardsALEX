-- Arcana Disguise Joker
-- ID: 100000022
local s,id=GetID()
local QK=25652259
local KK=64788463
local JK=90876561
local SUPPORT_CARD=29062925,92067220,93880808,56673112,29284413,28340377,81945678,58415502,11020863

function s.initial_effect(c)
	c:EnableReviveLimit()
	
	-- Fusion Procedure: 2 Warrior monsters with different names
	Fusion.AddProcMixN(c, true, true, s.matfilter, 2, s.fusfinal)

	-- E1: Continuous ATK/Negation in Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.bacon)
	c:AddEffect(e1)

	-- E2 (HOPT): Search on Fusion Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id) -- HOPT for effect 1
	e2:SetCondition(s.thcon2)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:AddEffect(e2)

	-- E3 (HOPT): Shuffle, Draw, Search Lvl 10 on send to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1}) -- HOPT for effect 2
	e3:SetCondition(s.shcon3)
	e3:SetTarget(s.shtg3)
	e3:SetOperation(s.shop3)
	c:AddEffect(e3)
end
s.listed_names={QK, KK, JK, SUPPORT_CARD}

-- Fusion Procedure
function s.matfilter(c)
	return c:IsRace(RACE_WARRIOR)
end
function s.fusfinal(g)
	-- Check if all 2 monsters have different names
	return g:GetClassCount(Card.GetCode)==#g
end

-- E1: Continuous ATK/Negation in Battle Phase
function s.bacon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsControler(tp) and Duel.GetCurrentPhase()==PHASE_BATTLE then
		-- Gain 1300 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()+1300)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		
		-- Opponent cannot activate card effects during the Battle Phase
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0, 1) -- Opponent only
		e2:SetValue(s.aclimit)
		e2:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN)
		Duel.RegisterEffect(e2, tp)
	end
end
function s.aclimit(e, re, tp)
	-- Only prevent card effect activation (not mandatory triggers or cost payments)
	return re:IsActiveType(TYPE_ACTIVATE)
end

-- E2: Search on Fusion Summon
function s.thcon2(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.thfilter2(c)
	-- Filter for the specific support card
	return c:IsCode(SUPPORT_CARD) and c:IsAbleToHand()
end
function s.thtg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, s.thfilter2, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end

-- E3: Shuffle, Draw, Search Lvl 10 on send to GY
function s.shcon3(e, tp, eg, ep, ev, re, r, rp)
	-- Was sent from Monster Zone to GY
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.shufflefilter(c)
	-- Queen's, King's, or Jack's Knight
	return c:IsCode(QK) or c:IsCode(KK) or c:IsCode(JK)
end
function s.lvl10filter(c)
	return c:IsLevel(10) and c:IsAbleToHand()
end
function s.shtg3(e, tp, eg, ep, ev, re, r, rp, chk)
	-- Check for shuffle-able targets in Hand, Field, and GY
	local g=Duel.GetMatchingGroup(s.shufflefilter, tp, LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE, 0, nil)
	if chk==0 then return #g>0 end

	Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
	-- Draw depends on number shuffled, so CATEGORY_DRAW is implicit
end
function s.shop3(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.shufflefilter, tp, LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE, 0, nil)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	-- Select any number of the applicable Knights
	local sg=g:Select(tp, 0, #g, nil)
	local count = #sg
	
	if count>0 then
		Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)

		if Duel.Draw(tp, count, REASON_EFFECT) then
			Duel.BreakEffect()
			-- Optional search for Level 10 monster
			if Duel.IsExistingMatchingCard(s.lvl10filter, tp, LOCATION_DECK, 0, 1, nil)
				and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
				local thg=Duel.SelectMatchingCard(tp, s.lvl10filter, tp, LOCATION_DECK, 0, 1, 1, nil)
				if #thg>0 then
					Duel.SendtoHand(thg, nil, REASON_EFFECT)
					Duel.ConfirmCards(1-tp, thg)
				end
			end
		end
	end
end