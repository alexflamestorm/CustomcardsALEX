-- Blue-Eyes Prime Chaos Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddRitualProcEqual(c,s.ritualfil,nil,nil,nil,nil,true)

    -- Battle Phase Immunity if Blue-Eyes used
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.bpcon)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- Piercing x N
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_PIERCE)
    e3:SetValue(s.pierceval)
    c:RegisterEffect(e3)

    -- Special Summon 2 Level 1 LIGHT Tuners after battle
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- Can be any Level multiple of 8
function s.ritualfil(c)
    return c:IsCode(89631139) or c:IsSetCard(0xdd)
end

-- Save number of Blue-Eyes used
function s.materialcheck(e,c)
    local g=c:GetMaterial()
    local ct=g:FilterCount(Card.IsCode,nil,89631139)
    e:GetHandler():SetHint(CHINT_NUMBER,ct)
    e:GetHandler():SetFlagEffectLabel(id,ct)
end

-- Battle Phase only immunity
function s.bpcon(e)
    local ph=Duel.GetCurrentPhase()
    local c=e:GetHandler()
    return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and c:GetFlagEffectLabel(id)>0
end
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Piercing value
function s.pierceval(e,c)
    local ct=e:GetHandler():GetFlagEffectLabel(id)
    return ct and ct>0 and ct or 1
end

-- After battle phase
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetBattledGroupCount()>0
end
function s.spfilter(c)
    return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER)
        and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,2,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if #g<2 then return end
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
    if #sg==2 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
