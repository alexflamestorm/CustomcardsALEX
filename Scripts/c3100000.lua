--Destruction Sword Tactics
local s,id=GetID()
function s.initial_effect(c)
    -- Draw when a "Buster Blader" or "Destruction Sword" monster destroys a monster by battle
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BATTLE_DESTROYING)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.drcon)
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Return from GY by discarding a "Destruction Sword" card
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.setcon)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    -- Choose 1 effect per turn
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.effecttg)
    e3:SetOperation(s.effectop)
    c:RegisterEffect(e3)
end

-- Check if a "Buster Blader" or "Destruction Sword" monster destroyed another monster
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    return tc:IsControler(tp) and tc:IsSetCard(SET_BUSTER_BLADER) or tc:IsSetCard(SET_DESTRUCTION_SWORD)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,1,REASON_EFFECT)
end

-- Condition to return from GY
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,SET_DESTRUCTION_SWORD) end
    Duel.DiscardHand(tp,Card.IsSetCard,1,1,REASON_COST,nil,SET_DESTRUCTION_SWORD)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

-- Select one of two effects
function s.effecttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.effectop(e,tp,eg,ep,ev,re,r,rp)
    local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    if opt==0 then
        -- Equip from GY and modify ATK/DEF
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local tc=Duel.SelectTarget(tp,Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
        local ec=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsSetCard,SET_BUSTER_BLADER),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if tc and ec then
            Duel.Equip(tp,tc,ec)
            local atk=math.floor(tc:GetAttack()/2)
            local def=math.floor(tc:GetDefense()/2)
            local e1=Effect.CreateEffect(ec)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            ec:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            e2:SetValue(def)
            ec:RegisterEffect(e2)
        end
    else
        -- Alternative cost for discarding effects
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_DISCARD_COST_CHANGE)
        e1:SetTargetRange(LOCATION_SZONE,0)
        e1:SetValue(s.replacecost)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.replacecost(e,re,rp,val)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,TYPE_EQUIP),e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end