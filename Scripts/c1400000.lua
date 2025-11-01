-- Vylon Omicron
-- ID: 100000021
local s,id=GetID()
local VYLON_ARCHETYPE = 0x30 -- Vylon Archetype Code

function s.initial_effect(c)
	-- Synchro Summon Procedure
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)

	-- E1 (HOPT): Destroy all Special Summoned monsters opponent controls on Synchro Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id) -- HOPT for this effect
	e1:SetCondition(s.dscon1)
	e1:SetTarget(s.dstg1)
	e1:SetOperation(s.dsop1)
	c:AddEffect(e1)

	-- E2 (HOPT): Negate S/T activation (Quick Effect)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id, 1}) -- HOPT for the second effect
	e2:SetCondition(s.negcon2)
	e2:SetCost(s.negcost2)
	e2:SetTarget(s.negtg2)
	e2:SetOperation(s.negop2)
	c:AddEffect(e2)
	
	-- E3: Continuous LP Cost Reduction for Vylon cards (Assuming Vylon archetype intended)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_ACTIVATION_COST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE, 0)
	e3:SetValue(s.costval3)
	c:AddEffect(e3)
end
s.listed_series={VYLON_ARCHETYPE}

-- E1: Destroy SS monsters
function s.dscon1(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.dsfilter1(c)
	return c:IsStatus(STATUS_SPSUMMONED) and c:IsDestructable()
end
function s.dstg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dsfilter1, tp, 0, LOCATION_MZONE, 1, nil) end
	local g=Duel.GetMatchingGroup(s.dsfilter1, tp, 0, LOCATION_MZONE, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end
function s.dsop1(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.dsfilter1, tp, 0, LOCATION_MZONE, nil)
	Duel.Destroy(g, REASON_EFFECT)
end

-- E2: Negate S/T
function s.negcon2(e, tp, eg, ep, ev, re, r, rp)
	-- Opponent's Spell/Trap activation and chain is disablable
	return ep == 1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
function s.negcost2_filter(c)
	return c:IsLocation(LOCATION_SZONE) and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
function s.negcost2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsExists(s.negcost2_filter, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=e:GetHandler():FilterSelect(tp, s.negcost2_filter, 1, 1, nil)
	Duel.SendtoGrave(g, REASON_COST)
end
function s.negfilter2(c, e, tp)
	return c:IsSetCard(VYLON_ARCHETYPE) and c:IsMonster() and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.negtg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then
		Duel.SetOperationInfo(ev, CATEGORY_NEGATE, eg, 1, 0, 0)
		Duel.SetOperationInfo(ev, CATEGORY_DESTROY, eg, 1, 0, 0)
		-- Check for Vylon Tuner in Deck
		return Duel.IsExistingMatchingCard(s.negfilter2, tp, LOCATION_DECK, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end
function s.negop2(e, tp, eg, ep, ev, re, r, rp)
	if Duel.NegateActivation(ev) and Duel.Destroy(eg, REASON_EFFECT)>0 then
		Duel.BreakEffect()
		if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp, s.negfilter2, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
			local tc=g:GetFirst()
			if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)>0 then
				-- Send to GY during the End Phase
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetLabelObject(tc)
				e1:SetCondition(s.retcon2)
				e1:SetOperation(s.retop2)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1, tp)
			end
		end
	end
end
function s.retcon2(e, tp, eg, ep, ev, re, r, rp)
	local tc=e:GetLabelObject()
	-- Check if the monster is still face-up on the field
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE)
end
function s.retop2(e, tp, eg, ep, ev, re, r, rp)
	local tc=e:GetLabelObject()
	Duel.SendtoGrave(tc, REASON_EFFECT)
end

-- E3: Continuous LP Cost Reduction
function s.costval3(e, re, tp)
	-- Only apply if the effect costs LP and the card is a Vylon card
	if re:IsSetCard(VYLON_ARCHETYPE) and re:GetCost() & COST_LP ~= 0 then
		return 0 -- Cost becomes 0
	end
	return -1 -- Do not modify cost
end