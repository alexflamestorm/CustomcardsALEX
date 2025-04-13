-- Red-Eyes Twin Meteor Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Summon procedure
    Fusion.AddProcMix(c,true,true,s.matfilter1,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON))

    -- Alternative Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Destroy Spells/Traps and optionally Special Summon Normals
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Two attacks on monsters
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

-- Fusion Material filters
function s.matfilter1(c)
    return c:IsLevel(7) and c:IsSetCard(0x3b)
end

-- Alternative Special Summon condition
function s.spfilter1(c,tp)
    return c:IsLevel(7) and c:IsSetCard(0x3b) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.spfilter2(c,tp)
    return c:IsRace(RACE_DRAGON) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst(),tp)
    g1:Merge(g2)
    Duel.SendtoGrave(g1,REASON_COST)
end

-- Destroy Spells/Traps and Special Summon Normal Monsters
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_NORMAL) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=g:Select(tp,1,2,nil)
    local ct=Duel.Destroy(dg,REASON_EFFECT)
    if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL)
        if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g2:Select(tp,1,math.min(ct,Duel.GetLocationCount(tp,LOCATION_MZONE)),nil)
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_DEFENSE)
        end
    end
end

