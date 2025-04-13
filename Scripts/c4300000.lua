--T.G. Armor Berserker
local s,id=GetID()
function s.initial_effect(c)
    --Invocación por Sincronía
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER),1,1,Synchro.NonTuner(nil),1,99)

    --Efecto 1: Invocar un T.G. Tuner desde el Cementerio
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    --Efecto 2: Atacar a todos los monstruos Invocados Especialmente
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ATTACK_ALL)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    --Efecto 3: Sincronizar desde el Cementerio en la Battle Phase
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(s.syncon)
    e3:SetCost(aux.bfgcost)
    e3:SetOperation(s.synop)
    c:RegisterEffect(e3)
end

--Condición de Invocación por Sincronía (Asegura que sea Synchro Summoned)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

--Seleccionar un T.G. Tuner en el Cementerio para invocar
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x27) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE)
    end
end

--Permitir atacar a todos los monstruos Invocados Especialmente
function s.atkval(e,c)
    return CATEGORY_SPECIAL_SUMMON
end

--Condición para Sincronizar en la Battle Phase
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase()
end

--Sincronizar usando solo monstruos en tu campo
function s.synop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,nil)
    if #g>0 then
        Duel.SynchroSummon(tp,g:GetFirst(),nil)
    end
end
