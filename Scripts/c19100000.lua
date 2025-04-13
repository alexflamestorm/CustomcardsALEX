-- Fighting Soul of the Flame Swordsman
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion materials
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2,true,function(g) return g:GetClassCount(Card.GetCode)==#g end)

    -- Treated as Flame Swordsman
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetValue(45231177)
    c:RegisterEffect(e0)

    -- Equip opponent's monster (Quick Effect)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e1:SetCost(s.eqcost)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Destroy before Damage Calc + burn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Leave field effect: destroy S/T equal to #Equips
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.lfcon)
    e3:SetTarget(s.lftg)
    e3:SetOperation(s.lfop)
    c:RegisterEffect(e3)
end

-- Cost: Discard + Banish 1 Equip
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE+LOCATION_SZONE,0,1,nil,TYPE_EQUIP)
            and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) 
    end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_GRAVE+LOCATION_SZONE,0,1,1,nil,TYPE_EQUIP)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Equip opponent monster
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsImmuneToEffect(e) then return end
    if not Duel.Equip(tp,tc,c,false) then return end
    -- Give 700 ATK boost
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(700)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
end

-- Destroy opponent’s monster + inflict 700
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetBattleTarget() and e:GetHandler():GetEquipGroup():GetCount()>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local d=e:GetHandler():GetBattleTarget()
    if chk==0 then return d:IsDestructable() end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local d=e:GetHandler():GetBattleTarget()
    if d and d:IsRelateToBattle() and Duel.Destroy(d,REASON_EFFECT)~=0 then
        Duel.Damage(1-tp,700,REASON_EFFECT)
    end
end

-- Leave field: destroy S/T equal to equip count
function s.lfcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousControler(tp) and rp~=tp and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.lftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetHandler():GetEquipGroup():GetCount()
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,1-tp,LOCATION_ONFIELD)
end
function s.lfop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetHandler():GetEquipGroup():GetCount()
    if ct==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,ct,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
