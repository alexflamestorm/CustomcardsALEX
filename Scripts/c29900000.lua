--Psi-Caller/Assault Mode
local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be Normal Summoned/Set
    c:EnableUnsummonable()
    -- Must be Special Summoned with Assault Mode Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCondition(function(e) return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),59822133) end)
    e0:SetValue(function(e,c,sump,sumtype,sumpos,targetp,se) return not (se and se:GetHandler():IsCode(80280737)) end)
    c:RegisterEffect(e0)

    -- Send 1 Synchro to summon its Assault Mode
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Revive Psi-Caller
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.revtg)
    e2:SetOperation(s.revop)
    c:RegisterEffect(e2)
end

-- Enviar Synchro para Invocar su Assault Mode
function s.assfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x301) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.synfilter(c,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.assfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.synextrafilter(c,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.assfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_MZONE,0,1,nil,tp)
    local b2=Duel.IsExistingMatchingCard(s.synextrafilter,tp,LOCATION_EXTRA,0,1,nil,tp)
        and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)<Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    if chk==0 then return b1 or b2 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_MZONE,0,1,nil,tp)
    local b2=Duel.IsExistingMatchingCard(s.synextrafilter,tp,LOCATION_EXTRA,0,1,nil,tp)
        and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)<Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    local opt=0
    if b1 and b2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then opt=0 else opt=1 end

    local loc=(opt==0) and LOCATION_MZONE or LOCATION_EXTRA
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,(opt==0) and s.synfilter or s.synextrafilter,tp,loc,0,1,1,nil,tp):GetFirst()
    if not tc then return end
    if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,function(c) return c:IsCode(tc:GetCode()+1) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end,
        tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
end

-- Revivir Psi-Caller
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsCode(psi_id) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,psi_id) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,Card.IsCode,tp,LOCATION_GRAVE,0,1,1,nil,psi_id)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Nothing extra
    end
end

-- ID de Psi-Caller
local psi_id=YOUR_PSI_CALLER_CARD_ID_HERE
