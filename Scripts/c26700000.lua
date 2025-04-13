--The Chosen Pharaoh
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be negated
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e0:SetCondition(s.condition)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	e0:SetCountLimit(1,id)
	c:RegisterEffect(e0)

	--To deck & add "The True Name"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.gycon)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

--Check if "Slifer", "Obelisk" and "Ra" were successfully Summoned this Duel
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,10000020)>0 and Duel.GetFlagEffect(tp,10000010)>0 and Duel.GetFlagEffect(tp,10000000)>0
end

function s.filter(c)
	return c:IsCode(10000020,10000010,10000000) and c:IsAbleToRemove()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,3,nil)
			and (Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp))
	end
end

function s.spfilter(c,e,tp)
	return c:IsCode(99999999) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local rg=Group.CreateGroup()
	local codes={[10000020]=false,[10000010]=false,[10000000]=false}
	for tc in aux.Next(g) do
		if not codes[tc:GetCode()] then
			codes[tc:GetCode()]=true
			rg:AddCard(tc)
			if rg:GetCount()==3 then break end
		end
	end
	if rg:GetCount()==3 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		local spg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		if #spg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=spg:Select(tp,1,1,nil):GetFirst()
			if sc then
				Duel.SpecialSummon(sc,0,tp,tp,true,true,POS_FACEUP)
			end
		end
	end
end

-- GY effect
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID() and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,1,nil,RACE_DIVINE)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tnfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.tnfilter(c)
	return c:IsCode(87210505) and c:IsAbleToHand()
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.tnfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.MoveToDeckTop(c)
	end
end
