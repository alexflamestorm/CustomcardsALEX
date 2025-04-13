-- Darklord's Forbidden Lance
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Send 1 Darklord from Deck to GY, gain ATK
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.handcon)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- GY effect: Triggered by Darklord targeting
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.drawcon)
    e2:SetOperation(s.drawop)
    c:RegisterEffect(e2)
end

-- Allow activation from hand if 2 "Darklord" with different levels
function s.handcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,0xef)
    return not e:GetHandler():IsLocation(LOCATION_HAND) or g:CheckSubGroup(aux.dlvcheck,2,2)
end

-- Filter and Target
function s.tgfilter(c)
    return c:IsSetCard(0xef) and c:IsMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        local atk=g:GetFirst():GetAttack()
        local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
        for tc in dg:Iter() do
            if tc:IsSetCard(0xef) and tc:IsMonster() and atk>0 then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(atk)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e1)
            end
        end
    end
end

-- GY Trigger Condition
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return re and rc:IsSetCard(0xef) and rc:IsControler(tp) and e:GetHandler():IsRelateToEffect(re)
end

-- Draw and reveal
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    local dc=Duel.GetOperatedGroup():GetFirst()
    Duel.ConfirmCards(1-tp,dc)
    if dc:IsSetCard(0xef) and dc:IsDiscardable(REASON_EFFECT) then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.SendtoGrave(dc,REASON_EFFECT+REASON_DISCARD)
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
    Duel.ShuffleHand(tp)
end
