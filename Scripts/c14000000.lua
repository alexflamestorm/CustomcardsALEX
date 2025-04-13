-- Elemental HERO Shade Escuridao
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Debe ser Invocado por Fusión
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x8),aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK))

    -- Tratar su nombre como "Elemental HERO Escuridao" en el campo y GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(29095552) -- ID de "Elemental HERO Escuridao"
    c:RegisterEffect(e1)

    -- Niega efectos activados en el Cementerio
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_GRAVE)
    c:RegisterEffect(e2)

    -- Gana 400 ATK por cada monstruo en tu Cementerio
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)

    -- Ataque penetrante + segundo ataque si inflige daño
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_BATTLE_DAMAGE)
    e5:SetCondition(s.atcon)
    e5:SetOperation(s.atop)
    c:RegisterEffect(e5)
end

-- **Cálculo del ATK adicional**
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*400
end

-- **Condición para el segundo ataque**
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp
end

-- **Realizar un segundo ataque**
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToBattle() then
        Duel.ChainAttack()
    end
end

