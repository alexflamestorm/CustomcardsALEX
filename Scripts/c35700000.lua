--Alien Dreadnought
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),1,1,Synchro.NonTuner(nil),1,99)

    --Alternative Synchro using opponent's monsters with A-Counters (Level 3)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SYNCHRO_MATERIAL)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e0:SetTarget(function(e,c) return c:GetControler()~=e:GetHandlerPlayer() and c:IsFaceup() and c:GetCounter(0x100e)>0 end)
    e0:SetValue(function(e,c) return 3 end) -- Treat as Level 3
    c:RegisterEffect(e0)

    --Quick Effect: Discard 1, place A-Counter on all opponent's monsters + protect own non-Synchro
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.qecost)
    e1:SetOperation(s.qeop)
    c:RegisterEffect(e1)
end

-- Quick Effect: Discard 1
function s.qecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Operation: Place A-Counters + grant protection to own non-Synchro monsters
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        tc:AddCounter(0x100e,1)
    end

    -- Grant protection to non-Synchro monsters
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.nonsynchrotg)
    e1:SetValue(s.efilter)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- Non-Synchro monsters you control
function s.nonsynchrotg(e,c)
    return c:IsControler(e:GetHandlerPlayer()) and not c:IsType(TYPE_SYNCHRO)
end

-- Immune to activated monster effects from opponent's monsters with A-Counters
function s.efilter(e,te)
    local tc=te:GetHandler()
    return te:IsActivated() and te:IsActiveType(TYPE_MONSTER)
        and tc:IsControler(1-e:GetHandlerPlayer())
        and tc:GetCounter(0x100e)>0
end
