--Fabled Reign
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--Search on activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Discard and apply effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.discost)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={0x35}

--Search effect when activated
function s.thfilter(c)
	return c:IsSetCard(0x35) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Discard cost: must be a "Fabled" monster
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.discfilter,tp,LOCATION_HAND,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.discfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		s.discard_type=tc:GetOriginalType() --save type for later
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
		--Restriction: only Special Summon "Fabled"
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return not c:IsSetCard(0x35) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.discfilter(c)
	return c:IsSetCard(0x35) and c:IsMonster() and c:IsDiscardable()
end

--Apply effect based on type
function s.tgfilter(c)
	return c:IsSetCard(0x35) and c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tp_type=s.discard_type or 0
	if tp_type & TYPE_MONSTER == 0 then return end
	local ctype=Duel.GetOperatedGroup():GetFirst()
	--Check if Beast
	if tp_type & TYPE_MONSTER ~= 0 and Duel.GetOperatedGroup():GetFirst():IsRace(RACE_BEAST) then
		--Beast effect: Send Fabled Fiend to GY
		if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	elseif Duel.GetOperatedGroup():GetFirst():IsRace(RACE_FIEND) then
		--Fiend effect: Reveal top 3, add to hand, discard 2 including revealed
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 then
			Duel.ConfirmDecktop(tp,3)
			local g=Duel.GetDecktopGroup(tp,3)
			if g:GetCount()>0 then
				Duel.DisableShuffleCheck()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ShuffleHand(tp)
				--Must discard 2 including 2 of those revealed cards
				local discard_group=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,2,2,nil)
				if #discard_group>0 then
					Duel.SendtoGrave(discard_group,REASON_EFFECT+REASON_DISCARD)
				end
			end
		end
	end
end
