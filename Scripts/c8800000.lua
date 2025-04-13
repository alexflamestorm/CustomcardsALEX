--Volcanic Infernal Doomsday
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Invocación Especial (Método Alternativo)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.sprcon)
    e1:SetOperation(s.sprop)
    c:RegisterEffect(e1)

    -- Protección contra destrucción por efecto del oponente
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetCondition(s.indcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Destruir todos los monstruos del oponente e infligir daño
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

-- **Invocación Especial desde el Extra Deck**
function s.sprfilter1(c)
    return c:IsCode(21362970) and c:IsAbleToRemove() -- "Volcanic Doomfire"
end
function s.sprfilter2(c)
    return c:IsRace(RACE_PYRO) and c:IsLevelAbove(6) and c:IsAbleToRemove()
end
function s.sprfilter3(c)
    return c:IsFaceup() and c:IsCode(21420702) and c:IsAbleToDeck() -- "Blaze Accelerator"
end
function s.sprcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.sprfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.sprfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.sprfilter3,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.sprfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,s.sprfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g3=Duel.SelectMatchingCard(tp,s.sprfilter3,tp,LOCATION_ONFIELD,0,1,1,nil)
    g1:Merge(g2)
    Duel.Remove(g1,POS_FACEUP,REASON_COST)
    Duel.SendtoDeck(g3,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

-- **Protección contra destrucción por efecto del oponente**
function s.indcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,21420702),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) -- "Blaze Accelerator"
end

-- **Destruir todo e infligir daño**
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
    if #g>0 then
        local ct=Duel.Destroy(g,REASON_EFFECT)
        Duel.Damage(1-tp,ct*500,REASON_EFFECT)
        -- No puede atacar este turno
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e:GetHandler():RegisterEffect(e1)
    end
end
