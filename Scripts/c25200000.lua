-- Exodia the Legendary God
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- Special Summon condition (from Extra Deck)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    
    -- Unaffected by other cards' effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- Set original ATK/DEF
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SET_BASE_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e3)

    -- Destroy all if 5 Spellcasters used
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.descon)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)

    -- Win condition
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_LEAVE_FIELD)
    e5:SetCondition(s.wincon)
    e5:SetOperation(s.winop)
    c:RegisterEffect(e5)
end

-- Fusion Materials filter
function s.matfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.exodiafilter(c)
    return c:IsCode(33396948) or c:IsForbiddenOne()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local exodia=g:Filter(Card.IsCode,nil,33396948)
    local darks=g:Filter(s.matfilter,nil)
    return #exodia>0 and #g>=2
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local exodia=g:FilterSelect(tp,Card.IsCode,1,1,nil,33396948)
    local others=g:Select(tp,1,63,exodia:GetFirst())
    exodia:Merge(others)
    c:SetMaterial(exodia)
    Duel.SendtoGrave(exodia,REASON_COST+REASON_MATERIAL)
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,#exodia,"Materials used: "..#exodia)
    -- Save for spellcaster check
    local sc=exodia:FilterCount(Card.IsRace,nil,RACE_SPELLCASTER)
    c:SetHint(CHINT_CARD,id)
    c:SetTurnCounter(sc)
end

-- Immune to other effects
function s.efilter(e,te)
    return te:GetOwner()~=e:GetOwner()
end

-- ATK/DEF based on materials
function s.atkval(e,c)
    return c:GetFlagEffectLabel(id) and c:GetFlagEffectLabel(id)*1000 or 1000
end

-- Destroy condition: 5 Spellcaster materials
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetTurnCounter()>=5
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
    Duel.Destroy(g,REASON_EFFECT)
end

-- Win condition
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsLocation,tp,LOCATION_GRAVE,0,nil)
    return g:IsExists(Card.IsCode,1,nil,33396948)
        and g:IsExists(Card.IsCode,1,nil,07902349)
        and g:IsExists(Card.IsCode,1,nil,70903634)
        and g:IsExists(Card.IsCode,1,nil,44519536)
        and g:IsExists(Card.IsCode,1,nil,89091579)
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Win(tp,WIN_REASON_EXODIA)
end
