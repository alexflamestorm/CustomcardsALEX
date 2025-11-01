-- Thunder Dragon Gigant
-- ID: 37500000
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)

	-- Alternative Summon Procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.altcon)
	e0:SetTarget(s.alttg)
	e0:SetOperation(s.altop)
	e0:SetValue(SUMMON_TYPE_FUSION) -- Considered a Fusion Summon for revive limit, but doesn't use Poly
	c:AddEffect(e0)
	-- Helper effect to track Thunder Dragon summons this turn
	local e0_flag=Effect.CreateEffect(c)
	e0_flag:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0_flag:SetCode(EVENT_SUMMON_SUCCESS)
	e0_flag:SetOperation(s.regop)
	Duel.RegisterEffect(e0_flag,0)
	local e0_flag2=e0_flag:Clone()
	e0_flag2:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e0_flag2,0)


	-- Effect 1: Negate monster effect when targeted (Quick Effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BE_TARGETED) -- Triggers when this card is targeted
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:AddEffect(e1)

	-- Effect 2: Burn damage when Thunder effect activates in hand (Twice per turn, Quick Effect)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) -- Trigger Quick Effect
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP) -- Works in Damage Step
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2) -- Twice per turn (per instance)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:AddEffect(e2)

	-- Effect 3: Float into Extra Deck Thunder monster if destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:AddEffect(e3)
end
s.listed_series={0x11c} -- Thunder Dragon archetype code

-- Fusion Materials
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x11c) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK|ATTRIBUTE_WIND|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_EARTH,fc,sumtype,tp)
end
function s.fusfinal(g) -- Check if attributes are different
	return g:GetClassCount(Card.GetAttribute)==#g
end
-- Set Fusion info correctly using AddProcMixN and the final check
Fusion.AddProcMixN(s.initial_effect,true,true,s.matfilter,2,s.fusfinal)

-- Alternative Summon Procedure
function s.regfilter(c)
	return c:IsSetCard(0x11c)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg and eg:IsExists(s.regfilter,1,nil) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1) -- Register flag for player tp
	end
end
function s.altcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- Check if a Thunder Dragon was summoned this turn (flag check)
	-- and if there's a Thunder Dragon monster to tribute
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 -- Need space adjustment if tributing occupied zone
		and Duel.GetFlagEffect(tp,id)>0
		and Duel.IsExistingMatchingCard(s.tribute_filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tribute_filter(c)
	return c:IsSetCard(0x11c) and c:IsAbleToTributeAsCost()
end
function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.tribute_filter,1,false,nil,c) end
	local g=Duel.SelectReleaseGroupCost(tp,s.tribute_filter,1,1,false,nil,c)
	Duel.SetTargetCard(g) -- Pass the tributed monster to operation if needed, though not explicitly required by text
	Duel.Release(g,REASON_COST)
end
function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
	-- Card is summoned automatically by the procedure
end

-- Effect 1: Negate monster effect when targeted
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- Check if targeted by a card effect (not attack) and effect hasn't resolved yet
	return re and (re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainDisablable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_ALL,LOCATION_MZONE) -- Target selection happens in operation
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET) -- Negate the chain that targeted this card
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end


-- Effect 2: Burn damage
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- Check if player activating is tp, location is hand, race is Thunder, and it's a monster effect
	return re:IsActiveType(TYPE_MONSTER) and rp==tp and re:IsMonsterEffect()
		and re:GetActivateLocation()==LOCATION_HAND
		and re:GetHandler():IsRace(RACE_THUNDER)
		and re:GetHandler():GetLevel()>0 -- Ensure it has a level
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=re:GetHandler():GetLevel()*200
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,dam,REASON_EFFECT)
end

-- Effect 3: Float
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Destroyed (battle or effect), owner's control, was Fusion Summoned initially
	return c:IsPreviousControler(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsAttackBelow(3000) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,true,POS_FACEUP) -- Ignore summoning conditions flag is true
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_SPECIAL,tp,tp,false,true,POS_FACEUP) -- Ignore conditions flag is true
	end
end