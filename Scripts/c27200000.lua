--Gravekeeper's Avatar of Apep
local s,id=GetID()
function s.initial_effect(c)
    --Flip: Discard 1 random card from opponent
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.distg)
    e1:SetOperation(s.disop)
    c:RegisterEffect(e1)

    --Sent to GY: Special Summon LV4 or lower Gravekeeper's/Flip in face-down DEF
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    --Quick: Book of Moon both sides
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetHintTiming(0,TIMING_END_PHASE)
    e3:SetTarget(s.postg)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)
end

--Flip: Random discard
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
    if #g==0 then return end
    local sg=g:RandomSelect(1-tp,1)
    Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end

--Send to GY: Reborn Level 4 or lower Gravekeeper’s or Flip in face-down DEF
function s.spfilter(c,e,tp)
    return (c:IsSetCard(0x2e) or c:IsType(TYPE_FLIP)) and c:IsLevelBelow(4)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
        Duel.ConfirmCards(1-tp,g)
    end
end

--Quick: Flip monsters face-down
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingTarget(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end
