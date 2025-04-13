-- Red-Eyes Archfiend Darkness Skull Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Fusion materials
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)

    -- Unaffected by other monsters' effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- Destroy all opponent's monsters and burn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)

    -- End Phase burn
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.burntg)
    e3:SetOperation(s.burnop)
    c:RegisterEffect(e3)
end

-- Fusion materials
function s.matfilter1(c,fc,sumtype,tp)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
    return c:IsSetCard(0x3b) or c:IsCode(74677422) -- "Red-Eyes" support
end

-- Immunity to monster effects
function s.efilter(e,te)
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end

-- Destroy opponent's monsters and inflict damage
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end
    if Duel.Destroy(g,REASON_EFFECT)>0 then
        local dg=Duel.GetOperatedGroup()
        local maxatk=0
        for tc in dg:Iter() do
            local atk=tc:GetBaseAttack()
            if atk>maxatk then maxatk=atk end
        end
        Duel.Damage(1-tp,maxatk,REASON_EFFECT)
    end
end

-- End Phase burn
function s.burntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    if ct>0 then
        Duel.Damage(1-tp,ct*200,REASON_EFFECT)
    end
end
