--Archfiend Skull Overlord of Doom
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.matfilter1,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND))
	--Name becomes "Summoned Skull"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(CARD_SUMMONED_SKULL)
	c:RegisterEffect(e1)
	--Always treated as Archfiend
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetValue(SET_ARCHFIEND)
	c:RegisterEffect(e2)
	--Destroy all non-Fiend monsters if Special Summoned
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Restriction to 1 attack if destruction effect used
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	c:RegisterEffect(e4)
	--ATK boost if only Fiends
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.boostcon)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FIEND))
	e5:SetValue(500)
	c:RegisterEffect(e5)
	--Banish destroyed opponent's monsters
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_SEND_REPLACE)
	e7:SetTarget(s.reptg)
	c:RegisterEffect(e7)
end
s.listed_names=(70781052)
s.listed_series=(0x45)

--Fusion Material filter: Level 6 Archfiend Fusion Monster
function s.matfilter1(c,fc,sub,mg,sg)
	return c:IsSetCard(0x45) and c:IsType(TYPE_FUSION) and c:IsLevel(6)
end

--Destroy all non-Fiend monsters
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and not c:IsRace(RACE_FIEND) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and not c:IsRace(RACE_FIEND) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
		--Mark that effect was used this turn
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

--Restrict to 1 attack if destruction effect was used
function s.atkcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.atktg(e,c)
	return c~=e:GetHandler()
end

--Boost condition: only Fiends
function s.boostcon(e)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return #g>0 and g:FilterCount(Card.IsRace,nil,RACE_FIEND)==#g
end

--Replace opponent's destroyed monsters with banish
function s.reptg(e,c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-e:GetHandlerPlayer()
end
