-- Elemental HERO Grand Terra Firma
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Requisitos de Fusión
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsFusionSetCard,0x8),s.extradeck_filter)

    -- Nombre tratado como "Elemental HERO Terra Firma" en campo y GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(29095552) -- ID de "Elemental HERO Terra Firma"
    c:RegisterEffect(e1)

    -- (Quick Effect) Banish 1 "Elemental HERO" monster, aplica 1 efecto
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- Requisito de Fusión: 1 monstruo invocado desde el Extra Deck
function s.extradeck_filter(c,fc,sumtype,tp)
    return c:IsSummonLocation(LOCATION_EXTRA)
end

-- Costo: Desterrar 1 "Elemental HERO" desde mano, campo o Cementerio
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    e:SetLabelObject(g:GetFirst())
end
function s.costfilter(c)
    return c:IsSetCard(0x8) and c:IsAbleToRemoveAsCost()
end

-- Selección del efecto
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
    local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    e:SetLabel(op)
end

-- Aplicación de los efectos
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=e:GetLabelObject()
    if not bc then return end
    local atk=bc:GetAttack()

    local op=e:GetLabel()
    if op==0 then
        -- Aumentar ATK
        if c:IsFaceup() and c:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
        end
    else
        -- Negar efectos y reducir ATK
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            if tc:IsType(TYPE_MONSTER) then
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_UPDATE_ATTACK)
                e2:SetValue(-atk)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e2)
            end
        end
    end
end
