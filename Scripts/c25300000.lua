-- Obliterate!!! Forbidden Incarnation
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from Deck/Hand/GY ignoring summoning conditions
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Add 1 Forbidden One from GY or banished
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Check for 5 different Exodia / Forbidden One / Millennium monsters
function s.reqfilter(c)
    return (c:IsSetCard(0x40) or c:IsSetCard(0x4d) or c:IsCode(33396948) or c:IsCode(70903634)
        or c:IsCode(07902349) or c:IsCode(44519536) or c:IsCode(89091579)) and c:IsMonster()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.reqfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    return #aux.GetUniqueCards(g)>4
end

function s.spfilter(c,e,tp)
    return s.reqfilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
    if #g==0 then return end
    local b1=#g>1 and Duel.SelectYesNo(tp,aux.Stringid(id,0))
    local sg=nil
    if b1 then
        sg=g:Select(tp,1,Duel.GetLocationCount(tp,LOCATION_MZONE),nil)
    else
        sg=g:Select(tp,1,1,nil)
    end
    if #sg==0 then return end
    for tc in aux.Next(sg) do
        Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP)
        if tc:IsCode(6142213) then -- Exodia Necross
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e1:SetValue(s.immuneval)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)

            local e2=e1:Clone()
            e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
            tc:RegisterEffect(e2)

            -- Prevent self-destruction
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_CANNOT_DISABLE)
            e3:SetValue(1)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e3)
        end
    end
    Duel.SpecialSummonComplete()
end

function s.immuneval(e,re)
    return re:IsActiveType(TYPE_MONSTER)
end

-- Return 1 "Forbidden One" monster from GY/banished to hand
function s.thfilter(c)
    return s.reqfilter(c) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
