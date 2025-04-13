-- Tabcode Talker
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Link Summon
    Link.AddProcedure(c,s.matfilter,2,99,s.lcheck)

    -- Special Summon a 2300 ATK Link Monster from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Immunity while monster summoned by e1 is on the field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.immcon)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    -- Copy name and effect if that monster leaves
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.copycon)
    e3:SetOperation(s.copyop)
    c:RegisterEffect(e3)

    -- Register flag for the monster summoned by e1
    s.summoned_by_effect=nil
end

-- Link Materials
function s.matfilter(c,lc,sumtype,tp)
    return c:IsType(TYPE_MONSTER,lc,sumtype,tp)
end
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsRace,1,nil,RACE_CYBERSE)
end

-- On Link Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c,e,tp,lc)
    return c:IsType(TYPE_LINK) and c:GetAttack()==2300 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(lc:GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        s.summoned_by_effect=tc
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        tc:SetCardTarget(c) -- Used to track relation
    end
end

-- Immunity if summoned monster still exists
function s.immcon(e)
    local c=e:GetHandler()
    local tc=s.summoned_by_effect
    return tc and tc:IsOnField() and tc:IsFaceup() and tc:GetFlagEffect(id)>0
end
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Copy name and effect when that monster is sent to GY
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=s.summoned_by_effect
    return tc and eg:IsContains(tc)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=s.summoned_by_effect
    if not tc or not tc:IsType(TYPE_MONSTER) then return end
    local code=tc:GetOriginalCode()
    c:ReplaceEffect(code,RESET_EVENT+RESETS_STANDARD)
end

