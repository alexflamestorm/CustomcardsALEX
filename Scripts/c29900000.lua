-- Psi-Caller/Assault Mode
-- ID: 29900000
local s,id=GetID()
local psi_caller_id = 29800000 -- ID of the base "Psi-Caller" monster
s.psi_caller_id = psi_caller_id

function s.initial_effect(c)
	-- Summon Condition: Must be Special Summoned with "Assault Mode Activate"
	c:SetSPSummonOnce(2) -- Standard for non-Nomi/Semi-Nomi monsters with custom SS conditions
	
	-- Mark as Tuner
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_TYPE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(TYPE_TUNER)
	c:AddEffect(e0)

	-- Effect 1 (HOPT): Send Synchro to SS /Assault Mode, maybe send ED Synchro
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id) -- HOPT for Effect 1
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:AddEffect(e1)

	-- Effect 2 (HOPT): Special Summon Psi-Caller from GY if destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1}) -- HOPT for Effect 2
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:AddEffect(e2)
end
s.listed_series={0x104f} -- Assault Mode archetype code

-- Map of Synchro ID to its /Assault Mode ID (Add more pairs as needed)
local synchro_to_am={
		[44508094]=61257789, -- Stardust Dragon -> Stardust Dragon/Assault Mode
	[70902743]=77336644, -- Red Dragon Archfiend -> Red Dragon Archfiend/Assault Mode
	[31924889]=14553285, -- Arcanite Magician -> Arcanite Magician/Assault Mode
	[06021033]=01764972, -- Doomkaiser Dragon -> Doomkaiser Dragon/Assault Mode
	[95526884]=37169670, -- Hyper Psychic Blaster -> Hyper Psychic Blaster/Assault Mode
	[38898779]=23693634, -- Colossal Fighter -> Colossal Fighter/Assault Mode
	[80321197]=101303008, -- Crimson Blader -> Crimson Blader/Assault Mode
	[97836203]=47027714, -- T.G. Halberd Cannon -> T.G. Halberd Cannon/Assault Mode
	[60800381]=101303007, -- Junk Warrior -> Junk Warrior/Assault Mode
	[51447164]=10500000, -- T.G. Blade Blaster -> T.G. Blade Blaster/Assault Mode
	[29800000]=29900000 -- Psi-Caller -> Psi-Caller/Assault Mode (Self reference, assuming ID)

}
function s.GetAMID(synchro_code)
	return synchro_to_am[synchro_code]
end

-- Effect 1: Cost, Target, Operation
function s.cost1_filter(c)
	return c:IsSynchroMonster() and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost1_filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1_filter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g:GetFirst()) -- Store the released card for the operation
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	local released_c = e:GetLabelObject()
	local am_id = s.GetAMID(released_c:GetPreviousCode())
	if chk == 0 then
		-- Check if the corresponding /Assault Mode monster exists in the Deck
		return am_id and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, 1, nil, am_id)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
	-- Optional part: check for ED Synchro send
	if Duel.GetMatchingGroupCount(nil, 1-tp, LOCATION_MZONE, 0, nil) > Duel.GetMatchingGroupCount(nil, tp, LOCATION_MZONE, 0, nil)
		and Duel.IsExistingMatchingCard(Card.IsSynchroMonster, tp, LOCATION_EXTRA, 0, 1, nil) then
		Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_EXTRA)
	end
end
function s.op1(e, tp, eg, ep, ev, re, r, rp)
	local released_c = e:GetLabelObject()
	local am_id = s.GetAMID(released_c:GetPreviousCode())
	if not am_id then return end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	-- Summon the corresponding /Assault Mode monster from the Deck
	local g = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_DECK, 0, 1, 1, nil, am_id)
	local tc = g:GetFirst()
	-- Note: Using SUMMON_TYPE_SPECIAL is sufficient here. The 'treated as' text is flavor/game rule.
	if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then 
		-- Secondary effect: send 1 Synchro from ED to GY
		if Duel.GetMatchingGroupCount(nil, 1-tp, LOCATION_MZONE, 0, nil) > Duel.GetMatchingGroupCount(nil, tp, LOCATION_MZONE, 0, nil)
			and Duel.IsExistingMatchingCard(Card.IsSynchroMonster, tp, LOCATION_EXTRA, 0, 1, nil)
			and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
			local edg = Duel.SelectMatchingCard(tp, Card.IsSynchroMonster, tp, LOCATION_EXTRA, 0, 1, 1, nil)
			Duel.SendtoGrave(edg, REASON_EFFECT)
		end
	end
end

-- Effect 2: Special Summon Psi-Caller
function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
	-- Was destroyed while on the field
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.sptg2_filter(c, e, tp)
	return c:IsCode(s.psi_caller_id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.sptg2_filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.sptg2_filter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop2(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end