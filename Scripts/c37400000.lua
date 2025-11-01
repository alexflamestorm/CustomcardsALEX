-- Thunder Dragonspark
-- ID: 37400000
local s,id=GetID()
function s.initial_effect(c)
	-- Effect 1: (Quick Effect) Discard to add S/T, maybe SS
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id) -- HOPT for either effect
	e1:SetCost(aux.selfdiscard)
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:AddEffect(e1)

	-- Effect 2: Add monster if banished/sent from field to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE+EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id) -- HOPT for either effect
	e2:SetCondition(s.thcon2)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:AddEffect(e2)
end
s.listed_series={0x11c} -- Thunder Dragon archetype code

-- Effect 1: Add S/T, maybe SS
function s.thfilter1_st(c)
	return c:IsSetCard(0x11c) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thfilter1_sp(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter1_fus(c)
	return c:IsFusionMonster() and c:IsSetCard(0x11c)
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b_st = Duel.IsExistingMatchingCard(s.thfilter1_st,tp,LOCATION_DECK,0,1,nil)
	local b_sp = false
	if Duel.IsExistingMatchingCard(s.thfilter1_fus,tp,LOCATION_MZONE,0,1,nil) then
		b_sp = Duel.IsExistingMatchingCard(s.thfilter1_sp,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	if chk==0 then return b_st end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if b_sp then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	end
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1_st,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(s.thfilter1_fus,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.thfilter1_sp,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.thfilter1_sp,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

-- Effect 2: Add Monster
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Check if banished, OR sent from FIELD to GY
	return (c:IsReason(REASON_EFFECT+REASON_COST) and c:IsLocation(LOCATION_REMOVED)) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE))
end
function s.thfilter2_deck(c,level,attribute)
	-- Check for Thunder Dragon monster, correct level, different attribute, and can be added to hand
	return c:IsSetCard(0x11c) and c:IsMonster()
		and c:GetOriginalLevel()==level
		and c:GetOriginalAttribute()~=attribute
		and c:IsAbleToHand()
end
function s.thfilter2_target(c,e,tp)
	local lv=c:GetOriginalLevel()
	local att=c:GetOriginalAttribute()
	-- Check if it's Thunder, not the card itself, and if a valid target exists in the deck for it
	return c:IsRace(RACE_THUNDER) and c~=e:GetHandler() and lv>0 and att~=0
		and Duel.IsExistingMatchingCard(s.thfilter2_deck,tp,LOCATION_DECK,0,1,nil,lv,att)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- Check if there's a valid Thunder monster target in field, GY, or banished
		return Duel.IsExistingMatchingCard(s.thfilter2_target,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	-- Select the target monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2_target,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetTargetCard(g) -- Store the target
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local level=tc:GetOriginalLevel()
	local attribute=tc:GetOriginalAttribute()
	if level<=0 or attribute==0 then return end -- Safety check

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2_deck,tp,LOCATION_DECK,0,1,1,nil,level,attribute)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end