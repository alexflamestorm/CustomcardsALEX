--Battlewasp - Voulge the Insurgent
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Tuner or Non-Tuner flexibility
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(SUMMON_TYPE_SYNCHRO)
	e0:SetCondition(s.matcon)
	c:RegisterEffect(e0)

	-- Quick Effect: Custom Synchro Summon by banishing Insects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCost(s.qscost)
	e1:SetTarget(s.qstg)
	e1:SetOperation(s.qsop)
	c:RegisterEffect(e1)

	-- Tag out "Battleswap" Synchro Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.swapcon)
	e2:SetTarget(s.swaptg)
	e2:SetOperation(s.swapop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end

-- Tuner flexibility if used as material
function s.matcon(e,c)
	local tc=e:GetHandler()
	return c and c:IsRace(RACE_INSECT)
end

-- Quick Synchro Summon
function s.qscfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
function s.qscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.qscfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetCount()>=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,2,99,nil)
	e:SetLabel(rg:GetSum(Card.GetLevel))
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.qsfilter(c,lv,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.qstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.qsfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetLabel(),e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.qsop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.qsfilter,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp)
	local sc=g:GetFirst()
	if sc then
		Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

-- Swap Battleswap Synchro Monsters
function s.swapcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
function s.swapfilter(c,lv)
	return c:IsSetCard(0x12f) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.swaptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,0x12f)
		return g:IsExists(function(c)
			return Duel.IsExistingMatchingCard(s.swapfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetLevel())
		end,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.swapop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,0x12f)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tg=g:FilterSelect(tp,function(c)
		return Duel.IsExistingMatchingCard(s.swapfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetLevel())
	end,1,1,nil)
	local tc=tg:GetFirst()
	if not tc then return end
	local lv=tc:GetLevel()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.swapfilter,tp,LOCATION_EXTRA,0,1,1,nil,lv):GetFirst()
		if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
			-- Optional: switch DEF to ATK
			local opg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
			if #opg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.ChangePosition(opg,POS_FACEUP_ATTACK)
			end
		end
	end
end
