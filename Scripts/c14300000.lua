-- Ancient Fairy Exalted Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,99)

    -- Nombre tratado como "Ancient Fairy Dragon" en campo y GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(25862681) -- ID de "Ancient Fairy Dragon"
    c:RegisterEffect(e1)

    -- Permitir ataque en Posición de Defensa aplicando DEF en cálculo de daño
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DEFENSE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.deftarget)
    c:RegisterEffect(e2)

    -- (Quick Effect) Revivir monstruo y negar efectos
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Permitir ataque en DEF para "Ancient Fairy Dragon" y sus menciones
function s.deftarget(e,c)
    return c:IsCode(25862681) or c:IsHasEffect(EFFECT_CHANGE_CODE) and c:GetCode()==25862681
end

-- Filtro para revivir monstruos LIGHT Beast, Fairy o Plant de nivel 4 o menor
function s.spfilter(c,e,tp)
    return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and (c:IsRace(RACE_BEAST) or c:IsRace(RACE_FAIRY) or c:IsRace(RACE_PLANT))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

-- Seleccionar objetivo para revivir
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

-- Revivir monstruo y negar efectos
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
        local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
        local sc=sg:GetFirst()
        if sc then
            Duel.HintSelection(sg)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            sc:RegisterEffect(e1)
        end
    end
end
