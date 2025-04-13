--T.G. Armed Majidae
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1)

    --Tratar como Tuner para una Invocación de Sincronía "T.G."
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.tunercon)
    e1:SetValue(TYPE_TUNER)
    c:RegisterEffect(e1)

    --Invocar Especialmente 1 "T.G." no-Tuner desde el Deck
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    --Usar un monstruo del oponente para una Invocación de Sincronía "T.G." y desterrar esta carta
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(s.syncon)
    e3:SetOperation(s.synop)
    c:RegisterEffect(e3)
end

--Condición: Si se está haciendo una Invocación de Sincronía de un monstruo "T.G."
function s.tunercon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end

--Descartar 1 carta como costo para Invocar un "T.G." no-Tuner desde el Deck
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_COST+REASON_DISCARD)
end

--Buscar un "T.G." no-Tuner en el Deck para Invocar Especialmente
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x27) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Usar un monstruo del oponente para una Invocación de Sincronía "T.G."
function s.synfilter(c,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x27) and c:GetSummonPlayer()==tp
end
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.synfilter,1,nil,tp)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        Duel.SendtoGrave(g,REASON_EFFECT)
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
    end
end
