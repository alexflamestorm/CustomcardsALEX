-- The Phantom Knights of Sharp Spear
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),2,99)

    -- Boost ATK y daño de perforación
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
    e1:SetValue(1000)
    c:RegisterEffect(e1)
    
    local e2=e1:Clone()
    e2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e2)

    -- Hacer que el oponente mande 1 carta al GY
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.tgcon)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_REMOVE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.rmcon)
    e4:SetOperation(s.tgop)
    c:RegisterEffect(e4)

    -- Revivir un Phantom Knights Xyz desde el Extra Deck
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1,{id,1})
    e5:SetCost(aux.bfgcost)
    e5:SetTarget(s.xyztg)
    e5:SetOperation(s.xyzop)
    c:RegisterEffect(e5)
end

-- **Condición: Se invocó un Xyz Phantom Knights**
function s.tgfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0xdb) and c:IsType(TYPE_XYZ) and c:IsSummonPlayer(tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.tgfilter,1,nil,tp)
end

-- **Condición: Se removió un Spell/Trap Phantom Knights**
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsSetCard,1,nil,0xdb)
end

-- **Hacer que el oponente mande una carta al GY**
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ONFIELD,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
        local sg=g:Select(1-tp,1,1,nil)
        Duel.SendtoGrave(sg,REASON_EFFECT)
    end
end

-- **Target para la invocación Xyz desde el Extra Deck**
function s.xyzfilter(c,e,tp)
    return c:IsSetCard(0xdb) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- **Revivir un Xyz Phantom Knights**
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
    end
end
