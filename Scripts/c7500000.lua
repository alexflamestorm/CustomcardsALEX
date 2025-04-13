--Archfiend Skull Overlord of Doom
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,70781052,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND))

    -- Se trata como "Summoned Skull" y "Archfiend"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(70781052) -- Código de "Summoned Skull"
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_ADD_SETCODE)
    e2:SetValue(SET_ARCHFIEND)
    c:RegisterEffect(e2)

    -- Destruir todos los monstruos no-Demonio cuando es Invocado Especialmente
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- Buff de ATK y banish de monstruos Nivel 4 o menor si solo controlas Demonios
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetCondition(s.atkcon)
    e4:SetValue(500)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(0,LOCATION_MZONE)
    e5:SetCondition(s.atkcon)
    e5:SetTarget(s.rmtg)
    e5:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e5)
end

-- **Condición para destruir monstruos al ser Invocado Especialmente**
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_FIEND),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(aux.NOT(aux.FilterFaceupFunction(Card.IsRace,RACE_FIEND)),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.NOT(aux.FilterFaceupFunction(Card.IsRace,RACE_FIEND)),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    Duel.Destroy(g,REASON_EFFECT)
end

-- **Condición para aplicar los efectos de buff y banish**
function s.atkcon(e)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_FIEND),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.rmtg(e,c)
    return c:IsLevelBelow(4)
end
