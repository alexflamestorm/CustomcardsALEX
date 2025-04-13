--Morphtronic Roomba
local s,id=GetID()
function s.initial_effect(c)
    --Efecto de Posición de Ataque: Destruir monstruos en la misma columna
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    --Efecto de Posición de Defensa: Destruir M/T en la misma columna
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.defcon)
    e2:SetTarget(s.deftg)
    e2:SetOperation(s.defop)
    e2:SetCountLimit(1,id+1)
    c:RegisterEffect(e2)
end

--Condición para efecto en Posición de Ataque
function s.atkcon(e)
    return e:GetHandler():IsPosition(POS_ATTACK)
end

--Condición para efecto en Posición de Defensa
function s.defcon(e)
    return e:GetHandler():IsPosition(POS_DEFENSE)
end

--Filtrar monstruos "Morphtronic" con diferentes niveles
function s.morphfilter(c,lvlist)
    return c:IsFaceup() and c:IsSetCard(0x26) and not lvlist[c:GetLevel()]
end

--Objetivo del efecto en Posición de Ataque
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.morphfilter,tp,LOCATION_MZONE,0,nil,{})
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,LOCATION_MZONE)
end

--Operación del efecto en Posición de Ataque
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.morphfilter,tp,LOCATION_MZONE,0,nil,{})
    local desGroup=Group.CreateGroup()
    for tc in aux.Next(g) do
        local col=tc:GetColumnGroup()
        desGroup:Merge(col:Filter(Card.IsControler,nil,1-tp))
    end
    if #desGroup>0 then
        Duel.Destroy(desGroup,REASON_EFFECT)
    end
end

--Objetivo del efecto en Posición de Defensa
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.morphfilter,tp,LOCATION_MZONE,0,nil,{})
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,LOCATION_SZONE)
end

--Operación del efecto en Posición de Defensa
function s.defop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.morphfilter,tp,LOCATION_MZONE,0,nil,{})
    local desGroup=Group.CreateGroup()
    for tc in aux.Next(g) do
        local col=tc:GetColumnGroup()
        desGroup:Merge(col:Filter(Card.IsControler,nil,1-tp))
    end
    if #desGroup>0 then
        Duel.Destroy(desGroup,REASON_EFFECT)
    end
end