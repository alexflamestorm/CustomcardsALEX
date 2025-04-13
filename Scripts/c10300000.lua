-- Infernoid Samael
local s,id=GetID()
function s.initial_effect(c)
 -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,1,1)

    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x9b),1,2) -- 2 monstruos, incluyendo 1 "Infernoid"

    -- Efecto 1: Molino de cartas al invocar por Enlace
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.deckcon)
    e1:SetTarget(s.decktg)
    e1:SetOperation(s.deckop)
    c:RegisterEffect(e1)

    -- Efecto 2: Enviar "Infernoid" en vez de tributar
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_EXTRA_RELEASE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetCondition(s.tributecon)
    e2:SetValue(s.tributeval)
    c:RegisterEffect(e2)

    -- Efecto 3: Añadir carta "Void"
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.voidcost)
    e3:SetTarget(s.voidtg)
    e3:SetOperation(s.voidop)
    c:RegisterEffect(e3)
end

-- **Efecto 1: Moler cartas al invocar por Enlace**
function s.deckcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
    if chk==0 then return ct>0 end
    Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end

function s.deckop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
    if ct>0 then
        Duel.DiscardDeck(tp,ct,REASON_EFFECT)
    end
end

-- **Efecto 2: Sustituir tributo de "Infernoid"**
function s.tributecon(e)
    return e:GetHandler():GetLinkedGroup():IsExists(Card.IsSetCard,1,nil,0x9b)
end

function s.tributeval(e,re,rp)
    return re and re:GetHandler():IsSetCard(0x9b)
end

-- **Efecto 3: Añadir "Void" Spell/Trap**
function s.voidcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
    Duel.Release(g,REASON_COST)
end

function s.voidfilter(c)
    return c:IsSetCard(0xb9) and c:IsAbleToHand()
end

function s.voidtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.voidfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.voidop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.voidfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
