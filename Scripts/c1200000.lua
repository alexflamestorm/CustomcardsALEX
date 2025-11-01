-- Vylon Synchron
-- ID: 100000019
local s,id=GetID()
local VYLON_ARCHETYPE = 0x30 -- Vylon Archetype Code

function s.initial_effect(c)
	-- E0: Continuous Tuner Status
	c:AddSetCard(TYPE_TUNER)

	-- E1: Special Summon Condition (from hand, no monsters)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetValue(s.spval1)
	c:AddEffect(e1)

	-- E2: Level Modification for Vylon Synchro Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_ATTRIBUTES)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.synmat)
	c:AddEffect(e2)

	-- E3 (HOPT): Equip Vylon monster from Deck when sent to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id) -- HOPT for this effect
	e3:SetCondition(s.equipcon)
	e3:SetTarget(s.equiptg)
	e3:SetOperation(s.equipop)
	c:AddEffect(e3)

	-- E4 (HOPT): Banish self to SS monster from S/T Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id, 1}) -- HOPT for the second effect
	e4:SetCost(s.spcost4)
	e4:SetTarget(s.sptg4)
	e4:SetOperation(s.spop4)
	c:AddEffect(e4)
end
s.listed_series={VYLON_ARCHETYPE}

-- E1: Special Summon Condition
function s.spval1(e, c)
	-- Check if player controls no monsters and it is being SS from hand
	return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_MZONE, 0) == 0
end

-- E2: Level Modification
function s.synmat(e, c)
	local rc=c:GetReasonCard()
	-- Check if the Synchro Monster is a "Vylon"
	if rc and rc:IsSetCard(VYLON_ARCHETYPE) then
		-- Return current level and all selectable levels (2, 3, 4, 5)
		return {c:GetLevel(), 2, 3, 4, 5}
	end
	return {c:GetLevel()}
end

-- E3: Equip from Deck
function s.equipcon(e, tp, eg, ep, ev, re, r, rp)
	-- Was sent from Monster Zone to GY
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.equipfilter(c)
	return c:IsSetCard(VYLON_ARCHETYPE) and c:IsMonster() -- Vylon monster
end
function s.equiptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then
		-- Check for target Synchro Monster on field
		return Duel.IsExistingTarget(Card.IsSynchroMonster, tp, LOCATION_MZONE, 0, 1, nil)
			-- Check for Vylon Monster in Deck to equip
			and Duel.IsExistingMatchingCard(s.equipfilter, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	Duel.SelectTarget(tp, Card.IsSynchroMonster, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_DECK)
end
function s.equipop(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,s.equipfilter,tp,LOCATION_DECK,0,1,1,nil)
		local eqc=g:GetFirst()
		if eqc and Duel.Equip(tp,eqc,tc,false) then
			-- Make it an Equip Spell and set equip limit
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			eqc:RegisterEffect(e1)

			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_SPELL+TYPE_EQUIP)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			eqc:RegisterEffect(e2)
		end
	end
end

-- E4: SS from S/T Zone
function s.spcost4(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end
function s.spfilter4(c, e, tp)
	-- Target must be a Monster in the S/T Zone (equipped or Pendulum)
	return c:IsLocation(LOCATION_SZONE) and c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg4(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.spfilter4, tp, LOCATION_SZONE, 0, 1, nil, e, tp)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp, s.spfilter4, tp, LOCATION_SZONE, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_SZONE)
end
function s.spop4(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
end