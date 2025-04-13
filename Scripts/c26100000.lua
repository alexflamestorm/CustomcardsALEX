--Fossil Giant Skull Gaia
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	aux.AddFusionProcCodeFun(c,nil,aux.FilterBoolFunction(Card.IsLevelAbove,5),1,true,true)

	--Must first be Special Summoned with "Fossil Fusion"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	--ATK boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)

	--Halve opponent monsters' ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.halfval)
	c:RegisterEffect(e2)

	--Negate Spell/Trap and banish all copies
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end

function s.matfilter(c)
	return c:IsRace(RACE_ROCK)
end

-- ATK Gain for each banished/GY Rock
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsRace,c:GetControler(),LOCATION_GRAVE+LOCATION_REMOVED,0,nil,RACE_ROCK)
	return g:GetCount()*200
end

-- Halve ATK
function s.halfval(e,c)
	return math.floor(c:GetAttack()/2)
end

-- Negate Spell/Trap
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,100000294),tp,LOCATION_GRAVE,0,1,nil) -- Fossil Fusion
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		local code=rc:GetCode()
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,nil,code)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
