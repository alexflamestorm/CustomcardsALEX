-- Nameless Pharaoh
local s,id=GetID()
function s.initial_effect(c)
    -- Triple Tribute for Divine Beast
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRIBUTE_LIMIT)
    e0:SetValue(s.trilimit)
    c:RegisterEffect(e0)

    -- Add 1 Egyptian God or related card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Quick Tribute Summon for Level 10 ? DEF or 4000 DEF
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetTarget(s.qstg)
    e3:SetOperation(s.qsop)
    c:RegisterEffect(e3)
end

-- Triple Tribute
function s.trilimit(e,c)
    return c:IsRace(RACE_DIVINE) and c:IsAttribute(ATTRIBUTE_DIVINE)
end

-- Filter for God cards or those that mention them
function s.thfilter(c)
    return (c:IsCode(10000020,10000010,10000000) or c:ListsCode(10000020,10000010,10000000))
        and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Quick Tribute Summon a Level 10 with ? or 4000 DEF
function s.qsfilter(c)
    return c:IsLevel(10) and (c:GetBaseDef()==4000 or c:GetBaseDef()==-2) and c:IsSummonable(true,nil)
end
function s.qstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.qsfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.qsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.qsfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.Summon(tp,g:GetFirst(),true,nil)
    end
end

