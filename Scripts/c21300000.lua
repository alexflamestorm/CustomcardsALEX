-- Millennium Kuriboh
local s,id=GetID()
function s.initial_effect(c)
    -- Substitute for "Forbidden" cards in hand, field, or GY
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
    e0:SetValue(10000010) -- placeholder code; change depending on what "Forbidden" refers to
    c:RegisterEffect(e0)

    -- Discard to end Battle Phase and add a card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.bpcon)
    e1:SetCost(s.bpcost)
    e1:SetOperation(s.bpop)
    c:RegisterEffect(e1)

    -- GY: revive high-Level "Exodia" or "Millennium" monsters if they left the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Substitute for "Forbidden" cards is handled via naming above

-- e1: End Battle Phase + search
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsControler(1-tp)
end
function s.bpcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
    return c:IsAbleToHand() and (
        c:IsSetCard(0x40) or -- Exodia
        c:IsSetCard(0x231) or -- Millennium
        c:IsSetCard(0x4f) -- Forbidden One
    )
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.EndBattlePhase() then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- e2: GY revive when high-Level Exodia or Millennium monster leaves field
function s.spfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsLevelAbove(10)
        and (c:IsSetCard(0x40) or c:IsSetCard(0x231))
        and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.spfilter,nil,tp)
    if chk==0 then return #g>0 end
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not Duel.Remove(c,POS_FACEUP,REASON_EFFECT) then return end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    for tc in g:Iter() do
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            -- Optional summon customization
        end
    end
    Duel.SpecialSummonComplete()
end
