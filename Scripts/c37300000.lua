-- Thunder Dragonsnake
-- ID: 37300000
local s,id=GetID()
function s.initial_effect(c)
	-- Effect 1: (Quick Effect) Discard to banish from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_BANISH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER+TIMING_MAIN_END) -- Usable during opponent's turn
	e1:SetCountLimit(1,id) -- HOPT for either effect
	e1:SetCondition(s.bancon)
	e1:SetCost(aux.selfdiscard)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:AddEffect(e1)

	-- Effect 2: Send "Thunder Dragon" card if banished/sent from field to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE+EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id) -- HOPT for either effect
	e2:SetCondition(s.sendcon)
	e2:SetTarget(s.sendtg)
	e2:SetOperation(s.sendop)
	c:AddEffect(e2)
end
s.listed_series={0x11c} -- Thunder Dragon archetype code

-- Effect 1: Discard to banish condition, target, operation
function s.thunfilter(c)
	return c:IsRace(RACE_THUNDER)
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	-- Check for Thunder monster on field or in GY
	return Duel.IsExistingMatchingCard(s.thunfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function s.banfilter(c,e)
	-- Target must be in GY and NOT the card being discarded (e:GetHandler())
	return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToBan() and c~=e:GetHandler()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_BANISH)
	local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_BANISH,g,1,0,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Ban(tc,POS_FACEUP,REASON_EFFECT)
	end
end


-- Effect 2: Send from Deck condition, target, operation
function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Check if banished, OR sent from FIELD to GY
	return (c:IsReason(REASON_EFFECT+REASON_COST) and c:IsLocation(LOCATION_REMOVED)) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE))
end
function s.sendfilter(c)
	return c:IsSetCard(0x11c) and c:IsAbleToGrave()
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end