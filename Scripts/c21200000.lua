-- Black Luster Blader – Soldier of the Sword of Destruction
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,
        aux.FilterBoolFunction(Card.IsSetCard,0x10cf), -- "Black Luster Soldier"
        aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR+RACE_DRAGON)
    )

    -- Unaffected by opponent's LIGHT, DARK and Dragon monster effects
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCode(EFFECT_IMMUNE_EFFECT)
    e0:SetValue(s.efilter)
    c:RegisterEffect(e0)

    -- Attack all monsters once each
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ATTACK_ALL)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Quick banish + gain ATK/DEF (1 turn cooldown)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.banishcon)
    e2:SetTarget(s.banishtg)
    e2:SetOperation(s.banishop)
    c:RegisterEffect(e2)

    -- Set cooldown flag after effect resolves
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetCountLimit(1)
    e3:SetOperation(s.cooldownop)
    Duel.RegisterEffect(e3,0)

    -- Inflict damage: Equip 1 monster from opponent's GY or banished
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_EQUIP+CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DAMAGE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.eqtg)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)
end

function s.efilter(e,te)
    local c=te:GetHandler()
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer() and
        (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
end

-- Quick banish
function s.banishcon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():GetFlagEffect(id+1)>0
end
function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() or chkc:IsLocation(LOCATION_GRAVE) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            c:RegisterEffect(e2)
            -- Set cooldown
            c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
        end
    end
end

function s.cooldownop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c) return c:GetFlagEffect(id+1)>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    for tc in g:Iter() do
        tc:ResetFlagEffect(id+1)
    end
end

-- Equip from GY or banished
function s.eqfilter(c)
    return c:IsMonster() and c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        if Duel.Equip(tp,tc,c) then
            -- Negate same Type/Attribute effects
            local at=tc:GetAttribute()
            local rt=tc:GetRace()
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
            e1:SetTarget(function(e,c)
                return c:IsFaceup() and c:IsAttribute(at) and c:IsRace(rt)
            end)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
