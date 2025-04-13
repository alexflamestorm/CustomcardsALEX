-- Vylon Ómicron
local s,id=GetID()
function s.initial_effect(c)
    -- No pagar LP para activar efectos de monstruos "Vylon"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_LPCOST_CHANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetValue(s.lpcost)
    c:RegisterEffect(e1)

    -- Negar Magia/Trampa enviando 1 carta de Equipo al Cementerio
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-- No pagar LP para efectos de monstruos "Vylon"
function s.lpcost(e,re,rp,val)
    if re and re:GetHandler():IsSetCard(0x30) and re:IsActiveType(TYPE_MONSTER) then
        return 0
    else
        return val
    end
end

-- Condición para negar una Magia/Trampa
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

-- Costo: Enviar 1 carta de Equipo equipada a este monstruo al Cementerio
function s.eqfilter(c,tp)
    return c:IsType(TYPE_EQUIP) and c:IsEquippedTo(e:GetHandler()) and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_SZONE,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

-- Objetivo de la negación
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Negar y luego Invocar Especialmente un "Vylon" Tuner
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x30) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
            -- Enviarlo al Cementerio durante la End Phase
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetCountLimit(1)
            e1:SetLabelObject(tc)
            e1:SetOperation(s.tgop)
            Duel.RegisterEffect(e1,tp)
        end
    end
end

-- Enviar al Cementerio el monstruo invocado durante la End Phase
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsLocation(LOCATION_MZONE) then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end
