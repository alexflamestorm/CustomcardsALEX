--Blooming Rose Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Send 1 Rose/Plant from Deck + Banish 1 monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.tgcon)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    --Tribute to Synchro "Rose" monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.sytg)
    e2:SetOperation(s.syop)
    c:RegisterEffect(e2)
end

-- e1: Send + Banish
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.tgfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x112) or c:IsRace(RACE_PLANT)) and c:IsAbleToGrave()
end
function s.rmvfilter(c)
    return c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.rmvfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rm=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,0,LOCATION_MZONE,1,1,nil)
        if #rm>0 then
            Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
        end
    end
end

-- e2: Tribute for Rose Synchro
function s.sytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.rosefilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler())
    end
end
function s.rosefilter(c,sc)
    local diff=c:GetLevel()-sc:GetLevel()
    if diff<=0 then return false end
    return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x112) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,diff,nil)
end
function s.gyfilter(c)
    return (c:IsSetCard(0x112) or c:IsRace(RACE_PLANT)) and c:IsAbleToRemove()
end
function s.syop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local g=Duel.SelectMatchingCard(tp,function(c) return s.rosefilter(c,c) end,tp,LOCATION_EXTRA,0,1,1,nil,c)
    local sc=g:GetFirst()
    if not sc then return end
    local lv_diff=sc:GetLevel()-c:GetLevel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local mats=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,lv_diff,lv_diff,nil)
    if #mats==lv_diff then
        Duel.Remove(mats,POS_FACEUP,REASON_COST)
        if Duel.SendtoGrave(c,REASON_COST+REASON_EFFECT)>0 and Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0 then
            Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
            sc:CompleteProcedure()
        end
    end
end
