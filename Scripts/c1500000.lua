-- Scourge Left Arm of the Forbidden One
local s,id=GetID()
function s.initial_effect(c)
    -- Nombre tratado como "Left Arm of the Forbidden One" en la mano o GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetValue(44519536) -- Código de "Left Arm of the Forbidden One"
    c:RegisterEffect(e1)

    -- Descarta para buscar "Left Arm of the Forbidden One" o "Exxod" Spell/Trap
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Protección de batalla para "Exodia" y "Exodius" mientras está en el GY
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.prottg)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

-- COSTO: Descarta esta carta
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- FILTRO: Buscar "Left Arm of the Forbidden One"
function s.thfilter1(c)
    return c:IsCode(44519536) and c:IsAbleToHand()
end

-- FILTRO: Buscar "Exxod" Spell/Trap
function s.thfilter2(c)
    return c:IsSetCard(0x40) and c:IsSpellTrap() and c:IsAbleToHand()
end

-- OBJETIVO: Buscar "Left Arm of the Forbidden One" o "Exxod" Spell/Trap
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local hasLeftArm=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
    local hasExxod=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
    local hasLeftArmInHand=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,44519536)

    if chk==0 then return hasLeftArm or (hasExxod and hasLeftArmInHand) end
end

-- OPERACIÓN: Buscar la carta elegida
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local hasLeftArm=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
    local hasExxod=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
    local hasLeftArmInHand=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,44519536)

    local option=0
    if hasLeftArm and (hasExxod and hasLeftArmInHand) then
        option=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)) -- 0: Left Arm, 1: Exxod
    elseif hasLeftArm then
        option=0
    elseif hasExxod and hasLeftArmInHand then
        option=1
    else
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=nil
    if option==0 then
        g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    else
        g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
    end

    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- FILTRO: Protección para "Exodia" y "Exodius"
function s.prottg(e,c)
    return c:IsCode(12600382) or c:IsSetCard(0x40) -- "Exodius the Ultimate Forbidden Lord" y "Exodia"
end
