--In The Name of The Gods
local s,id=GetID()
function s.initial_effect(c)
	--Activate: Special Summon Divine-Beast
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)

	--GY protect effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end

-- Check if opponent declares attack
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end

-- Check if opponent activates a card/effect
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end

function s.cfilter(c)
	return c:IsCode(87210505,83764719) and c:IsAbleToGrave()
end

function s.spfilter(c,e,tp)
	return c:IsCode(10000020,10000010,10000000) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,true,true,POS_FACEUP)>0 then
			if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_FZONE,0,1,nil,99999901) then -- Sanctuary of the Gods
				if e:GetCode()==EVENT_ATTACK_ANNOUNCE then
					Duel.NegateAttack()
				elseif e:GetCode()==EVENT_CHAINING then
					Duel.NegateActivation(ev)
				end
				local rc=eg:GetFirst()
				if rc and rc:IsRelateToEffect(re) then
					Duel.Destroy(rc,REASON_EFFECT)
				end
			end
		end
	end
end

-- GY protect effect
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DIVINE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsControler(tp)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and e:GetHandler():IsAbleToRemove() end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

