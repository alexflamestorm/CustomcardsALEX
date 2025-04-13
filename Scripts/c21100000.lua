-- Chimera the Demonic Flying Mythical Beast
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),
        aux.FilterBoolFunction(s.matfilter))
    
    -- Name becomes "Chimera the Flying Mythical Beast"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e0:SetValue(04796100) -- Chimera the Flying Mythical Beast original code
    c:RegisterEffect(e0)

    -- Draw cards on Fusion Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.drcon)
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    c:RegisterEffect(e1)

    -- Negate + Flip + Piercing support
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DISABLE+CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- Banish to recover
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.rctg)
    e3:SetOperation(s.rcop)
    c:RegisterEffect(e3)
end

function s.matfilter(c)
    return c:IsRace(RACE_BEAST+RACE_FIEND)
end

-- Draw condition
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=0
    local mat=e:GetHandler():GetMaterial()
    for tc in aux.Next(mat) do
        if tc:IsRace(RACE_BEAST+RACE_FIEND) then
            ct=ct+1
        end
    end
    if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
    e:SetLabel(ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
end

-- Negate/flip/piercing condition
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:IsActivated() and re:GetHandler():IsLocation(LOCATION_MZONE)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_PIERCE)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(function(e,c)
            return c:IsRace(RACE_BEAST+RACE_FIEND+RACE_ILLUSION)
        end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

-- Recovery
function s.rcfilter(c)
    return c:IsRace(RACE_BEAST+RACE_FIEND+RACE_ILLUSION) and not c:IsCode(id) and c:IsFaceup() and c:IsAbleToHand()
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rcfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.rcfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end
