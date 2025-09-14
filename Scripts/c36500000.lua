--Fabled Lilith
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),2,2,s.lcheck)
	c:EnableReviveLimit()
	--On Link Summon: discard 2, search 2
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Recycle 5, draw 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

--Link material check (at least 1 "Fabled")
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x35) --"Fabled" setcode
end

--Condition: Link Summon
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

--Cost: discard 2
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end

--Target: search 2 "Fabled" with different names from each other and discarded monsters
function s.filter(c,exc)
	return c:IsSetCard(0x35) and c:IsMonster() and c:IsAbleToHand() and not exc:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local discarded=Duel.GetOperatedGroup()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil,discarded) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local discarded=Duel.GetOperatedGroup()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,discarded)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,2,2,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	--Extra Deck restriction
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not (c:IsRace(RACE_FIEND) or c:IsRace(RACE_BEAST)) and c:IsLocation(LOCATION_EXTRA)
end

--Condition: Fabled Synchro destroyed by battle or opponent's effect while this in GY
function s.tdfilter(c,tp)
	return c:IsSetCard(0x35) and c:IsType(TYPE_SYNCHRO)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tdfilter,1,nil,tp)
end

--Target: shuffle 5, draw 2
function s.tdfilter2(c)
	return c:IsSetCard(0x35) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_GRAVE,0,5,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter2,tp,LOCATION_GRAVE,0,nil)
	if #g>=5 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,5,5,nil)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			Duel.ShuffleDeck(tp)
		end
		if sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==5 then
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end
