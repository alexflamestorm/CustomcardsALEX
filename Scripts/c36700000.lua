--Fabled Tennin
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Destroy up to the difference of cards in hands
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Negate and discard 1 "Fabled"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--Special Summon Level 8 or lower Fabled Synchro from Extra Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

--Condition: Synchro Summoned
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

--Target cards to destroy up to difference in hand counts
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local diff=math.abs(Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)-Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0))
	if chk==0 then return diff>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,diff,1-tp,LOCATION_ONFIELD)
end

--Destroy operation
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local diff=math.abs(Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)-Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0))
	if diff<=0 then return end
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,diff,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
		if diff>=2 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

--Negate condition
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev)
end

--Negate target
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fabledfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

function s.fabledfilter(c)
	return c:IsSetCard(0x35) and c:IsDiscardable()
end

--Negate operation
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(tp,s.fabledfilter,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		end
	end
end

--Condition: Leaves the field, was Synchro Summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end

--Special Summon Level 8 or lower "Fabled" Synchro
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x35) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(8)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

