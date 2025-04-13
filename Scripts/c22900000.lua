-- High Purple Gadget
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from hand if 2+ Level 4 Gadgets with different names in field or GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Banish 1 Gadget, summon different one from Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Revive the banished monster when this is sent to GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCondition(s.spcon2)
    e4:SetTarget(s.sptg2)
    e4:SetOperation(s.spop2)
    c:RegisterEffect(e4)
end

-- Check 2+ Level 4 Gadgets with different names on field or GY
function s.gadgetfilter(c)
    return c:IsLevel(4) and c:IsSetCard(0x51) and c:IsType(TYPE_MONSTER)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.gadgetfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    return g:GetClassCount(Card.GetCode)>=2
end

-- Banish 1 Level 4 Gadget, summon another with different name
function s.rmfilter(c,tp)
    return c:IsLevel(4) and c:IsSetCard(0x51) and c:IsAbleToRemove()
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.spfilter(c,code)
    return c:IsLevel(4) and c:IsSetCard(0x51) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
    local rc=g:GetFirst()
    if rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 then
        e:GetHandler():CreateEffectRelation(e)
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,rc:GetCode())
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,rc:GetCode())
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Revive the banished Gadget when this card is sent to the GY
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local code=e:GetHandler():GetFlagEffectLabel(id)
        return code and Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_REMOVED,0,1,nil,code,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.rvfilter(c,code,e,tp)
    return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local code=e:GetHandler():GetFlagEffectLabel(id)
    local g=Duel.SelectMatchingCard(tp,s.rvfilter,tp,LOCATION_REMOVED,0,1,1,nil,code,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
