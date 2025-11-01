-- Thunder Dragonorb
-- ID: 37200000
local s,id=GetID()
function s.initial_effect(c)
	-- Effect 1: Discard, Tribute Thunder, Add LIGHT/DARK Thunder
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id) -- HOPT for either effect
	e1:SetCost(aux.selfdiscard)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:AddEffect(e1)

	-- Effect 2: Shuffle Thunder from GY if banished/sent from field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE+EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id) -- HOPT for either effect
	e2:SetCondition(s.shufcon)
	e2:SetTarget(s.shuftg)
	e2:SetOperation(s.shufop)
	c:AddEffect(e2)
end

-- Effect 1: Add from Deck
function s.addfilter(c,level,attribute)
	-- Check for LIGHT or DARK, Thunder, correct level, different attribute, and can be added to hand
	return (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
		and c:IsRace(RACE_THUNDER)
		and c:IsLevel(level)
		and c:GetAttribute()~=attribute
		and c:IsAbleToHand()
end
function s.tribfilter(c,tp)
	-- Check if it's a Thunder monster that can be tributed
	return c:IsRace(RACE_THUNDER) and c:IsReleasable()
		-- Check if a valid target exists in the deck for this specific monster
		and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetAttribute())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- Check if there's a valid Thunder monster to tribute on the field
		return Duel.IsExistingMatchingCard(s.tribfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	-- Select monster to tribute
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.tribfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetTargetCard(g) -- Store the tribute target
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0) -- Tribute is sending to GY unless otherwise specified
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 then -- Release instead of Tribute for effects
		local level=tc:GetPreviousLevelOnField() -- Get level before it hit GY
		local attribute=tc:GetPreviousAttributeOnField() -- Get attribute before it hit GY
		if level<=0 or attribute==0 then return end -- Safety check

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil,level,attribute)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- Effect 2: Shuffle from GY
function s.shufcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Check if banished, OR sent from FIELD to GY
	return (c:IsReason(REASON_EFFECT+REASON_COST) and c:IsLocation(LOCATION_REMOVED)) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE))
end
function s.shuffilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsLevelAbove(4) and c:IsAbleToDeck()
end
function s.shuftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shuffilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.shufop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.shuffilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end