--Fortune Lady Priestess Tenebris
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--ATK/DEF basado en Nivel
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	--Aumentar Nivel en Standby Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	--Inmunidad para Spellcasters (Synchro con Fortune)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.immcon)
	e4:SetOperation(s.immop)
	c:RegisterEffect(e4)
	--Special Summon de Fortune
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end

--ATK/DEF = Nivel x 400
function s.value(e,c)
	return c:GetLevel()*400
end

--Aumentar nivel (máx. 12)
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:GetLevel()<12 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end

--Comprobación Synchro con Fortune Fairy/Lady
function s.matfilter(c)
	return c:IsSetCard(0x31) or c:IsSetCard(0x520)
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and mg:IsExists(s.matfilter,1,nil)
end

--Dar inmunidad a Spellcasters
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE,0,nil,RACE_SPELLCASTER)
	if #g>0 then
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--Costo: Reducir nivel en 2
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:GetLevel()>2 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end

--Special Summon de Fortune Fairy/Lady
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x31) or c:IsSetCard(0x520)) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		--Banish en End Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOperation(function(_,tp) Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end)
		tc:RegisterEffect(e1)
	end
end
