--Sangenpai Puncture Dragion
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon rule (banish 1 Tuner + 1 non-Tuner Dragon)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    --SS FIRE Dragon from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon2)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop2)
    c:RegisterEffect(e1)

    --SS from GY after 3+ attacks (once per Duel)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.gycon)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)
end

-- Custom Special Summon from Extra Deck
function s.tunfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
function s.nontunfilter(c)
    return c:IsRace(RACE_DRAGON) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.tunfilter,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.nontunfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.tunfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,s.nontunfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    g1:Merge(g2)
    Duel.Remove(g1,POS_FACEUP,REASON_COST)
end

-- On Summon: Special Summon FIRE Dragon
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+SUMMON_TYPE_SYNCHRO)
        or e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.filter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and not Duel.IsExistingMatchingCard(s.chk,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.chk(c,code)
    return c:IsCode(code)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Revival from GY if 3+ attacks declared this turn
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
        and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)>=3
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
