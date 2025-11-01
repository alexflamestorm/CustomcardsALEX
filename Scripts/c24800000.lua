-- Thunder Dragon Cyclops
-- ID: 100000015
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Procedure
	c:EnableReviveLimit()
	local th_lord_id = 05206415 -- Placeholder ID for Thunder Dragonlord
	local th_matrix_id = 20318029 -- Placeholder ID for Thunder Dragonmatrix
	Fusion.AddProcMix(c,true,true,th_lord_id,th_matrix_id)

	-- Alternative Summon Procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.altcon)
	e0:SetTarget(s.alttg)
	e0:SetOperation(s.altop)
	e0:SetValue(SUMMON_TYPE_FUSION) -- Considered a Fusion Summon for revive limit
	c:AddEffect(e0)
	-- Helper effect to track Thunder hand activations this turn
	local e0_flag=Effect.CreateEffect(c)
	e0_flag:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0_flag:SetCode(EVENT_CHAINING) -- Check when effects activate
	e0_flag:SetOperation(s.regop)
	Duel.RegisterEffect(e0_flag,0)

	-- Effect 1: Add banished Thunder Dragon monsters to hand (HOPT)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id) -- HOPT for each effect separately
	e1:SetCost(s.thcost1)
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:AddEffect(e1)

	-- Effect 2: SS Thunder Fusion during opponent's Standby Phase (HOPT)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) -- Trigger Quick Effect
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id, 1}) -- Use flag 1 for second HOPT clause
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:AddEffect(e2)
end
s.listed_series={0x11c} -- Thunder Dragon archetype code
s.th_matrix_id = 20318029 -- Store matrix ID for easy access

-- Helper for Alternative Summon: Register flag if Thunder effect activates in hand
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_HAND and re:GetHandler():IsRace(RACE_THUNDER) then
		Duel.RegisterFlagEffect(tp,id+1000,RESET_PHASE+PHASE_END,0,1) -- Register flag for player tp
	end
end

-- Alternative Summon Procedure
function s.matfilter1(c) -- Thunder monster from Hand/Field
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemove()
end
function s.matfilter2(c) -- Thunder Dragonmatrix from Hand/Deck/GY
	return c:IsCode(s.th_matrix_id) and c:IsAbleToRemove()
end
function s.altcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<-1 then return false end -- Need space for 1 monster
	-- Check if flag is active (Thunder effect activated in hand this turn)
	if Duel.GetFlagEffect(tp,id+1000)==0 then return false end
	-- Check if materials exist
	local mg1=Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	local mg2=Duel.GetMatchingGroup(s.matfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
	return aux.SelectUnselectGroup(mg1,e,tp,1,1,nil,0) and aux.SelectUnselectGroup(mg2,e,tp,1,1,nil,0)
end
function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg1=Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	local mg2=Duel.GetMatchingGroup(s.matfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- Player selects 1 from mg1 and 1 from mg2
	local g1=aux.SelectUnselectGroup(mg1,e,tp,1,1,nil,1,tp,HINTMSG_REMOVE,nil,nil,true)
	local g2=aux.SelectUnselectGroup(mg2,e,tp,1,1,nil,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g1>0 and #g2>0 then
		g1:Merge(g2)
		g1:KeepAlive()
		e:SetLabelObject(g1) -- Store selected materials
		return true
	end
	return false
end
function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT) -- Banish the materials
	g:DeleteGroup()
	-- Card is summoned automatically by the procedure
end

-- Effect 1: Add banished Thunder Dragon monsters to hand
function s.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
function s.thfilter1(c)
	return c:IsSetCard(0x11c) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	local tg=Group.CreateGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc1=g:Select(tp,1,1,nil):GetFirst()
	if not tc1 then return end
	tg:AddCard(tc1)
	g:RemoveCard(tc1)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then -- Ask to add a second one?
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- Filter out cards with the same name as the first selection
		local tc2=g:FilterSelect(tp,function(c) return c:GetCode()~=tc1:GetCode() end,1,1,nil):GetFirst()
		if tc2 then
			tg:AddCard(tc2)
		end
	end
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end

-- Effect 2: SS Thunder Fusion during opponent's Standby Phase
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==1-tp
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToTributeAsCost() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsType(TYPE_FUSION) and c:IsLevelAbove(7)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),c:GetOriginalSetCard(),c:GetOriginalType(),c:GetOriginalAttack(),c:GetOriginalDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute(),POS_FACEUP,tp,SUMMON_TYPE_FUSION)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- Use SpecialSummonRule which bypasses location checks and treats as proper summon type
		Duel.SpecialSummonRule(tp,tc,SUMMON_TYPE_FUSION)
		tc:CompleteProcedure()
	end
end