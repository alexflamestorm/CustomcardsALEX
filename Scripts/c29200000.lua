--Spirit Dark Message "I"
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    -- Treated as "Spirit Message 'I'"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetValue(31893528) -- Card ID of "Spirit Message 'I'"
    c:RegisterEffect(e0)

    -- Protect Destiny Board and Spirit Messages from destruction
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(s.prottg)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Place Spirit Message from hand or GY if Destiny Board places one
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CUSTOM+502)
    e3:SetRange(LOCATION_SZONE)
    e3:SetOperation(s.msgop)
    c:RegisterEffect(e3)

    -- Search if Destiny Board is not controlled
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.thcon)
    e4:SetCost(s.thcost)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    e4:SetCountLimit(1,id)
    c:RegisterEffect(e4)
end

-- Target protection: Destiny Board or Spirit Message
function s.prottg(e,c)
    return c:IsFaceup() and (c:IsCode(94212438) or (c:IsSetCard(0x4e)))
end

-- Custom event triggered externally when Destiny Board places a Spirit Message
-- This is illustrative: would be triggered by Destiny Board's code
function s.msgop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,94212438) then return end
    local g=Duel.GetMatchingGroup(s.msgfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
    if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
function s.msgfilter(c)
    return c:IsSetCard(0x4e) and c:IsType(TYPE_SPELL) and not c:IsForbidden()
end

-- Condition: No Destiny Board on field
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,94212438)
end

-- Cost: Send this card from S/T zone to GY
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- Search Dark Spirit’s Mastery and a Level 8 Fiend
function s.thfilter1(c)
    return c:IsCode(43813459) and c:IsAbleToHand()
end
function s.thfilter2(c)
    return c:IsRace(RACE_FIEND) and c:IsLevel(8) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g1==0 then return end
    local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g2==0 then return end
    g1:Merge(g2)
    Duel.SendtoHand(g1,tp,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g1)
end
