--Fossil Skull Stegosaurus
local s,id=GetID()
function s.initial_effect(c)
	--Excavate top 5 cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.exctg)
	e1:SetOperation(s.excop)
	c:RegisterEffect(e1)

	--Activate Fossil Fusion when destroying a monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.fftg)
	e2:SetOperation(s.ffop)
	c:RegisterEffect(e2)
end

-- Cost: Discard this card
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- Excavate top 5
function s.excfilter(c)
	return c:IsAbleToHand() and (c:IsSetCard(0x122) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:ListsCode(89181369)))
end
function s.rockfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToGrave()
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,5)
	Duel.ConfirmDecktop(tp,5)
	local tg=g:Filter(s.excfilter,nil)
	if #tg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local th=tg:Select(tp,1,1,nil):GetFirst()
		if th then
			Duel.SendtoHand(th,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,th)
			g:RemoveCard(th)
		end
	end
	local rocks=g:Filter(s.rockfilter,nil)
	if #rocks>0 then
		Duel.SendtoGrave(rocks,REASON_EFFECT)
		g:Sub(rocks)
	end
	Duel.ShuffleDeck(tp)
end

-- Activate Fossil Fusion from hand or GY
function s.fffilter(c,tp)
	return c:IsCode(89181369) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.fftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fffilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.ffop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local g=Duel.SelectMatchingCard(tp,s.fffilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		if te then
			local cost=te:GetCost()
			local target=te:GetTarget()
			local operation=te:GetOperation()
			if cost then cost(te,tp,eg,ep,ev,re,r,rp,1) end
			if target then target(te,tp,eg,ep,ev,re,r,rp,1) end
			if operation then operation(te,tp,eg,ep,ev,re,r,rp) end
		end
	end
end
