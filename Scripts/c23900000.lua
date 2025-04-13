-- Lyrilusc - Duet Leiothrix
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    Link.AddProcedure(c,nil,1,1,s.lcheck)
    c:EnableReviveLimit()

    -- Battle protection and damage
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetCondition(s.lyrilusc_summon)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetCondition(s.lyrilusc_summon)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Apply additional effects based on monster this card points to
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_REMOVED)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.nobanishtg)
    e3:SetCondition(s.cond_wind)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.atktg)
    e4:SetValue(1000)
    e4:SetCondition(s.cond_wb)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id)
    e5:SetCondition(s.negcon)
    e5:SetCost(s.negcost)
    e5:SetTarget(s.negtg)
    e5:SetOperation(s.negop)
    c:RegisterEffect(e5)
end

function s.lcheck(g,lc,sumtype,tp)
    return g:GetFirst():IsLevel(1) or g:GetFirst():GetRank()==1
end

function s.lyrilusc_summon(e)
    local c=e:GetHandler()
    local mat=c:GetMaterial()
    return mat and mat:IsExists(Card.IsSetCard,1,nil,0xf7)
end

-- Cannot be banished (WIND)
function s.nobanishtg(e,c)
    local tc=e:GetHandler():GetLinkedGroup():GetFirst()
    return tc and tc:IsAttribute(ATTRIBUTE_WIND)
end
function s.cond_wind(e)
    return e:GetHandler():GetLinkedGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND)
end

-- +1000 ATK (Winged Beast)
function s.atktg(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.cond_wb(e)
    return e:GetHandler():GetLinkedGroup():IsExists(Card.IsRace,1,nil,RACE_WINGEDBEAST)
end

-- Negation effect (Level/Rank/Link 1)
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.IsChainNegatable(ev) and c:GetLinkedGroup():IsExists(s.lv1filter,1,nil)
end
function s.lv1filter(c)
    return (c:IsLevel(1) or c:GetRank()==1 or c:IsLink(1))
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end
