--Baldr the White Monarch
local s,id=GetID()
function s.initial_effect(c)
    -- Allow Tribute Summon with 1 Monarch S/T
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRIBUTE_LIMIT)
    e0:SetValue(s.tlimit)
    c:RegisterEffect(e0)

    -- Tribute Summon procedure with Spell/Trap as tribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.otcon)
    e1:SetOperation(s.otop)
    e1:SetValue(SUMMON_TYPE_ADVANCE)
    c:RegisterEffect(e1)

    -- On Tribute Summon: search 800 ATK / 1000 DEF + optional effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Tribute Limit only applies to Monarch S/T
function s.tlimit(e,c)
    return c:IsLocation(LOCATION_SZONE) and not (c:IsSetCard(0xc6) and c:IsType(TYPE_SPELL+TYPE_TRAP))
end

-- Custom Tribute Summon using 1 Monarch S/T
function s.otfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xc6) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsReleasable()
end
function s.otcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_ONFIELD,0,nil)
    return minc<=1 and Duel.CheckTribute(c,1,1,g)
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectTribute(tp,c,1,1,Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_ONFIELD,0,nil))
    c:SetMaterial(g)
    Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

-- Search 800 ATK / 1000 DEF monster on Tribute Summon
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function s.filter(c,e,tp)
    return c:IsAttack(800) and c:IsDefense(1000) and c:IsType(TYPE_MONSTER)
        and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    local opt=0
    if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and (not tc:IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    else
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end

    -- Apply one of the effects
    Duel.BreakEffect()
    local opt=0
    if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then
        -- Extra Tribute Summon
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    else
        Duel.Recover(tp,800,REASON_EFFECT)
    end
end
