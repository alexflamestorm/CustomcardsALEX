--T.G. Progress Warrior
local s,id=GetID()
function s.initial_effect(c)
    --Requisitos de Invocación por Sincronía
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_MONSTER),1,99)

    --Efecto 1: Reducir el ATK de los monstruos del oponente
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    --Efecto 2: Negar efectos de monstruo y desterrar temporalmente
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

--Reducir el ATK de los monstruos del oponente según la cantidad de "T.G." que controlas
function s.tgfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x27)
end
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil) * -100
end

--Condición para negar efectos de monstruo
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end

--Objetivo del efecto de negación
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_MZONE)
end

--Negar y desterrar un monstruo hasta la End Phase del próximo turno
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
            --Devolver el monstruo en la End Phase del siguiente turno
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetReset(RESET_PHASE+PHASE_END,2)
            e1:SetLabelObject(g:GetFirst())
            e1:SetCountLimit(1)
            e1:SetOperation(s.retop)
            Duel.RegisterEffect(e1,tp)
        end
    end
end

--Devolver el monstruo desterrado a su campo
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsFaceup() and tc:IsLocation(LOCATION_REMOVED) then
        Duel.ReturnToField(tc)
    end
end