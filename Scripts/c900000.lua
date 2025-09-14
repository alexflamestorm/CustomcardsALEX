--Flamvell Ignite
local s,id=GetID()
function s.initial_effect(c)
	--Activate: Search or Send to GY a Pyro monster with 200 DEF
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--Once per turn: Apply effect based on summoned monster Type
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={0x2c} --Flamvell

--Filter for Pyro monster with 200 DEF
function s.thfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsDefense(200) and c:IsAbleToHand()
end
function s.gyfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsDefense(200) and c:IsAbleToGrave()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
			or Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil) 
	end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local opt=0
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil)
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		opt=0
	elseif b2 then
		opt=1
	else return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	if opt==0 then
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--Effect: Apply depending on monster's Type
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsControler,nil,1-tp) --Opponent's summoned monsters
	if #g==0 then return end
	local pyro=g:IsExists(Card.IsRace,1,nil,RACE_PYRO)
	if pyro then
		--Both players take 500 damage
		Duel.Damage(tp,500,REASON_EFFECT)
		Duel.Damage(1-tp,500,REASON_EFFECT)
	else
		--Non-Pyro: Banish cards from opponent's GY
		local ct=Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_MZONE,0,nil)+1
		local gyc=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
		if #gyc>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=gyc:Select(tp,1,math.min(ct,#gyc),nil)
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
