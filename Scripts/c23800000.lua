-- Gagagagauntlet Launcher
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon procedure
    Xyz.AddProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
    c:EnableReviveLimit()

    -- Destroy + search
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Change Rank and ATK if no materials
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_RANK)
    e2:SetCondition(s.rankcon)
    e2:SetValue(4)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_SET_ATTACK_FINAL)
    e3:SetValue(3000)
    c:RegisterEffect(e3)
end

function s.ovfilter(c,tp,lc)
    return c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:GetReasonEffect() and c:GetReasonEffect():IsActiveType(TYPE_XYZ)
end

function s.xyzop(e,tp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.filter(c)
    return c:IsFaceup() and c:IsDestructable()
end

function s.thfilter(c)
    return (c:IsSetCard(0x54) or c:IsSetCard(0x1a)) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

function s.rankcon(e)
    return e:GetHandler():GetOverlayCount()==0
end
