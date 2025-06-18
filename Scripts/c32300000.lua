--Perfect Bonding
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Special Summon 1 WATER, WIND or FIRE Dinosaur from Hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Main Phase effects (Choose 1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetTarget(s.mptg)
	e2:SetOperation(s.mpop)
	c:RegisterEffect(e2)
end

-- Activation effect: Summon 1 WATER, WIND, FIRE Dinosaur from Hand/GY
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_WIND+ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Main Phase Choices
function s.hydrocond(c)
	return c:IsCode(22587018) and c:IsAbleToGraveAsCost() -- Hydrogeddon
end
function s.oxycond(c)
	return c:IsCode(58071123) and c:IsAbleToGraveAsCost() -- Oxygeddon
end
function s.windfirefilter(c,attr)
	return c:IsAttribute(attr) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToGraveAsCost()
end
function s.firedragonsp(c,e,tp)
	return c:IsCode(32200000) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) -- Replace with Fire Dragon ID
end
function s.waterdragonsp(c,e,tp)
	return c:IsCode(85066822) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) -- Water Dragon
end
function s.fusfilter(c,e,tp,m)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_SEASERPENT)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,tp)
end
function s.mptg(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end
function s.mpop(e,tp,eg,ep,ev,re,r,rp)
	-- Player chooses 1 of 3 options
	local opt=Duel.SelectOption(tp,
		aux.Stringid(id,2), -- Water Dragon
		aux.Stringid(id,3), -- Fire Dragon
		aux.Stringid(id,4)  -- Fusion
	)
	if opt==0 then
		-- Tribute Hydrogeddon + Oxygeddon for Water Dragon
		local g1=Duel.SelectMatchingCard(tp,s.hydrocond,tp,LOCATION_MZONE,0,1,1,nil)
		local g2=Duel.SelectMatchingCard(tp,s.oxycond,tp,LOCATION_MZONE,0,1,1,nil)
		if #g1>0 and #g2>0 then
			local g=Group.__add(g1,g2)
			if Duel.SendtoGrave(g,REASON_COST)==2 then
				local sc=Duel.GetFirstMatchingCard(s.waterdragonsp,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
				if sc then
					Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	elseif opt==1 then
		-- Tribute WIND + FIRE Dinosaur for Fire Dragon
		local g1=Duel.SelectMatchingCard(tp,s.windfirefilter,tp,LOCATION_MZONE,0,1,1,nil,ATTRIBUTE_WIND)
		local g2=Duel.SelectMatchingCard(tp,s.windfirefilter,tp,LOCATION_MZONE,0,1,1,nil,ATTRIBUTE_FIRE)
		if #g1>0 and #g2>0 then
			local g=Group.__add(g1,g2)
			if Duel.SendtoGrave(g,REASON_COST)==2 then
				local sc=Duel.GetFirstMatchingCard(s.firedragonsp,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
				if sc then
					Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	else
		-- Fusion Sea Serpent using Field/Hand or banish Dino in GY
		local mg1=Duel.GetFusionMaterial(tp)
		local mg2=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_DINOSAUR)
		local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1)
		if #sg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			if sc then
				local mat=mg1:Filter(Card.IsCanBeFusionMaterial,sc,tp)
				Duel.FusionSummon(tp,sc,mat,nil,REASON_EFFECT)
			end
		end
	end
end
