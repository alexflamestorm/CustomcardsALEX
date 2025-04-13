--Red-Eyes Volcano Field
local s,id=GetID()
function s.initial_effect(c)
    -- Activación como Field Spell
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Aumentar ATK/DEF y protección a Red-Eyes
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.atktg)
    e1:SetValue(600)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.atktg)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Discard para buscar Red-Eyes o Nivel 1 Dragón OSCURO
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1,id)
    e4:SetCost(s.thcost)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)

    -- Trigger al invocar monstruo Normal
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_SUMMON_SUCCESS)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1,{id,1})
    e5:SetCondition(s.ncon)
    e5:SetTarget(s.ntg)
    e5:SetOperation(s.nop)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e6)
end

-- Aplica solo a monstruos Red-Eyes
function s.atktg(e,c)
    return c:IsSetCard(0x3b) -- Red-Eyes
end

-- Costo: descartar 1 carta
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Buscar Red-Eyes o Level 1 DARK Dragon
function s.thfilter(c)
    return (c:IsSetCard(0x3b) or (c:IsLevel(1) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK)))
        and c:IsAbleToHand()
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

-- Condición: Normal Monster invocado por el jugador
function s.ncon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.normfilter,1,nil,tp)
end
function s.normfilter(c,tp)
    return c:IsControler(tp) and c:IsType(TYPE_NORMAL)
end

function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
end

function s.nop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    if opt==0 then
        local g=eg:Filter(s.normfilter,nil,tp)
        local atk=g:GetFirst():GetBaseAttack()//2
        Duel.Damage(1-tp,atk,REASON_EFFECT)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
    end
end
