--Gravekeeper's Necromancer
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2e),2,2)

    -- Quick Effect: Set 1 Necrovalley S/T from hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- Tribute 1 "Gravekeeper's" to add from GY and Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.cost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Set effect
function s.setfilter(c)
    return c:IsSetCard(0x2e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.SSet(tp,tc)
        -- Allow activation this turn if Necrovalley is on field and it's a Trap
        if Duel.IsEnvironment(CARD_NECROVALLEY) and tc:IsType(TYPE_TRAP) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end

-- Tribute cost
function s.cfilter(c,tp)
    return c:IsSetCard(0x2e) and c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c,c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
    local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
    e:SetLabelObject(g:GetFirst())
    Duel.Release(g,REASON_COST)
end

-- Add target
function s.thfilter(c,rc)
    return c:IsSetCard(0x2e) and c:IsAbleToHand() and not c:IsCode(rc:GetCode())
end
function s.nvfilter(c)
    return c:IsSetCard(0x2e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=e:GetLabelObject()
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,rc) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE+LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetLabelObject()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,rc)
    if #g1==0 then return end
    if Duel.SendtoHand(g1,nil,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.nvfilter,tp,LOCATION_DECK,0,1,nil) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g2=Duel.SelectMatchingCard(tp,s.nvfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g2>0 then
            Duel.SendtoHand(g2,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g2)
            Duel.BreakEffect()
            Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
        end
    end
end

