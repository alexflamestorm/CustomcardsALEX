--Fossil Dragon Skull Raptor
local s,id=GetID()
function s.initial_effect(c)
	--Must be Special Summoned with "Fossil Fusion"
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	
	--Send 1 Fossil monster from Extra Deck, change position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.poscon)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)

	--Extra attack and recover LP
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	--Banish from GY to bounce
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- Material filter for custom fusion (Rock + Level 6 or higher)
function s.matfilter(c,fc,sub,mg,sg,stopchk)
	return c:IsRace(RACE_ROCK) or c:IsLevelAbove(6)
end

-- On Special Summon condition
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.tgfilter(c)
	return c:IsSetCard(0x122) and c:IsAbleToGrave()
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local tg=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,1,nil)
		if #tg>0 then
			Duel.ChangePosition(tg,POS_FACEUP_DEFENSE)
		end
	end
end

-- Destroy DEF position monster by battle
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc:IsDefensePos() and bc:IsReason(REASON_BATTLE)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		local val=bc:GetAttack()
		if val<0 then val=0 end
		Duel.Recover(tp,val,REASON_EFFECT)
		-- Gain additional attack
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end

-- Banish to return cards
function s.thfilter1(c)
	return c:IsSetCard(0x122) and c:IsAbleToHand()
end

function s.thfilter2(c)
	return c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter2,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,PLAYER_EITHER,LOCATION_GRAVE+LOCATION_MZONE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	if #g1>0 and #g2>0 then
		g1:Merge(g2)
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
	end
end
