-- Fabled Andromalith
-- ID: 100000024
local s,id=GetID()
local FABLED_ARCHETYPE = 0x35 -- Fabled Archetype Code

function s.initial_effect(c)
	-- Synchro Summon Procedure: 1 "Fabled" Tuner + 1+ non-Tuners
	c:EnableReviveLimit()
	Synchro.AddProcedure(c, Card.IsSetCard, {0x35}, 1, 1, Synchro.NonTuner(nil), 1, 99)

	-- E1 (HOPT): Hand equalization and negation on Synchro Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISCARD)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id) -- HOPT for effect 1
	e1:SetCondition(s.hcon1)
	e1:SetTarget(s.htg1)
	e1:SetOperation(s.hop1)
	c:AddEffect(e1)

	-- E2a (HOPT Quick Effect): Protection/Draw - Attack declared
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_DRAW)
	e2a:SetType(EFFECT_TYPE_QUICK_O)
	e2a:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,{id,1}) -- HOPT for effect 2
	e2a:SetCondition(s.atkcon2)
	e2a:SetCost(s.discardcost2)
	e2a:SetTarget(s.drawtg2)
	e2a:SetOperation(s.drawop2)
	c:AddEffect(e2a)
	
	-- E2b (HOPT Quick Effect): Protection/Draw - Opponent's activation
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_CHAINING)
	e2b:SetCondition(s.actcon2)
	c:AddEffect(e2b)
end
s.listed_series={0x35}

-- E1: Hand Equalization and Negation
function s.hcon1(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.htg1(e, tp, eg, ep, ev, re, r, rp, chk)
	local p1_hand=Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
	local p2_hand=Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND)
	
	if chk==0 then return p1_hand ~= p2_hand end

	local dis_player = -1
	local target_count = 0
	if p1_hand > p2_hand then
		dis_player = tp
		target_count = p1_hand - p2_hand
	else
		dis_player = 1-tp
		target_count = p2_hand - p1_hand
	end

	if target_count > 0 then
		-- Set discard player and count for operation
		Duel.SetTargetPlayer(dis_player)
		Duel.SetTargetParam(target_count)
		Duel.SetOperationInfo(0, CATEGORY_DISCARD, nil, target_count, dis_player, LOCATION_HAND)
	end
end

function s.hop1(e, tp, eg, ep, ev, re, r, rp)
	local dis_player=Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
	local target_count=Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)

	if target_count <= 0 then return end

	-- Perform Discard, saving the discarded cards
	local discard_g = Duel.DiscardHand(dis_player, nil, target_count, target_count, REASON_EFFECT, e:GetHandler())
	
	if #discard_g > 0 then
		local c=e:GetHandler()
		local codes = {}
		
		-- Collect codes of discarded non-Fabled cards
		for _, dc in ipairs(discard_g:GetCards()) do
			if not dc:IsSetCard(FABLED_ARCHETYPE) then
				codes[dc:GetOriginalCode()] = true
			end
		end

		if next(codes) then
			-- Continuous Negation Effect
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED, LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
			e1:SetTarget(function(e, c) return s.negate_filter(e, c, codes) end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			c:RegisterEffect(e2)
			
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CANNOT_TRIGGER)
			c:RegisterEffect(e3)
		end
	end
end
function s.negate_filter(e, c, codes)
	-- Targets cards with the stored codes, that are NOT "Fabled"
	return codes[c:GetOriginalCode()] and not c:IsSetCard(FABLED_ARCHETYPE)
end

-- E2: Protection and Draw
function s.atkcon2(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	-- Attack declared involving this card
	return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c
end

function s.actcon2(e, tp, eg, ep, ev, re, r, rp)
	-- Opponent activates a card or effect
	return rp == 1-tp
end

function s.discardcost2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, e:GetHandler()) end
	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST+REASON_DISCARD, e:GetHandler())
end

function s.drawtg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	-- Draw is registered in operation during the End Phase
end
function s.drawop2(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	
	-- 1. Protection (Indestructible by battle/effects until the end of this turn)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	
	local e2=e1:Clone()
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.effimmval)
	c:RegisterEffect(e2)

	-- 2. End Phase Draw
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetTarget(s.enddrawtg)
	e3:SetOperation(s.enddrawop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3, tp)
end

function s.effimmval(e, re, rp)
	-- Immunity against all card effects
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

function s.enddrawtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function s.enddrawop(e, tp, eg, ep, ev, re, r, rp)
	local p=Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
	local d=Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
	Duel.Draw(p, d, REASON_EFFECT)
end