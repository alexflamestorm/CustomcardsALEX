--Sacred Temple of Necrovalley
local s,id=GetID()
function s.initial_effect(c)
    -- This card's name is always treated as "Necrovalley"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_FZONE)
    e0:SetValue(CARD_NECROVALLEY)
    c:RegisterEffect(e0)

    -- Add 1 Gravekeeper's card, then discard 1
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Tribute-less summon for Level 5+ Gravekeeper's monsters
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SUMMON_PROC)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_HAND,0)
    e2:SetCondition(s.ntcon)
    e2:SetTarget(s.nttg)
    c:RegisterEffect(e2)

    -- End Phase: Replace itself with another Necrovalley
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOFIELD)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.nvcon)
    e3:SetOperation(s.nvop)
    e3:SetCountLimit(1,id)
    c:RegisterEffect(e3)
end

-- e1: On activation, search 1 Gravekeeper's card, then discard 1
function s.thfilter(c)
    return c:IsSetCard(0x2e) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
        Duel.BreakEffect()
        Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
    end
end

-- e2: Tribute-less Summon for Level 5+ Gravekeeper's
function s.ntcon(e,c,minc)
    if c==nil then return true end
    return minc==0 and c:IsLevelAbove(5) and c:IsSetCard(0x2e)
end
function s.nttg(e,c)
    return c:IsSetCard(0x2e)
end

-- e3: During End Phase, replace this with another "Necrovalley"
function s.nvcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x2e)
end
function s.nvfilter(c)
    return c:IsCode(CARD_NECROVALLEY) and not c:IsCode(id) and c:IsSSetable()
end
function s.nvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.nvfilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end

