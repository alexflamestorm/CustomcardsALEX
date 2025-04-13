--Super Fossil Fusion
local s,id=GetID()
function s.initial_effect(c)
	--This card's name becomes "Fossil Fusion" in the GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(100000294) -- Fossil Fusion's original card ID
	c:RegisterEffect(e0)

	--Activate: Special Summon up to 2 Fossil Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(2,id,EFFECT_COUNT_CODE_OATH) -- 2 times per duel
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--GY effect: Add Fossil Fusion from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- Filter: Fossil Fusion monsters
function s.fossilfilter(c,e,tp)
	return c:IsSetCard(0x122) and c:IsType(TYPE_FUSION)
		and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
			or c:IsLocation(LOCATION_GRAVE))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,true)
		and Duel.IsExistingMatchingCard(s.materialfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,c)
end

function s.materialfilter(c,fc)
	return c:IsCanBeFusionMaterial(fc) and c:IsAbleToRemove()
end

-- Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.fossilfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end

-- Activate
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.fossilfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,ft,nil,e,tp)
	for tc in aux.Next(g) do
		local matg=Duel.SelectMatchingCard(tp,s.materialfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil,tc)
		if #matg==2 then
			tc:SetMaterial(matg)
			Duel.Remove(matg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

-- GY Condition: not the same turn it was sent there
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end

function s.thfilter(c)
	return c:IsCode(100000294) and c:IsAbleToHand() -- Fossil Fusion
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
