-- Magical Storm Gaia The Dragon Champion
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.ffilter1,s.ffilter2,aux.FilterBoolFunction(Card.IsLevel,5),aux.FilterBoolFunction(Card.IsLevel,5))

    -- Name becomes "Gaia the Dragon Champion"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(66889139)
    c:RegisterEffect(e1)

    -- Draw 3, discard 1 if Fusion Summoned with proper condition
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)

    -- Quick Effect: Negate 2 opponent cards
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsMainPhase() end)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

-- Fusion materials
function s.ffilter1(c)
    return c:IsSetCard(0xbd) and c:IsMonster()
end
function s.ffilter2(c)
    return c:IsRace(RACE_DRAGON)
end

-- Draw 3 if Fusion Summoned and you control a proper Spell/Trap
function s.spellfilter(c)
    return (c:IsType(TYPE_FIELD) or c:IsType(TYPE_CONTINUOUS)) and c:IsFaceup()
        and c:IsAbleToGrave() and (c:IsCode(66889139) or c:IsSetCard(0xbd))
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION)
        and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,3,REASON_EFFECT)==3 then
        Duel.ShuffleHand(tp)
        Duel.BreakEffect()
        Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
    end
end

-- Quick Effect: negate 2 face-up opponent cards, lose 2600 ATK
function s.negfilter(c)
    return c:IsFaceup() and aux.disfilter1(c)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetAttack()>=2600
        and Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_ONFIELD,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() or c:GetAttack()<2600 then return end
    local atkdown=Effect.CreateEffect(c)
    atkdown:SetType(EFFECT_TYPE_SINGLE)
    atkdown:SetCode(EFFECT_UPDATE_ATTACK)
    atkdown:SetValue(-2600)
    atkdown:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(atkdown)
    local tg=Duel.GetTargetCards(e)
    for tc in aux.Next(tg) do
        if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2)
        end
    end
end
