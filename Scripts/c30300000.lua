--Heroic Challenger Colosseum (Custom)
local s,id=GetID()
function s.initial_effect(c)
    --Activación: Añadir 1 carta "Heroic"
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- No daño mientras controles un monstruo "Heroic"
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(1,0)
    e2:SetCondition(s.damcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e3)

    -- Protección de XYZ con materiales "Heroic"
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.xyztg)
    e4:SetValue(aux.tgoval)
    c:RegisterEffect(e4)

    -- GY effect: Doble daño si tienes 500 LP o menos
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1,{id,1})
    e5:SetCondition(s.dmgcon)
    e5:SetCost(aux.bfgcost)
    e5:SetTarget(s.dmgtg)
    e5:SetOperation(s.dmgop)
    c:RegisterEffect(e5)
end

-- Buscar 1 "Heroic"
function s.filter(c)
    return c:IsSetCard(0x6f) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Condición de no daño
function s.damcon(e)
    return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,0x6f)
end

-- Protección a XYZ con materiales "Heroic"
function s.xyztg(e,c)
    if not c:IsType(TYPE_XYZ) then return false end
    local og=c:GetOverlayGroup()
    return og:IsExists(Card.IsSetCard,1,nil,0x6f)
end

-- Condición de LP
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(tp)<=500
end

-- Seleccionar objetivo para doble daño
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingTarget(aux.FilterFaceup(Card.IsSetCard,0x6f),tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,aux.FilterFaceup(Card.IsSetCard,0x6f),tp,LOCATION_MZONE,0,1,1,nil)
end

-- Aplicar efecto de daño doble
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(aux.ChangeBattleDamageDouble)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end
