-- Infinite Knight Timaeus
local s,id=GetID()
function s.initial_effect(c)
    -- Requisitos de invocación (Link-3, 3 Warriors)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR),3,3)

    -- No puede ser destruido ni seleccionado por efectos
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e0:SetValue(aux.tgoval)
    c:RegisterEffect(e0)
    local e1=e0:Clone()
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Invocar "Legendary Knight" desde la mano, Deck o GY
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Invocar "Timaeus the Knight of Destiny" desde el Extra Deck
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.tkodcon)
    e3:SetCost(s.tkodcost)
    e3:SetTarget(s.tkodtg)
    e3:SetOperation(s.tkodop)
    c:RegisterEffect(e3)
end

-- **Efecto 1: Invocar "Legendary Knight"**
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.spfilter(c,e,tp,zone)
    return c:IsSetCard(0x10f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,e:GetHandler():GetLinkedZone(tp))>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler():GetLinkedZone(tp)) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local zone=c:GetLinkedZone(tp)
    if zone==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
    end
end

-- **Efecto 2: Invocar "Timaeus the Knight of Destiny"**
function s.tkodfilter(c)
    return c:IsSetCard(0x10f) and c:IsMonster()
end
function s.tkodcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.tkodfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    return g:GetClassCount(Card.GetCode)>=3
end
function s.tkodcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.tkodtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,100000103),tp,LOCATION_EXTRA,0,1,nil)
        and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.tkodop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)<=0 then return end
    local tc=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsCode,100000103),tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
    end
end
