-- Vylon Abnormity
-- ID: 100000020
local s,id=GetID()
local VYLON_ARCHETYPE = 0x30 -- Vylon Archetype Code

function s.initial_effect(c)
	-- E1: Special Summon Condition (from hand, HOPT)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G) -- Use G since it's an easy condition from hand
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon1)
	e1:SetOperation(s.spop1)
	c:AddEffect(e1)

	-- E2: Equip when sent to GY (HOPT for trigger)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id) -- HOPT for the trigger
	e2:SetCondition(s.equipcon2)
	e2:SetCost(s.equipcost2)
	e2:SetTarget(s.equiptg2)
	e2:SetOperation(s.equipop2)
	c:AddEffect(e2)
end
s.listed_series={0x30}

-- E1: Special Summon Condition & HOPT enforcement
function s.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- HOPT check for this specific SS method
	if Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0 then
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
		if #g==0 then return true end -- No monsters
		-- Check if all monsters are LIGHT
		if g:FilterCount(Card.IsAttribute, nil, ATTRIBUTE_LIGHT) == #g then return true end
	end
	return false
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp,c)
	-- Registers a flag to limit Special Summon to once per turn this way
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_LIMIT_ACTIVITY)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetValue(ACTIVITY_SPSUMMON)
	e1:SetLabel(id)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- E2: Equip when sent to GY
function s.equipcon2(e, tp, eg, ep, ev, re, r, rp)
	-- Was sent from Monster Zone to GY
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.equipcost2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLP(tp)>500 end
	Duel.PayLPCost(tp, 500)
end
function s.equiptg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then
		-- Check for target face-up monster to equip to, and S/T Zone space
		return Duel.GetLocationCount(tp, LOCATION_SZONE)>0
			and Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
end
function s.equipop2(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Equip(tp, c, tc, false) then
		-- Make it an Equip Spell and set equip limit (must remain equipped to this card)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_SPELL+TYPE_EQUIP)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)

		-- Register the Equipped Effect (E3)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id, 1))
		e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_IGNITION) -- Ignition effect of the equipped Spell
		e3:SetRange(LOCATION_SZONE)
		e3:SetCountLimit(1, {id, 2}) -- HOPT for the equipped effect
		e3:SetCondition(s.eff3con)
		e3:SetTarget(s.eff3tg)
		e3:SetOperation(s.eff3op)
		c:RegisterEffect(e3)
	end
end
function s.eqlimit(e,c)
	-- Only allow equipping to the originally targeted monster (or if it's the owner's monster)
	return c:IsFaceup() and c:IsControler(e:GetOwnerControler())
end

-- E3: Equipped Effect (HOPT)
function s.eff3con(e, tp, eg, ep, ev, re, r, rp)
	-- Check if the card is an equipped spell in the S/T zone
	return e:GetHandler():IsLocation(LOCATION_SZONE) and e:GetHandler():IsHasType(TYPE_EQUIP)
end
function s.eff3filter(c, equip_c)
	return c:IsSetCard(VYLON_ARCHETYPE) and c:IsMonster() and c:IsAbleToHand()
		-- Check if SS is possible (if Vylon is equipped)
		and (not equip_c:IsSetCard(VYLON_ARCHETYPE) or c:IsCanBeSpecialSummoned(equip_c:GetEffectHandle(), 0, equip_c:GetControler(), false, false))
end
function s.eff3tg(e, tp, eg, ep, ev, re, r, rp, chk)
	local eqc = e:GetHandler():GetEquipTarget() -- The monster this card is equipped to
	if chk==0 then return eqc and Duel.IsExistingTarget(s.eff3filter, tp, LOCATION_GRAVE, 0, 1, nil, eqc) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	Duel.SelectTarget(tp, s.eff3filter, tp, LOCATION_GRAVE, 0, 1, 1, nil, eqc)
end
function s.eff3op(e, tp, eg, ep, ev, re, r, rp)
	local eqc = e:GetHandler():GetEquipTarget()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if eqc and eqc:IsSetCard(VYLON_ARCHETYPE) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- Special Summon it instead
			Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
		else
			-- Add to hand
			Duel.SendtoHand(tc, nil, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, tc)
		end
	end
end