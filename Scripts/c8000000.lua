--Archfiend Skull of Thunderbolts
local s,id=GetID()
function s.initial_effect(c)
    -- Se trata como "Summoned Skull" en el campo y en el GY
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

    -- Invocación Especial desde la mano si controlas un "Archfiend" de Nivel/Rank 6 o mayor
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_SPSUMMON_PROC)
    e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e3:SetRange(LOCATION_HAND)
    e3:SetCondition(s.spcon)
    c:RegisterEffect(e3)

    -- Enviar 1 "Archfiend" al GY para Invocar "Summoned Skull"
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.sstg)
    e4:SetOperation(s.ssop)
    c:RegisterEffect(e4)

    -- Negar efecto destruyendo un "Archfiend" o "Summoned Skull"
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,1})
    e5:SetCondition(s.negcon)
    e5:SetCost(s.negcost)
    e5:SetTarget(s.negtg)
    e5:SetOperation(s.negop)
    c:RegisterEffect(e5)
end

-- **Condición de Invocación Especial desde la mano**
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,SET_ARCHFIEND),tp,LOCATION_MZONE,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

-- **Enviar "Archfiend" al GY para Invocar "Summoned Skull"**
function s.ssfilter(c)
    return c:IsSetCard(SET_ARCHFIEND) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_DECK,0,1,nil) 
        and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_DECK,0,1,nil,70781052)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_DECK,0,1,1,nil,70781052)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- **Condición de Negación (cuando el oponente activa un efecto)**
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and Duel.IsChainNegatable(ev)
end

-- **Costo para Negar (Destruir un "Archfiend" o "Summoned Skull")**
function s.negcostfilter(c)
    return c:IsFaceup() and (c:IsSetCard(SET_ARCHFIEND) or c:IsCode(70781052)) and c:IsDestructable()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Destroy(g,REASON_COST)
end

-- **Objetivo de Negación y Destrucción**
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end

-- **Negación y Destrucción**
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
        Duel.Destroy(g,REASON_EFFECT)
    end
end
