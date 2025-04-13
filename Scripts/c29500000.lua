--Phantom Beast Machine King Barbaros Ur
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion materials
    Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
    
    -- Cannot be destroyed by battle + Battle Damage = 3000
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)

    -- Take control after battle
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLED)
    e3:SetCondition(s.ctcon)
    e3:SetTarget(s.cttg)
    e3:SetOperation(s.ctop)
    c:RegisterEffect(e3)

    -- Negate destruction or targeting (Quick Effect)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.negcon)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)
end

-- Fusion material filters
function s.matfilter1(c,fc,sub,mg,sg)
    return c:IsType(TYPE_MONSTER) and (c:IsCode(78651105) or (c:IsLevelAbove(5) and c:IsSummonType(SUMMON_TYPE_NORMAL) and not c:IsSummonableCard()))
end
function s.matfilter2(c,fc,sub,mg,sg)
    return c:IsAttackAbove(3000)
end

-- Damage becomes 3000
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsControler(1-tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
        e1:SetValue(3000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
        bc:RegisterEffect(e1)
    end
end

-- Take control of monster
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    if chk==0 then return bc:IsControlerCanBeChanged() end
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then
        Duel.GetControl(bc,tp)
    end
end

-- Negate destruction or targeting
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)) or
        (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasCategory(CATEGORY_DESTROY) and re:GetHandler():IsRelateToEffect(re))
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsChainDisablable(ev) end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

