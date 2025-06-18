--Bonding CO
local s,id=GetID()
function s.initial_effect(c)
    --Send FIRE + WIND Dino to GY: Special Summon FIRE Sea Serpent from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    --Banish from GY to add WATER or WIND Dinosaur
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- EFFECT 1
function s.tgfilter1(c)
    return c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
end
function s.tgfilter2(c)
    return c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_SEASERPENT) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.tgfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,1,nil)
    if #g1==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,1,nil)
    if #g2==0 then return end
    local tg=Group.__add(g1,g2)
    if Duel.SendtoGrave(tg,REASON_EFFECT)==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- EFFECT 2
function s.thfilter(c)
    return c:IsRace(RACE_DINOSAUR) and (c:IsAttribute(ATTRIBUTE_WIND) or c:IsAttribute(ATTRIBUTE_WATER)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

