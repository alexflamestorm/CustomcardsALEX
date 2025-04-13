-- Mementotlan Fusionist
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.matfilter,2,true)

    -- Special Summon self if sent from Extra Deck to GY or banished
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_REMOVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.spcon2)
    c:RegisterEffect(e2)

    -- Flip all banished cards face-up on Fusion Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.flipcon)
    e3:SetOperation(s.flipop)
    c:RegisterEffect(e3)
end

-- Fusion material must be 2 different "Memento" monsters
function s.matfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0x1f49)
end

-- Was banished
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
-- Was sent to GY from Extra Deck
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_EXTRA) and r==REASON_EFFECT+REASON_MATERIAL+REASON_FUSION
end

-- Special Summon self from Extra Deck
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,nil,e:GetHandler())>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 then
        Duel.SpecialSummon(c,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
        c:CompleteProcedure()
    end
end

-- Flip banished cards face-up on Fusion Summon
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    if #g>0 then
        Duel.ConfirmCards(tp,g)
    end
end
