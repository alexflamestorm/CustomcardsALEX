-- Rainbow Crystal Rainbow Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion summon procedure
    Fusion.AddProcMixN(c,true,true,s.cbfilter,7)

    -- Alternative Special Summon by returning 7 Crystal Beast cards
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    -- Battle/card effect destruction protection
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.reptg)
    c:RegisterEffect(e1)

    -- ATK boost
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- Inflict 4000 damage
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetCondition(s.damcon)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)

    -- Treated as Ultimate Crystal
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_ADD_TYPE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e4:SetValue(TYPE_FUSION)
    c:RegisterEffect(e4)
end

-- Fusion material filter
function s.cbfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0x1034,fc,sumtype,tp) -- Crystal Beast
end

-- Special Summon condition (from Extra Deck)
function s.cbretfilter(c)
    return c:IsSetCard(0x1034) and c:IsFaceup() and c:IsAbleToHandAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.cbretfilter,tp,LOCATION_MZONE,0,nil)
    return g:GetClassCount(Card.GetCode)>=7 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(s.cbretfilter,tp,LOCATION_MZONE,0,nil)
    local sg=aux.SelectUnselectGroup(g,e,tp,7,7,aux.dncheck,1,tp,HINTMSG_RTOHAND)
    Duel.SendtoHand(sg,nil,REASON_COST)
end

-- Replacement effect
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return e:GetHandler():GetFlagEffect(id)<ct end
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    return true
end

-- ATK boost = 1000 per "Crystal" Spell
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.crystalspell,c:GetControler(),LOCATION_SZONE,0,nil)*1000
end
function s.crystalspell(c)
    return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x1034)
end

-- Inflict 4000 damage
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsRelateToBattle() and not bc:IsDestroyed()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(4000)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,4000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
