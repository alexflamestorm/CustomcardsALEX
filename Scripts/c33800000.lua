--Sillva, Elder Warlord of Dark World
local s,id=GetID()
function s.initial_effect(c)
	-- Set Super Poly or Dark World Ascension & discard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	-- Tribute and recycle Fiends to draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.drcost)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

-- Condition: Fusion Summon
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- Operation: Set Super Polymerization/Dark World Ascension + discard
function s.setfilter(c)
	return (c:IsCode(48130397) or c:IsCode(65956182)) and c:IsSSetable() -- Super Poly / Dark World Ascension
end
function s.discardfilter(c)
	return c:IsSetCard(0x6) and (c:IsCode(34230233) or c:IsCode(99458769)) -- Grapha / Reign-Beaux
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.BreakEffect()
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
			local dc=Duel.GetOperatedGroup():GetFirst()
			if dc and s.discardfilter(dc) then
				-- Allow activation this turn
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetTargetRange(LOCATION_SZONE,0)
				e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,g:GetFirst():GetCode()))
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
				-- Allow this card to be used as fusion material from GY
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
				e2:SetValue(LOCATION_GRAVE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e2)
			end
		end
	end
end

-- Cost: Tribute itself
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

-- Operation: Shuffle Fiends from GY + hand, draw 3
function s.tdfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToDeck()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	g1:Merge(g2)
	if #g1>0 then
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end
