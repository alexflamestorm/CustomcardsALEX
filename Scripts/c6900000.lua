--Exodia's Horcruxes
local s,id=GetID()
function s.initial_effect(c)
    c:Activate()

    -- Se trata como "Exodd" y "Obliterate"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_SETCODE)
    e1:SetRange(LOCATION_FZONE+LOCATION_GRAVE+LOCATION_ONFIELD)
    e1:SetValue(0x203) -- "Exodd" y "Obliterate"
    c:RegisterEffect(e1)

    -- Negar activación de Magia/Trampa
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- Monstruos Nivel 10 OSCURIDAD Lanzador de Conjuros no son afectados por efectos del oponente
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.immtg)
    e3:SetValue(s.immval)
    c:RegisterEffect(e3)

    -- Descartar 1 carta obligatorio en End Phase o enviar esta carta al GY
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.discon)
    e4:SetOperation(s.disop)
    c:RegisterEffect(e4)
end

-- **Negar Magia/Trampa**
function s.cfilter(c)
    return (c:IsSetCard(0xde) or c:IsSetCard(0x40)) and c:IsMonster()
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
        and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(re:GetHandler(),REASON_EFFECT)
    end
end

-- **Inmunidad para Nivel 10 OSCURIDAD Lanzador de Conjuros**
function s.immtg(e,c)
    return c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER)
end

function s.immval(e,re)
    return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end

-- **Descartar 1 carta obligatorio o enviar esta carta al GY**
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
        Duel.SendtoGrave(g,REASON_DISCARD+REASON_EFFECT)
    else
        Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
    end
end
