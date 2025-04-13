-- Advanced Crystal Beast Citrine Chimera
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Debe ser Invocado por Fusión o Tributando 2 "Crystal Beast" con diferentes Atributos
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x1045),aux.FilterBoolFunction(Card.IsSetCard,0x1045))
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(aux.fuslimit)
    c:RegisterEffect(e1)

    -- Tratar su nombre como "Advanced Dark" en el campo
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_CODE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(100000114) -- ID ficticio de "Advanced Dark"
    c:RegisterEffect(e2)

    -- Enviar al GY si "Advanced Dark" no está en el campo
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.gycon)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

-- **Verifica si "Advanced Dark" no está en el campo**
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,100000114),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

-- **Envía la carta al GY si "Advanced Dark" no está en el campo**
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_MZONE) then return end
    Duel.SendtoGrave(c,REASON_EFFECT)
end

