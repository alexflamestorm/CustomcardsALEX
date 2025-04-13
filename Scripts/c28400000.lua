--Summoned Skull Archfiend
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be Normal Summoned/Set
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.FALSE)
    c:RegisterEffect(e0)

    --Special Summon (reveal 1 Summoned Skull or Archfiend from hand or Deck)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Name becomes "Summoned Skull"
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_CODE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(70781052)
    c:RegisterEffect(e2)

    --Wipe opponent's monsters with lower DEF
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1)
    e3:SetCost(s.drycost)
    e3:SetTarget(s.drytg)
    e3:SetOperation(s.dryop)
    c:RegisterEffect(e3)
end

-- Special Summon by revealing
function s.revealfilter(c)
    return c:IsSetCard(0x23) or c:IsCode(70781052) -- "Archfiend" or "Summoned Skull"
end
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(s.revealfilter,c:GetControler(),LOCATION_HAND+LOCATION_DECK,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleDeck(tp)
end

-- Destroy Effect
function s.drycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.dryfilter(c,atk)
    return c:IsFaceup() and (c:IsType(TYPE_LINK) or c:GetDefense()<atk)
end
function s.drytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.dryfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
    local g=Duel.GetMatchingGroup(s.dryfilter,tp,0,LOCATION_MZONE,nil,e:GetHandler():GetAttack())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.dryop(e,tp,eg,ep,ev,re,r,rp)
    local atk=e:GetHandler():GetAttack()
    local g=Duel.GetMatchingGroup(s.dryfilter,tp,0,LOCATION_MZONE,nil,atk)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
        -- Skip Battle Phase
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SKIP_BP)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

