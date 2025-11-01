-- T.G. Blade Blaster/Assault Mode
-- ID: 10500000
local s,id=GetID()
local blaster_id = 51447164 -- ID oficial de T.G. Blade Blaster
local am_activate_id = 80280737 -- ID oficial de Assault Mode Activate

function s.initial_effect(c)
	-- Summon Condition: Must be Special Summoned with "Assault Mode Activate"
	c:SetSPSummonOnce(2)

	-- Effect 1 (HOPT): Negate and Destroy on targeting
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id) -- HOPT for this effect
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:AddEffect(e1)

	-- Effect 2 (Once per opponent's turn): Banish self and opponent's GY card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id, 1}) -- Once per opponent's turn (using custom flag 1)
	e2:SetCondition(s.bancon)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:AddEffect(e2)

	-- Effect 3 (Floating): Special Summon T.G. Blade Blaster if destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon3)
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3)
	c:AddEffect(e3)
end

-- Effect 1: Negation
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
	-- Check if effect is active and chain is disablable
	if not re or not re:IsActiveType(TYPE_ACTIVATE) or not Duel.IsChainDisablable(ev) then return false end
	-- Check if the effect targets any card the player controls
	local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
	if not tg then return false end
	return tg:IsExists(Card.IsControler, 1, nil, tp)
end
function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, e:GetHandler()) end
	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST+REASON_DISCARD, e:GetHandler())
end
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(ev, CATEGORY_NEGATE, eg, 1, 0, 0)
	Duel.SetOperationInfo(ev, CATEGORY_DESTROY, eg, 1, 0, 0)
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(re:GetHandler(), REASON_EFFECT)
	end
end

-- Effect 2: Banish
function s.bancon(e, tp, eg, ep, ev, re, r, rp)
	-- Activates during opponent's Standby Phase
	return Duel.GetTurnPlayer() == 1-tp
end
function s.banfilter(c)
	return c:IsAbleToRemove()
end
function s.bantg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingTarget(s.banfilter, tp, 0, LOCATION_GRAVE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	-- Target opponent's GY only
	Duel.SelectTarget(tp, s.banfilter, tp, 0, LOCATION_GRAVE, 1, 1, nil) 
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, e:GetHandler(), 1, 0, 0)
end
function s.banop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tc = Duel.GetFirstTarget()
	-- Check if both are still valid and the current card is on the field (location check is important for quick effects)
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
		local g = Group.FromCards(c, tc)
		Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
		
		-- Temporary banish effect: return on next Standby Phase
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabelObject(g)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY) -- Reset after activation
		Duel.RegisterEffect(e1, tp)
	end
end
function s.retcon(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for the temporary effect to activate (only on the next Standby Phase of the controller)
	return Duel.GetTurnPlayer()==tp
end
function s.retop(e, tp, eg, ep, ev, re, r, rp)
	local g = e:GetLabelObject()
	if #g>0 then
		Duel.ReturnToField(g)
	end
end

-- Effect 3: Floating
function s.spcon3(e, tp, eg, ep, ev, re, r, rp)
	-- Check if the card was destroyed while on the field
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.sptg3_filter(c, e, tp)
	return c:IsCode(blaster_id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg3(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.sptg3_filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp, s.sptg3_filter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end
function s.spop3(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
end