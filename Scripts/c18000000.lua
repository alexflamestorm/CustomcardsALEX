-- Nordic Horror - Ouroboros Break
local s,id=GetID()
function s.initial_effect(c)
    -- Activar seleccionando un monstruo del oponente y tomar control
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Destruir esta carta cuando el monstruo deje el campo y buscar "Jormungardr the Nordic Serpent"
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.descon)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- Comprobar si controlas un "Aesir" y seleccionar un monstruo del oponente
function s.aesirfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x43)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingMatchingCard(s.aesirfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

-- Tomar control del monstruo sin activar sus efectos
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        Duel.GetControl(tc,tp,PHASE_END,1)

        -- Negar los efectos del monstruo tomado
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_TRIGGER)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)

        -- Asociar la carta a ese monstruo
        c:SetCardTarget(tc)
    end
end

-- Condición: si el monstruo controlado deja el campo
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end

-- Destruir la carta y buscar "Jormungardr the Nordic Serpent"
function s.thfilter(c)
    return c:IsCode(100000153) and c:IsAbleToHand() -- Código de "Jormungardr the Nordic Serpent"
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Destroy(c,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

