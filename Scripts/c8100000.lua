--Lair of the Skull Archfiend
local s,id=GetID()
function s.initial_effect(c)
    --Activar Cartas M/T con "Summoned Skull" en su texto como Quick Effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_HAND,0)
    e1:SetTarget(s.qetarget)
    c:RegisterEffect(e1)
    
    --Los "Summoned Skull" no pueden ser destruidos por efectos del oponente
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.indestg)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    --Reducir ATK del oponente en batalla con "Summoned Skull"
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

-- **Permitir activar como Quick Effect si menciona "Summoned Skull"**
function s.qetarget(e,c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:ListsCode(70781052) -- 70781052 es "Summoned Skull"
end

-- **Hacer a "Summoned Skull" indestructible por efectos**
function s.indestg(e,c)
    return c:IsFaceup() and (c:IsCode(70781052) or c:IsOriginalCode(70781052))
end

-- **Reducir ATK del monstruo del oponente en batalla con "Summoned Skull"**
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttackTarget()
    return tc and tc:IsControler(1-tp) and Duel.GetAttacker():IsCode(70781052)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttackTarget()
    if not tc then return end
    local lv=Duel.GetAttacker():GetLevel()
    local rk=Duel.GetAttacker():GetRank()
    local atkdown=500*(lv+rk)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-atkdown)
    e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
    tc:RegisterEffect(e1)
end
