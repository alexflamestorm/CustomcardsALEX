-- Fortune Lady Guide
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),2,99)

    -- Gana ATK basado en los Niveles totales de "Fortune Lady"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- No puede atacar directamente
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    c:RegisterEffect(e2)

    -- Daño de perforación
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e3)

    -- Efectos de Main Phase (cambiar Nivel o invocar Fortune Lady)
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.target)
    e4:SetOperation(s.operation)
    c:RegisterEffect(e4)
end

-- **Gana ATK basado en los niveles de Fortune Lady**
function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x31) -- Fortune Lady
end
function s.atkval(e,c)
    local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)
    return g:GetSum(Card.GetLevel)*200
end

-- **Efecto de Main Phase: Elegir cambiar nivel o invocar**
function s.filter(c,e,tp)
    return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
        or e:GetHandler():GetLinkedGroup():IsExists(Card.IsFaceup,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetLinkedGroup():Filter(Card.IsFaceup,nil)
    local opt=0
    if #g>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) then
        opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif #g>0 then
        opt=0
    else
        opt=1
    end

    if opt==0 then
        -- Cambiar Nivel a 12
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetValue(12)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    else
        -- Invocar una "Fortune Lady"
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
        if sc then
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

