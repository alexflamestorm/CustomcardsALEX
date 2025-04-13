-- Mementoal Tecuhtlica - Five Headed Ruler
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Must be Fusion Summoned
    Fusion.AddProcMixN(c,true,true,s.mfilter,5)

    -- Name becomes Combined Creation
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(100000185) -- ID de "Mementoal Tecuhtlica - Combined Creation"
    c:RegisterEffect(e0)

    -- Only control 1
    c:SetUniqueOnField(1,0,id)

    -- Unaffected by other cards except "Memento"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)

    -- Attack all monsters if only monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ATTACK_ALL)
    e2:SetCondition(s.atkcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- If destroyed in battle, summon Combined Creation
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Fusion material must be "Memento" monsters
function s.mfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0x1f49)
end

-- Immune to effects that aren't "Memento"
function s.immval(e,te)
    local c=te:GetHandler()
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and not c:IsSetCard(0x1f49)
end

-- Can attack all if only monster
function s.atkcon(e)
    return Duel.GetMatchingGroupCount(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())==1
end

-- Battle destroyed trigger
function s.spfilter(c,e,tp)
    return c:IsCode(100000185) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
end
