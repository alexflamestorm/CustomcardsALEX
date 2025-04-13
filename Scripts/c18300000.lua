-- Trial by Fire
local s,id=GetID()
function s.initial_effect(c)
    -- Activar: Revelar 3 y elegir 1
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Boost ATK/DEF Guerreros y Dragones
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.boostfilter)
    e2:SetValue(300)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    -- FUEGO no destruibles por batalla
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e4:SetTarget(s.firefilter)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    -- Banish castigo
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_REMOVE)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetRange(LOCATION_FZONE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,{id,0})
    e5:SetCondition(s.rmcon)
    e5:SetTarget(s.rmtg)
    e5:SetOperation(s.rmop)
    c:RegisterEffect(e5)
end

-- Filtro de boost
function s.boostfilter(e,c)
    return c:IsRace(RACE_WARRIOR+RACE_DRAGON)
end
function s.firefilter(e,c)
    return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- Activación
function s.filter(c)
    return (c:IsCode(732302) or c:IsSetCard(0x2d) or c:ListsCode(45231177)) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
    if #g<3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg=g:Select(tp,3,3,nil)
    Duel.ConfirmCards(1-tp,sg)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
    local tc=sg:Select(1-tp,1,1,nil):GetFirst()
    if tc then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        sg:RemoveCard(tc)
        Duel.SendtoGrave(sg,REASON_EFFECT)
    end
end

-- Condición de castigo
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c)
        return c:IsFaceup() and (c:IsCode(45231177) or c:ListsCode(45231177))
    end,1,nil)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=eg:GetFirst()
    local atk=tc:GetAttack()
    local def=tc:GetDefense()
    local val=math.max(atk,def)
    local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,nil)
    local bg=g:Filter(function(c) return c:IsAttackBelow(val) or c:IsDefenseBelow(val) end,nil)
    if chk==0 then return #bg>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,bg,1,1-tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    if not tc then return end
    local val=math.max(tc:GetAttack(),tc:GetDefense())
    local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,nil)
    local bg=g:Filter(function(c) return c:IsAttackBelow(val) or c:IsDefenseBelow(val) end,nil)
    if #bg>0 then
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
        local rc=bg:Select(1-tp,1,1,nil)
        Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)
    end
end
