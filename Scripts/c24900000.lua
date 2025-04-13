-- Mind Draining Archfiend
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHIC),1,1,aux.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    -- Cannot attack directly
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    c:RegisterEffect(e0)

    -- Piercing
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e1)

    -- Gain ATK when LP is paid
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PAY_LPCOST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Substitute LP cost for Psychic monster effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_LPCOST_CHANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.lpcosttg)
    e3:SetValue(s.lpcostval)
    c:RegisterEffect(e3)
end

-- ATK gain when LP is paid
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() and ev>0 then
        local atk=ev
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- Only apply to Psychic monster effects where LP would be paid
function s.lpcosttg(e,c)
    return c:IsRace(RACE_PSYCHIC)
end
function s.lpcostval(e,re,rp,val)
    local c=e:GetHandler()
    if c:IsFaceup() and c:GetAttack()>=val then
        -- Lose ATK instead of paying LP
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
        return 0
    end
    return val
end
