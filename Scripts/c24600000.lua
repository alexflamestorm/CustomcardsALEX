-- Enlightenment Gaia the Dragon Champion
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
    
    -- Name becomes "Gaia the Dragon Champion"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(66889139) -- Gaia the Dragon Champion ID
    c:RegisterEffect(e0)

    -- Gains ATK for Normal Monsters used
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Negate effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- Trigger effect: set S/T or gain ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOFIELD+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.trigtg)
    e3:SetOperation(s.trigop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.byown)
    c:RegisterEffect(e4)
end

-- Fusion materials
function s.matfilter1(c)
    return c:IsRace(RACE_WARRIOR) and (c:IsCode(06368038) or c:IsType(TYPE_EFFECT)) -- Gaia or Warrior Effect
end
function s.matfilter2(c)
    return c:IsRace(RACE_DRAGON) and (c:IsCode(28279543) or c:IsType(TYPE_EFFECT)) -- Curse or Dragon Effect
end

-- Gain ATK for each Normal Monster used
function s.atkcon(e)
    return e:GetHandler():GetMaterial():IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function s.atkval(e,c)
    local ct=e:GetHandler():GetMaterial():FilterCount(Card.IsType,nil,TYPE_NORMAL)
    return ct*2600
end

-- Negate effect
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:GetAttack()>=2600 end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-2600)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

-- Condition: was destroyed by its own effect
function s.byown(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler()==e:GetHandler()
end

-- Search or ATK gain
function s.setfilter(c)
    return c:IsCode(98045062,30450531,17948378) and not c:IsForbidden()
end
function s.trigtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.trigop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
    local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        end
    else
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(2600)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
