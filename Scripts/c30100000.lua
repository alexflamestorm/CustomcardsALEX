--Heroic Champion - Lionheart (Custom)
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,4,3)
    c:EnableReviveLimit()
    
    --Battle and card effect indestructible
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e2)
    
    --Attach attacked monster after battle
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLED)
    e3:SetCondition(s.atcon)
    e3:SetOperation(s.atop)
    e3:SetCountLimit(1,id)
    c:RegisterEffect(e3)
    
    --Gain ATK equal to all Warrior monsters on field
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCost(s.atkcost)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
end

-- E3: Attach the attacked monster
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() and not bc:IsImmuneToEffect(e)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if c:IsRelateToEffect(e) and bc:IsRelateToBattle() and not bc:IsImmuneToEffect(e) then
        Duel.Overlay(c,Group.FromCards(bc))
    end
end

-- E4: Gain ATK from other Warriors
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE,LOCATION_MZONE,nil,RACE_WARRIOR)
    local atk=g:GetSum(Card.GetAttack)
    -- Prevent other monsters from attacking
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(function(e,c) return c~=e:GetHandler() end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    -- Gain ATK
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(atk)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
end
