--Nekroz of Constellar
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddRitualProcGreater(c,aux.FilterBoolFunction(Card.IsSetCard,0xb4)) -- Nekroz Ritual Spell
    -- Return to hand (discard effect)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.thcost1)
    e1:SetTarget(s.thtg1)
    e1:SetOperation(s.thop1)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
    -- Quick Effect: Return any 1 card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(s.qhtg)
    e2:SetOperation(s.qhop)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)
end

-- Cost: discard this card
function s.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- Target: 1 Nekroz/Constellar + 1 opponent's monster
function s.thfilter1(c)
    return (c:IsSetCard(0xb4) or c:IsSetCard(0x53)) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thfilter2(c)
    return c:IsMonster() and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then
        return Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingTarget(s.thfilter2,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g1=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g2=Duel.SelectTarget(tp,s.thfilter2,tp,0,LOCATION_MZONE,1,1,nil)
    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,#g1,0,0)
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end

-- Quick Effect: return 1 card
function s.qhfilter(c)
    return c:IsAbleToHand()
end
function s.qhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.qhfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.qhfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.qhfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.qhop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
