-- Thunder Dragon Cyclops
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Summon
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsCode,100000240),aux.FilterBoolFunction(Card.IsCode,100000241)) -- Assuming Thunder Dragonlord = 100000240, Thunder Dragonmatrix = 100000241

    -- Special Summon condition (alternative)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Add 2 banished Thunder Dragons
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Tribute during opponent's Standby Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.sp2con)
    e3:SetCost(s.sp2cost)
    e3:SetTarget(s.sp2tg)
    e3:SetOperation(s.sp2op)
    c:RegisterEffect(e3)
end

-- Alt. Special Summon Condition
function s.cfilter(c)
    return c:IsRace(RACE_THUNDER) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(aux.FilterCodeFunction(Card.IsAbleToRemoveAsCost,100000241),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.GetFlagEffect(tp,100000234)>0 -- Thunder monster effect activated in hand
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,aux.FilterCodeFunction(Card.IsAbleToRemoveAsCost,100000241),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    g1:Merge(g2)
    Duel.Remove(g1,POS_FACEUP,REASON_COST)
end

-- Discard 1; Add up to 2 Thunder Dragons from banishment
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
    return c:IsSetCard(0x11c) and c:IsAbleToHand() and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
        return g:GetClassCount(Card.GetCode)>=2
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
    local sg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,true,nil)
    if #sg>0 then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end

-- Flag check (fake Thunder monster activation tracker)
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if re and re:GetHandler():IsRace(RACE_THUNDER) and re:GetActivateLocation()==LOCATION_HAND then
        Duel.RegisterFlagEffect(tp,100000234,RESET_PHASE+PHASE_END,0,1)
    end
end

-- Opponent's Standby Phase Condition
function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.sp2cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.sp2filter(c,e,tp)
    return c:IsRace(RACE_THUNDER) and c:IsType(TYPE_FUSION) and c:IsLevelAbove(7)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 
        and Duel.IsExistingMatchingCard(s.sp2filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.sp2filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
    end
end
