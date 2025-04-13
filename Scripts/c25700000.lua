-- Sanctuary of The Gods
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Protection effect
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.prottg)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    -- Special Summon at Battle Phase Start
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- On activation: search Nameless Pharaoh or DIVINE monster
function s.filter(c)
    return (c:IsCode(100000244) or c:IsRace(RACE_DIVINE)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- Immunity target: Tribute Summoned Egyptian Gods
function s.prottg(e,c)
    return c:IsFaceup() and c:IsRace(RACE_DIVINE) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
        and (c:IsCode(10000000) or c:IsCode(10000010) or c:IsCode(10000020))
end

function s.efilter(e,re)
    return re:IsActivated() and not re:GetHandler():IsRace(RACE_DIVINE) and (re:IsActiveType(TYPE_MONSTER) or re:IsActiveType(TYPE_SPELL+TYPE_TRAP))
end

function s.filter(c)
    return (c:IsCode(100000244) or c:IsRace(RACE_DIVINE)) and c:IsAbleToHand()
end

-- Special Summon from hand at Battle Phase
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_DIVINE) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
end
