-- Gilford, the Fighting Flame Swordsman
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Materials
    Fusion.AddProcMix(c,true,true,45231177,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR))

    -- Treated as Flame Swordsman
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetValue(45231177)
    c:RegisterEffect(e0)

    -- Destroy all opponent's monsters on Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Equip FIRE monster from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)

    -- Destroy S/T + Equip
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.sdtg)
    e3:SetOperation(s.sdop)
    c:RegisterEffect(e3)

    -- Revive Flame Swordsman on destruction
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,3})
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- Destroy all opponent monsters on Summon (but no direct attack)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
    -- Cannot attack directly this turn
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- Equip FIRE from GY
function s.eqfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsForbidden() then return end
    Duel.Equip(tp,tc,c)
end

-- Destroy 1 S/T and 1 Equip card equipped to this
function s.sdfilter1(c)
    return c:IsSpellTrap() and c:IsDestructable()
end
function s.sdfilter2(c,ec)
    return c:IsFaceup() and c:GetEquipTarget()==ec and c:IsDestructable()
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.sdfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            and Duel.IsExistingMatchingCard(s.sdfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,c)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectMatchingCard(tp,s.sdfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    local g2=Duel.SelectMatchingCard(tp,s.sdfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,c)
    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g1=Duel.SelectMatchingCard(tp,s.sdfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    local g2=Duel.SelectMatchingCard(tp,s.sdfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,c)
    g1:Merge(g2)
    if #g1>0 then
        Duel.Destroy(g1,REASON_EFFECT)
    end
end

-- Special Summon a Level 5 Flame Swordsman from Extra or GY
function s.spfilter(c,e,tp)
    return c:IsLevel(5) and c:IsCode(45231177) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
