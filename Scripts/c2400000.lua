-- Descendant of the Ashened City
-- ID: 100000025
local s,id=GetID()
local OBSIDIM_ID = 03055018 -- Placeholder ID for "Obsidim, the Ashened City"
local VEIDOS_ID = 787835557 -- Official ID for "Veidos the Eruption Dragon of Extinction"
local ASHENED_ARCHETYPE = 0x1a5 -- Official Archetype Code

function s.initial_effect(c)
	-- E1: Discard to Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.thcost1)
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:AddEffect(e1)

	-- E2 (HOPT): SS from GY when opponent's Pyro is destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id) -- HOPT for this effect
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:AddEffect(e2)
end
s.listed_names={OBSIDIM_ID, VEIDOS_ID}
s.listed_series={ASHENED_ARCHETYPE}

-- E1: Discard to Search
function s.thcost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(), REASON_COST+REASON_DISCARD)
end

function s.thfilter1a(c) -- Obsidim, the Ashened City
	return c:IsCode(OBSIDIM_ID) and c:IsAbleToHand()
end
function s.thfilter1b(c) -- Ashened monster or Veidos
	return (c:IsSetCard(ASHENED_ARCHETYPE) or c:IsCode(VEIDOS_ID)) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg1(e, tp, eg, ep, ev, re, r, rp, chk)
	local is_obsidim_on_field = Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_FZONE, 0, 1, nil, OBSIDIM_ID)
	
	if chk==0 then
		if is_obsidim_on_field then
			-- If Obsidim is controlled, search Ashened or Veidos
			return Duel.IsExistingMatchingCard(s.thfilter1b, tp, LOCATION_DECK, 0, 1, nil)
		else
			-- If Obsidim is NOT controlled, search Obsidim
			return Duel.IsExistingMatchingCard(s.thfilter1a, tp, LOCATION_DECK, 0, 1, nil)
		end
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop1(e, tp, eg, ep, ev, re, r, rp)
	local is_obsidim_on_field = Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_FZONE, 0, 1, nil, OBSIDIM_ID)
	
	local filter = s.thfilter1a
	if is_obsidim_on_field then
		filter = s.thfilter1b
	end
	
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end

-- E2: SS from GY
function s.spfilter2(c, tp)
	-- Check if "Obsidim, the Ashened City" is in the Field Zone
	return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_FZONE, 0, 1, nil, OBSIDIM_ID)
end
function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
	-- Condition check: "Obsidim" in Field Zone
	if not s.spfilter2(e:GetHandler(), tp) then return false end
	-- Check if a Pyro monster opponent controls was destroyed
	return eg:IsExists(s.des_filter, 1, nil, 1-tp)
end
function s.des_filter(c, opp)
	-- Check if destroyed monster was controlled by opp and is Pyro
	return c:IsPreviousControler(opp) and c:IsRace(RACE_PYRO)
end
function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop2(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
	end
end