
-- The Wrath of God
local s,id=GetID()
function s.initial_effect(c)
    -- Search spell/trap that lists Divine Beast
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Additional Tribute Summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
    e2:SetTarget(s.sumfilter)
    c:RegisterEffect(e2)

    -- Restrict opponent use of Divine Beasts
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.matlimit)
    e3:SetValue(s.matval)
    c:RegisterEffect(e3)

    local e4=e3:Clone()
    e4:SetCode(EFFECT_UNRELEASABLE_SUM)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    -- Prevent Divine Beasts from activating effects in End Phase
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_CANNOT_TRIGGER)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetRange(LOCATION_SZONE)
    e5:SetTargetRange(1,0)
    e5:SetCondition(s.epcon)
    e5:SetTarget(s.epfilter)
    c:RegisterEffect(e5)
end

-- Divine Beast codes
s.listed_names={10000020,10000010,10000000}
function s.divinefilter(c)
    return c:IsFaceup() and c:IsCode(10000020,10000010,10000000)
end

-- Search condition: You control at least one Divine Beast
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.divinefilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Filter for searchable cards
function s.thfilter(c)
    return (c:ListsCode(10000020) or c:ListsCode(10000010) or c:ListsCode(10000000))
        and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Extra Tribute Summon for Divine Beast
function s.sumfilter(c)
    return c:IsRace(RACE_DIVINE)
end

-- Restriction: Can't be used as material or tributed by opponent
function s.matlimit(e,c)
    return c:IsCode(10000020,10000010,10000000)
end
function s.matval(e,c,sumtype)
    return sumtype==SUMMON_TYPE_FUSION or sumtype==SUMMON_TYPE_SYNCHRO 
        or sumtype==SUMMON_TYPE_XYZ or sumtype==SUMMON_TYPE_LINK
end

-- End Phase effect lock
function s.epcon(e)
    return Duel.GetCurrentPhase()==PHASE_END
end
function s.epfilter(e,c)
    return c:IsCode(10000020,10000010,10000000)
end
