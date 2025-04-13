--Griffolis, Herald of The Ice Barrier
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	--On Synchro Summon: Special Synchro from Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--Cannot activate monster effects in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(s.handcon)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
end

--Only if this card was Synchro Summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

--Find a valid Synchro Monster from Extra Deck
function s.filter(c,e,tp,mg)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsSynchroSummonable(nil,mg)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x2f),tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x2f),tp,LOCATION_GRAVE,0,nil)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			--Seleccionar materiales que sumen exactamente el nivel
			local lv=sc:GetLevel()
			local mat=aux.SelectUnselectGroup(mg,e,tp,1,63,nil,1,tp,HINTMSG_TODECK,function(g) return g:GetSum(Card.GetLevel)==lv end)
			if #mat>0 then
				Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_COST)
				Duel.BreakEffect()
				Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
			end
		end
	end
end

--Condition for hand effect lock
function s.handfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f) and c:IsType(TYPE_SYNCHRO)
end

function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.handfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.aclimit(e,re,tp)
	local loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_HAND
end
