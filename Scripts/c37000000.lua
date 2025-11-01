-- Twin-Headed Voltage Thunder Dragon
-- ID: 37000000
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Procedure
	c:EnableReviveLimit()
	-- Material 1: "Thunder Dragon" (Original Normal Monster ID: 31786629)
	-- Material 2: 1 "Thunder Dragon" monster (Archetype ID: 0x11e)
	Fusion.AddProcMix(c,true,true,31786629,aux.FilterBoolFunction(Card.IsSetCard,0x11c))

	-- Effect 1: Battle Protection (Opponent cannot activate effects)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetCondition(s.actcon)
	c:AddEffect(e1)

	-- Effect 2: Set S/T on Fusion Summon (Once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TO_DECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:AddEffect(e2)

	-- Effect 3: Special Summon from GY (Once per turn)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION) -- Ignition effect from GY
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1}) -- Use flag 1 for the second OPT clause
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:AddEffect(e3)
end
s.listed_series={0x11c} -- Thunder Dragon archetype code

-- Effect 1: Battle Protection Condition & Value
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a or not d then return false end
	if a:IsControler(1-tp) and d:IsControler(tp) and d:IsRace(RACE_THUNDER) then return true end
	if d:IsControler(1-tp) and a:IsControler(tp) and a:IsRace(RACE_THUNDER) then return true end
	return false
end
function s.aclimit(e,re,tp)
	local phase=Duel.GetCurrentPhase()
	-- Restrict activation only during Damage Step
	return phase==PHASE_DAMAGE or phase==PHASE_DAMAGE_CAL
end


-- Effect 2: Set S/T Condition, Target, Operation
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.setfilter(c)
	return c:IsSetCard(0x11c) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SSet(tp,tc)
		if tc:IsTrap() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

-- Effect 3: GY Special Summon Cost, Target, Operation
function s.costfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemoveAsCost(POS_FACEDOWN) -- Usually banish as cost is face-down unless specified
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST) -- Banish face-down as cost
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Return to Extra Deck when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_EXTRA)
		c:RegisterEffect(e1,true) -- Register immediately and make it temporary
	end
end