--Archfiend Skull King of Devastation
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),8,2,s.xyzfilter,aux.Stringid(id,0),2,nil)

    -- Se trata como "Summoned Skull" y "Archfiend"
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

    -- Negar y destruir
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

-- Permite invocarlo usando "Summoned Skull"
function s.xyzfilter(c,xyz,sumtype,tp)
    return c:IsCode(70781052)
end

-- **Condición para activar el efecto de negación**
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetOverlayCount()>0
end

-- **Seleccionar objetivos para negar**
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g1=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,g2,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
end

-- **Negar efectos y destruir**
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local tc1=g:GetFirst()
    local tc2=g:GetNext()
    if not (tc1 and tc2) then return end
    if tc1:IsControler(1-tp) then tc1,tc2=tc2,tc1 end
    if tc2:IsFaceup() and tc2:IsRelateToEffect(e) and Duel.NegateRelatedChain(tc2,RESET_TURN_SET) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc2:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc2:RegisterEffect(e2)
        if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 then
            Duel.BreakEffect()
            c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
        end
    end
end
