-- Hyper God Energy
local s,id=GetID()
function s.initial_effect(c)
    -- Activate same turn it was Set
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e0:SetCondition(s.setcon)
    c:RegisterEffect(e0)

    -- Main negation effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

-- Divine Beast check to activate set turn
function s.setcon(e)
    return Duel.IsExistingMatchingCard(Card.IsRace,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,RACE_DIVINE)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(0)
    local b1=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,10000020) -- Slifer
    local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,10000010) -- Obelisk
    local b3=Duel.IsExistingMatchingCard(function(c)
        return c:IsCode(10000000) or c:IsSetCard(0x3b) -- The Winged Dragon of Ra variants
    end,tp,LOCATION_MZONE,0,1,nil)

    if chk==0 then return b1 or b2 or b3 end

    -- Store which effects are usable
    local opt=0
    if b1 then opt=opt+1 end
    if b2 then opt=opt+2 end
    if b3 then opt=opt+4 end
    e:SetLabel(opt)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    return true
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local opt=e:GetLabel()
    local rc=re:GetHandler()

    if opt&1~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        -- Slifer effect
        if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
            Duel.NegateActivation(ev)
            local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
            for tc in aux.Next(g) do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(-1000)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_UPDATE_DEFENSE)
                tc:RegisterEffect(e2)
            end
        end
    elseif opt&2~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        -- Obelisk effect
        local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsReleasable),tp,LOCATION_MZONE,0,nil)
        if #g>1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
            local rg=g:Select(tp,1,2,nil)
            if Duel.Release(rg,REASON_EFFECT)>0 then
                Duel.NegateActivation(ev)
                Duel.Damage(1-tp,2000*#rg,REASON_EFFECT)
            end
        end
    elseif opt&4~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        -- Ra effect
        if Duel.CheckLPCost(tp,1000) then
            Duel.PayLPCost(tp,1000)
            Duel.NegateActivation(ev)
            local g=Duel.GetMatchingGroup(function(c)
                return c:IsFaceup() and (c:IsCode(10000000) or c:IsSetCard(0x3b))
            end,tp,LOCATION_MZONE,0,nil)
            for tc in aux.Next(g) do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(1000)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_UPDATE_DEFENSE)
                tc:RegisterEffect(e2)
            end
        end
    end
end

