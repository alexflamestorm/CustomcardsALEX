-- Flame Swordsman - Fighting Ferocious
local s,id=GetID()
function s.initial_effect(c)
    -- Efecto al ser Invocado de manera Especial
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- Efecto al usarse como Material de Fusión
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.eqcon)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end

-- **Efecto 1: Enviar 1 "Salamandra" o "Flame Swordsman" del Deck al GY**
function s.tgfilter(c)
    return c:IsCode(32268901, 45231177) and c:IsAbleToGrave() -- Salamandra o Flame Swordsman
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

-- **Efecto 2: Equipar un Dragón de Fuego al ser Material de Fusión**
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return r==REASON_FUSION and eg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) and eg:IsExists(Card.IsRace,1,nil,RACE_WARRIOR)
end

function s.eqfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=e:GetHandler():GetReasonCard()
    if chk==0 then return tc and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler():GetReasonCard()
    if not tc or not tc:IsFaceup() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.Equip(tp,g:GetFirst(),tc)
        -- Efecto del Equip
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_EQUIP)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetValue(s.efilter)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        g:GetFirst():RegisterEffect(e1)

        local e2=Effect.CreateEffect(tc)
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
        e2:SetRange(LOCATION_SZONE)
        e2:SetCountLimit(1)
        e2:SetTarget(s.bantg)
        e2:SetOperation(s.banop)
        g:GetFirst():RegisterEffect(e2)
    end
end

function s.efilter(e,re)
    return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local tc=c:GetEquipTarget()
    if chk==0 then return tc and Duel.IsExistingMatchingCard(Card.IsAttackAbove,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack()) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=c:GetEquipTarget()
    if not tc then return end
    local g=Duel.GetMatchingGroup(Card.IsAttackAbove,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        local ct=#g
        if ct>0 then
            local e1=Effect.CreateEffect(tc)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500*ct)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
    Duel.SendtoGrave(c,REASON_EFFECT)
end
