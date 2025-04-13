-- Paladion The Magna Warrior
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon procedure
    c:SetUniqueOnField(1,0,id)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Redirect targeting
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_BE_BATTLE_TARGET+EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.redircon)
    e2:SetTarget(s.redirtg)
    e2:SetOperation(s.redirop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)

    -- Can attack directly, but conditional damage
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e4:SetCondition(s.damcon)
    e4:SetOperation(s.damop)
    c:RegisterEffect(e4)

    -- On destroy, search
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCondition(s.thcon)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
end

function s.spfilter(c,mg)
    return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and mg:IsExists(s.spfilter2,1,c,c:GetCode())
end
function s.spfilter2(c,code)
    return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and not c:IsCode(code)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local ct=#aux.GetUniqueCodes(g,s.spfilter)
    return ct>=3
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE)
    Duel.Remove(tg,POS_FACEUP,REASON_COST)
end

function s.rescon(g,e,tp)
    return #aux.GetUniqueCodes(g)==3 and g:FilterCount(Card.IsSetCard,nil,0x2066)==3
end

-- Redirect target
function s.redircon(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.GetCurrentChain()>0 and re and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) 
        or Duel.GetAttackTarget()==e:GetHandler()
end

function s.redirtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
end

function s.redirop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
    local tc=g:GetFirst()
    if Duel.GetAttackTarget()==e:GetHandler() then
        Duel.ChangeAttackTarget(tc)
    elseif re and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
        if tg:IsContains(e:GetHandler()) then
            Duel.ChangeTargetCard(ev,Group.FromCards(tc))
        end
    end
end

-- Damage condition: when direct attack
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetAttackTarget()==nil and c:GetBattleTarget()==nil and c==Duel.GetAttacker()
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(s.magfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    Duel.ChangeBattleDamage(tp,ct*400,false)
end
function s.magfilter(c)
    return c:IsSetCard(0x2066) and c:IsLevelBelow(4)
end

-- On destroy, search Level 8 Magna Warrior
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.thfilter(c)
    return c:IsSetCard(0x2093) and c:IsLevel(8) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
