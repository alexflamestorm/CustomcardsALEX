
--Baldr the Mega Monarch
local s,id=GetID()
function s.initial_effect(c)
    -- Tribute Summon with Monarch S/T
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRIBUTE_LIMIT)
    e1:SetValue(s.tlimit)
    c:RegisterEffect(e1)

    -- Summon with 1 Tribute if it's a Tribute Summoned monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SUMMON_PROC)
    e2:SetCondition(s.otcon)
    e2:SetOperation(s.otop)
    e2:SetValue(SUMMON_TYPE_ADVANCE)
    c:RegisterEffect(e2)

    -- On Tribute Summon: add 800/1000 and 2400/1000 monsters
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

-- Tribute limit allows Monarch S/T
function s.tlimit(e,c)
    return c:IsLocation(LOCATION_SZONE) and not (c:IsSetCard(0xc6) and c:IsType(TYPE_SPELL+TYPE_TRAP))
end

-- Can tribute summon with 1 Tribute Summoned monster
function s.otfilter(c)
    return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsReleasable()
end
function s.otcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    return minc<=1 and Duel.CheckTribute(c,1,1,tp,nil,nil,s.otfilter)
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectTribute(tp,c,1,1,nil,nil,s.otfilter)
    c:SetMaterial(g)
    Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1,g:GetFirst():GetAttribute())
end

-- On Tribute Summon
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function s.filter1(c)
    return c:IsAttack(800) and c:IsDefense(1000) and c:IsAbleToHand()
end
function s.filter2(c)
    return c:IsAttack(2400) and c:IsDefense(1000) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g1==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g2==0 then return end
    g1:Merge(g2)
    Duel.SendtoHand(g1,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g1)

    -- Check if the Tribute was a LIGHT monster or LIGHT Spell/Trap
    local attr=e:GetHandler():GetFlagEffectLabel(id)
    if attr and attr==ATTRIBUTE_LIGHT then
        Duel.BreakEffect()
        Duel.Recover(tp,1600,REASON_EFFECT)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)

        -- Permitir una segunda invocación normal
        local e2=e1:Clone()
        Duel.RegisterEffect(e2,tp)
    end
end
