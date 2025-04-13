-- Rainbow Crystal Beast Ruby Carbuncle
local s,id=GetID()
function s.initial_effect(c)
    -- Convertirse en Continuous Spell en vez de destruirse
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_SEND_REPLACE)
    e1:SetTarget(s.reptg)
    c:RegisterEffect(e1)

    -- Colocar un "Crystal Beast" en la S/T Zone
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOZONE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.stztg)
    e2:SetOperation(s.stzop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Enviar como Continuous Spell al GY para Invocar un "Ultimate Crystal" o "Rainbow Neos"
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetCost(s.spcost)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- **Convertirse en Continuous Spell en vez de destruirse**
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    return true
end

-- **Colocar un "Crystal Beast" en la S/T Zone**
function s.stzfilter(c)
    return c:IsSetCard(0x1034) and not c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsForbidden()
end
function s.stztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.stzfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
end
function s.stzop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.stzfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil):GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

-- **Enviar como Continuous Spell al GY para Invocar un "Ultimate Crystal" o "Rainbow Neos"**
function s.spfilter(c,e,tp)
    return (c:IsSetCard(0x1040) or c:IsCode(86346643)) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
    end
end
