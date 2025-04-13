--Black Luster Soldier, the Chaos Blue Magician
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Ritual Summon condition
    Ritual.AddProcGreater(c,aux.FilterBoolFunction(Card.IsCode,46986414)) --"Chaos Form"

    --Can be used as the entire requirement for a "Chaos" Ritual Summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e1:SetCondition(s.ritcon)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    --Gain Spell Counters
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)

    --Special Summon "Black Luster Soldier" or "Gaia the Fierce Knight" monsters
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Condition to be used as full material for a "Chaos" Ritual Summon
function s.ritcon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0
end

-- Gain Spell Counters
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    if re:IsActiveType(TYPE_SPELL) then
        local c=e:GetHandler()
        if c:GetCounter(0x1)<3 then
            c:AddCounter(0x1,1)
        end
    end
end

-- Special Summon condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0x1)>0
end

-- Special Summon cost (Tribute itself)
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ct=c:GetCounter(0x1)
    if chk==0 then return ct>0 and c:IsReleasable() end
    e:SetLabel(ct)
    Duel.Release(c,REASON_COST)
end

-- Special Summon target
function s.spfilter(c,e,tp)
    return (c:IsSetCard(SET_BLACK_LUSTER_SOLDIER) or c:IsCode(6368038)) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetLabel()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct 
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,ct,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

-- Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,ct,ct,nil,e,tp)
    if #g>0 then
        for sc in aux.Next(g) do
            Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP)
        end
        Duel.SpecialSummonComplete()
    end
end