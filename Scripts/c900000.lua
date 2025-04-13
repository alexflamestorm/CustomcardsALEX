--Flamvell Ignite
local s,id=GetID()
function s.initial_effect(c)
    -- When activated: Add or Send 1 Pyro with 200 DEF
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Effect while Continuous on field - Trigger on summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.condition)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

-- Activation effect: Add/Send Pyro with 200 DEF
function s.pyrofilter(c)
    return c:IsRace(RACE_PYRO) and c:IsDefense(200) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPTION)
    local g=Duel.SelectMatchingCard(tp,s.pyrofilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    else
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

-- Summon-triggered effect
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsFaceup,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=eg:GetFirst()
    if chk==0 then return true end
    e:SetLabelObject(tc)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if tc:IsRace(RACE_PYRO) then
        Duel.Damage(tp,500,REASON_EFFECT)
        Duel.Damage(1-tp,500,REASON_EFFECT)
    else
        local count=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)+1
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_GRAVE,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=g:Select(tp,1,math.min(count,#g),nil)
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        end
    end
end
