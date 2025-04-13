-- Salamangreat Medallion
local s,id=GetID()
function s.initial_effect(c)
    -- Equip to 1 "Salamangreat" monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Allow 2 attacks on monsters
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Take control of an opponent's monster
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.ctcon)
    e3:SetCost(s.ctcost)
    e3:SetTarget(s.cttg)
    e3:SetOperation(s.ctop)
    c:RegisterEffect(e3)
end

-- Equip targeting
function s.eqfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x119)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
        Duel.Equip(tp,c,tc)
    end
end

-- Condition to activate Quick Effect
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsEquipped()
end

-- Cost (send itself to the GY)
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- Control effect target
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsType(TYPE_EFFECT) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_EFFECT) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_MZONE,1,1,nil,TYPE_EFFECT)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

-- Control effect operation
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1) then
        -- Change Type to Cyberse
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetValue(RACE_CYBERSE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)

        -- Change Attribute to FIRE
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetValue(ATTRIBUTE_FIRE)
        tc:RegisterEffect(e2)

        -- Treat as "Salamangreat"
        local e3=e1:Clone()
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetValue(0x119)
        tc:RegisterEffect(e3)
    end
end

