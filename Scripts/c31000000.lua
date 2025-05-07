--Heroic Volition
local s,id=GetID()
function s.initial_effect(c)
    --Equip procedure
    aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x6f)) -- 0x6f es el Set ID de "Heroic"

    --Piercing & Unaffected
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_PIERCE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    --Once per turn activation restriction
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e3)
end

-- Efecto de inmunidad contra efectos del oponente
function s.efilter(e,re)
    return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
