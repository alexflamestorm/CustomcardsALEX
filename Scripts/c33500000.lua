--The Legendary Orca
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon to opponent's field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Special Summon to your field and change Level
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

    -- Add WATER Warrior
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCountLimit(1,id+2)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end

-- Special Summon to opponent's field
function s.umifilter(c)
    return c:IsFaceup() and c:IsCode(22702055) -- Umi
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and 2 or 1
    if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.CheckReleaseGroup(1-tp,nil,ct,nil) end
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and 2 or 1
    local g=Duel.SelectReleaseGroup(1-tp,Card.IsReleasable,ct,ct,nil)
    if #g>0 and Duel.Release(g,REASON_COST)>0 then
        Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
    end
end

-- Special Summon from hand to your field & adjust Level
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_ONFIELD,0,1,nil)
        or Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,0,2,nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    return chk==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,0,1,1,nil)
        if #g>0 then
            local tc=g:GetFirst()
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetValue(7)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end

-- Search WATER Warrior
function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
