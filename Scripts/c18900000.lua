-- Salamandra of Fighting Flames
local s,id=GetID()
function s.initial_effect(c)
    -- Equip to FIRE or Warrior
    aux.AddEquipProcedure(c,nil,function(c) return c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE) end)

    -- ATK boost + Unaffected by opponent’s monster effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(700)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    -- Recovery from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.retcost)
    e3:SetTarget(s.rettg)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)

    -- Bonus effect while equipped
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.bancon)
    e4:SetOperation(s.banop)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1,{id,1})
    e5:SetCondition(s.fuscon)
    e5:SetTarget(s.fustg)
    e5:SetOperation(s.fusop)
    c:RegisterEffect(e5)
end

-- Unaffected by opponent’s monster effects
function s.efilter(e,te)
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Recovery cost: shuffle 2 FIRE Warrior or "Fighting Flame"
function s.cfilter(c)
    return c:IsAbleToDeck() and (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) or c:IsSetCard(0xFF1)) -- Assuming "Fighting Flame" uses setcode 0xFF1
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) 
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)~=0 then
        -- FIRE-only Extra Deck lock
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_FIRE) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

-- Banish and Burn effect (Flame Swordsman or FIRE Warrior)
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    local rc=eg:GetFirst()
    return rc==ec and ec:IsFaceup() and (ec:IsCode(45231177) or ec:IsRace(RACE_WARRIOR) and ec:IsAttribute(ATTRIBUTE_FIRE))
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    local rc=eg:GetFirst()
    if rc:IsRelateToBattle() then
        local atk=rc:GetBaseAttack()
        Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
        Duel.Damage(1-tp,atk,REASON_EFFECT)
    end
end

-- Fusion Summon for "Flame Manipulator" or "Masaki"
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and (ec:IsCode(34460851) or ec:IsCode(90876561)) -- Flame Manipulator / Masaki
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsFusionSummonable,tp,LOCATION_EXTRA,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    if not ec then return end
    Fusion.SummonEff(ec,e,tp,nil,nil,nil,true)
end
