--Morphtronic Walkie-Talkie
local s,id=GetID()
function s.initial_effect(c)
    --Efecto en Posición de Ataque: Synchro usando GY
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SYNCHRO_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    --Efecto en Posición de Defensa: Revivir monstruos Morphtronic
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.defcon)
    e2:SetTarget(s.deftg)
    e2:SetOperation(s.defop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)
end

--Condición para el efecto de Posición de Ataque
function s.atkcon(e)
    return e:GetHandler():IsPosition(POS_ATTACK)
end

--Filtrar Tuners "Morphtronic" en el GY
function s.tunerfilter(c)
    return c:IsSetCard(0x26) and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end

--Filtrar no-Tuners "Morphtronic" en el GY
function s.nontunerfilter(c)
    return c:IsSetCard(0x26) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end

--Filtrar Synchros invocables
function s.synchrofilter(c,lv)
    return c:IsType(TYPE_SYNCHRO) and c:IsSummonableCard() and c:GetLevel()==lv
end

--Objetivo del efecto en Posición de Ataque
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tunerfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

--Operación del efecto en Posición de Ataque
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.SelectMatchingCard(tp,s.tunerfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g1==0 then return end
    local lv1=g1:GetFirst():GetLevel()
    
    local g2=Duel.SelectMatchingCard(tp,s.nontunerfilter,tp,LOCATION_GRAVE,0,0,99,nil)
    local lv2=0
    for tc in aux.Next(g2) do
        lv2=lv2+tc:GetLevel()
    end

    if lv1+lv2>8 then return end

    g1:Merge(g2)
    Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)

    local sg=Duel.SelectMatchingCard(tp,s.synchrofilter,tp,LOCATION_EXTRA,0,1,1,nil,lv1+lv2)
    if #sg>0 then
        Duel.SpecialSummon(sg,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
        sg:GetFirst():CompleteProcedure()
    end
end

--Condición para el efecto de Posición de Defensa
function s.defcon(e)
    return e:GetHandler():IsPosition(POS_DEFENSE)
end

--Filtrar Synchros en el GY
function s.synchrogyfilter(c)
    return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove()
end

--Objetivo del efecto en Posición de Defensa
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.synchrogyfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operación del efecto en Posición de Defensa
function s.defop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.SelectMatchingCard(tp,s.synchrogyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #sg==0 then return end
    local lv=sg:GetFirst():GetLevel()
    Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)

    local g1=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.nontunerfilter,tp,LOCATION_GRAVE,0,nil)
    local sg2=Group.CreateGroup()
    local sum=0

    if #g1>0 then
        local tc1=g1:Select(tp,1,1,nil):GetFirst()
        sg2:AddCard(tc1)
        sum=sum+tc1:GetLevel()
    end

    while sum<lv and #g2>0 do
        local tc2=g2:Select(tp,1,1,nil):GetFirst()
        sg2:AddCard(tc2)
        sum=sum+tc2:GetLevel()
    end

    if sum==lv then
        for sc in aux.Next(sg2) do
            Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
        Duel.SpecialSummonComplete()
    end
end
