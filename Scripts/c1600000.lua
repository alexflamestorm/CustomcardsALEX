-- Black Luster Soldier - Super Knight
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Ritual Summon con "Super Soldier Synthesis"
    local e1=aux.AddRitualProcEqual(c,aux.FilterBoolFunction(Card.IsCode,46052429)) -- Código de "Super Soldier Synthesis"

    -- Protección contra destrucción si fue Invocado por Ritual
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetCondition(s.ritcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e3)

    -- Revelar en la mano para buscar 1 carta
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_HAND)
    e4:SetCountLimit(1,{id,1})
    e4:SetCost(s.thcost)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)

    -- Daño si no se invoca por Ritual después de buscar
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetCountLimit(1)
    e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e5:SetLabelObject(e4)
    e5:SetCondition(s.dmgcon)
    e5:SetOperation(s.dmgop)
    Duel.RegisterEffect(e5,0)
end

-- Condición de protección por Ritual
function s.ritcon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

-- COSTO: Revelar en la mano
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end

-- FILTRO: Buscar una carta válida
function s.thfilter(c)
    return c:IsType(TYPE_RITUAL) or c:IsCode(73580471, 14735698) and c:IsAbleToHand() -- Beginning Knight & Evening Twilight Knight
end

-- OBJETIVO: Seleccionar carta para buscar
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- OPERACIÓN: Buscar la carta y activar el efecto de daño
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        -- Registrar que se activó el efecto
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end

-- CONDICIÓN: Si no Ritual Summon después de buscar
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject():GetHandler()
    return c:GetFlagEffect(id)~=0 and not Duel.IsExistingMatchingCard(Card.IsSummonType,tp,LOCATION_MZONE,0,1,nil,SUMMON_TYPE_RITUAL)
end

-- OPERACIÓN: Infligir 2000 de daño
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)
    Duel.Damage(tp,2000,REASON_EFFECT)
end

