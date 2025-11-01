-- Infernity Fraudster
-- ID: 100000029
local s,id=GetID()
local INFERNITY_ARCHETYPE = 0xb -- Infernity Archetype Code
local INFERNITY_HAND_NEGATE_FLAG = 0x100 -- Custom flag to signal "ignore no hand condition"

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Link Summon Procedure: 2 DARK monsters
	Link.AddProcedure(c, Card.IsAttribute, (ATTRIBUTE_DARK), 2)
	-- Assuming Link 2, with arrows Bottom-Left and Bottom-Right
	c:SetLinkField(LINK_BL+LINK_BR) 

	-- E1 (Continuous): Ignore "no cards in hand" condition for monster effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(INFERNITY_HAND_NEGATE_FLAG)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE) -- Set a flag that other Infernity scripts can check
	e1:SetTargetRange(LOCATION_MZONE, 0)
	-- Value could be a function to check the specific text if engine supports, 
	-- but here we just set a flag for other scripts to reference.
	c:AddEffect(e1)

	-- E2 (HOPT Ignition): Send Infernity card, Set Infernity S/T
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id) -- HOPT for effect 2
	e2:SetCondition(s.actcon2)
	e2:SetTarget(s.acttg2)
	e2:SetOperation(s.actop2)
	c:AddEffect(e2)
end
s.listed_series={INFERNITY_ARCHETYPE}

-- E2: Send to GY and Set S/T
function s.actcon2(e, tp, eg, ep, ev, re, r, rp)
	-- If you have no cards in your hand
	return Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) == 0
end

function s.st_filter(c)
	-- Infernity Spell/Trap card
	return c:IsSetCard(INFERNITY_ARCHETYPE) and (c:IsSpell() or c:IsTrap())
end

function s.any_filter(c)
	-- Any Infernity card
	return c:IsSetCard(INFERNITY_ARCHETYPE)
end

function s.acttg2(e, tp, eg, ep, ev, re, r, rp, chk)
	local st_exists = Duel.IsExistingMatchingCard(s.st_filter, tp, LOCATION_DECK, 0, 1, nil)
	
	if chk==0 then
		-- Check if any Infernity card to send to GY AND Infernity S/T to Set exists
		return Duel.IsExistingMatchingCard(s.any_filter, tp, LOCATION_DECK, 0, 1, nil) and st_exists
	end

	-- Operations Info
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
	if st_exists then
		Duel.SetOperationInfo(0, CATEGORY_SET, nil, 1, tp, LOCATION_DECK)
	end
end

function s.actop2(e, tp, eg, ep, ev, re, r, rp)
	-- 1. Send 1 "Infernity" card from Deck to the GY
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp, s.any_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g1 > 0 then
		Duel.SendtoGrave(g1, REASON_EFFECT)
		
		Duel.BreakEffect()
		-- 2. Set 1 "Infernity" Spell/Trap Card directly from your Deck
		local g2=Duel.SelectMatchingCard(tp, s.st_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
		if #g2 > 0 and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 then
			Duel.SSet(g2:GetFirst())
		end
	end
end