--Gravekeeper's Bahimah of Serket
local s,id=GetID()
function s.initial_effect(c)
    --Ritual Summon procedure is handled by the Spell, this is just the effects
    --Activate Necrovalley or related card on Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.nvcon)
    e1:SetTarget(s.nvtg)
    e1:SetOperation(s.nvop)
    c:RegisterEffect(e1)

    --Gain ATK and second attack
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdocon)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    --Quick: Send S/T, search Gravekeeper's
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.cost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

-- Check Ritual Summoned
function s.nvcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

-- Activate Necrovalley or Continuous S/T
function s.nvfilter(c)
    return c:IsSetCard(0x2e) and (c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:CheckActivateEffect(false,true,false)~=nil
end
function s.nvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.nvfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil)
    end
end
function s.nvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
    local g=Duel.SelectMatchingCard(tp,s.nvfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local te=tc:GetActivateEffect()
        if te then
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            te:UseCountLimit(tp,1,true)
            local cost=te:GetCost()
            if cost then cost(te,tp,eg,ep,ev,re,r,rp,1) end
            Duel.BreakEffect()
            te:GetOperation()(te,tp,eg,ep,ev,re,r,rp)
        end
    end
end

-- Gain 500 ATK and extra attack
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local atk=Effect.CreateEffect(c)
        atk:SetType(EFFECT_TYPE_SINGLE)
        atk:SetCode(EFFECT_UPDATE_ATTACK)
        atk:SetValue(500)
        atk:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(atk)

        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- Cost: send Spell/Trap from hand/field to GY
function s.costfilter(c)
    return c:IsSpellTrap() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

-- Search Level 5+ Gravekeeper's
function s.thfilter(c)
    return c:IsSetCard(0x2e) and c:IsLevelAbove(5) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

