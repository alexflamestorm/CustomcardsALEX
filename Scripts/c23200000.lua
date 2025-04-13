-- Blue-Eyes Prime Spirit Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),2,2,aux.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    -- Battle/card effect immunity
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    c:RegisterEffect(e2)

    -- Negate and Special Summon non-Synchro Blue-Eyes
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    -- Extra Special Summon after successful negation
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.sscon)
    e4:SetTarget(s.sstg)
    e4:SetOperation(s.ssop)
    c:RegisterEffect(e4)
end

-- Check if Synchro Summoned using Blue-Eyes or Special Summoned by Blue-Eyes card
function s.immcon(e)
    local c=e:GetHandler()
    local m=c:GetMaterial()
    return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and m:IsExists(Card.IsCode,1,nil,89631139)
        or c:GetSummonLocation()==LOCATION_EXTRA and c:GetReasonEffect() and c:GetReasonEffect():GetHandler():IsSetCard(0xdd)
end

-- Negate and Special Summon from GY
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainNegatable(ev)
end
function s.spfilter(c)
    return c:IsSetCard(0xdd) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
            e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,g:GetFirst():GetLevel())
        end
    end
end

-- Check if negation resolved
function s.sscon(e)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.ssfilter(c,lv)
    return c:IsSetCard(0xdd) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    local lv=e:GetHandler():GetFlagEffectLabel(id)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,lv) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    local lv=e:GetHandler():GetFlagEffectLabel(id)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,lv)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
