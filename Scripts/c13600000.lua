-- Elemental HERO Storming Great Tornado
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Debe ser Invocado por Fusión
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x8),aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))

    -- Tratar su nombre como "Elemental HERO Great Tornado" en el campo y GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(61204971) -- ID de "Elemental HERO Great Tornado"
    c:RegisterEffect(e1)

    -- Negar efectos de todos los monstruos del oponente al ser Invocado
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetOperation(s.negateop)
    c:RegisterEffect(e2)

    -- Halve ATK/DEF en batalla de un "HERO"
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DAMAGE_CALCULATING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.halfcon)
    e3:SetOperation(s.halfop)
    c:RegisterEffect(e3)
end

-- **Negar efectos de los monstruos del oponente al Invocarse**
function s.negateop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_MONSTER),tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        local tc=g:GetFirst()
        while tc do
            -- Negar efectos
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            -- No poder activar efectos en respuesta
            Duel.SetChainLimitTillChainEnd(aux.FALSE)
            tc=g:GetNext()
        end
    end
end

-- **Condición: Un "HERO" está en batalla**
function s.halfcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttacker()
    local bc=Duel.GetAttackTarget()
    if not bc then return false end
    if tc:IsControler(1-tp) then tc,bc=bc,tc end
    return tc and tc:IsFaceup() and tc:IsSetCard(0x8) and bc:IsFaceup()
end

-- **Efecto: Reducir ATK/DEF a la mitad**
function s.halfop(e,tp,eg,ep,ev,re,r,rp)
    local bc=Duel.GetAttackTarget()
    if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(math.ceil(bc:GetAttack()/2))
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
        bc:RegisterEffect(e1)

        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        e2:SetValue(math.ceil(bc:GetDefense()/2))
        bc:RegisterEffect(e2)
    end
end

