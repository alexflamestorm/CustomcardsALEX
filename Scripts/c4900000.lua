--Morphtronic Cran
local s,id=GetID()
function s.initial_effect(c)
    -- Efecto en Posición de Ataque: Invoca un Morphtronic Tuner desde el GY
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Efecto en Posición de Defensa: Invoca un Morphtronic desde el GY
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.defcon)
    e2:SetTarget(s.deftg)
    e2:SetOperation(s.defop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)

    -- Restricción de Invocación Especial solo de Synchro después de usar los efectos
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(1,0)
    e3:SetTarget(s.splimit)
    c:RegisterEffect(e3)
end

--Condición de Posición de Ataque
function s.atkcon(e)
    return e:GetHandler():IsPosition(POS_ATTACK)
end

--Filtrar Morphtronic Tuner en el GY
function s.tunerfilter(c,e,tp)
    return c:IsSetCard(0x26) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end

--Objetivo del efecto en Posición de Ataque
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.tunerfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operación del efecto en Posición de Ataque
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.SelectMatchingCard(tp,s.tunerfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Aplicar la restricción de Invocar solo Synchros
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

--Condición de Posición de Defensa
function s.defcon(e)
    return e:GetHandler():IsPosition(POS_DEFENSE)
end

--Filtrar Morphtronic en el GY
function s.morphfilter(c,e,tp)
    return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Objetivo del efecto en Posición de Defensa
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.morphfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operación del efecto en Posición de Defensa
function s.defop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.SelectMatchingCard(tp,s.morphfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
        -- Aplicar la restricción de Invocar solo Synchros
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

--Restricción de Invocar solo Synchros después de usar los efectos
function s.splimit(e,c)
    return not c:IsType(TYPE_SYNCHRO)
end
