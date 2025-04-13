--Lightning Buster, Destruction Swordspear
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,1,1)

    -- Equip to "Buster Blader" or Unequip
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Prevent opponent from banishing cards while equipped
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_ONFIELD+LOCATION_GRAVE,0)
    e2:SetCondition(s.bancon)
    c:RegisterEffect(e2)

    -- Protection effect
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end

-- Material restriction: 1 non-Link "Destruction Sword" monster
function s.matfilter(c,scard,sumtype,tp)
    return c:IsSetCard(SET_DESTRUCTION_SWORD) and not c:IsType(TYPE_LINK,scard,sumtype,tp)
end

-- Equip or Unequip Targeting
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local eqp=c:IsEquipped() and c:GetEquipTarget() or nil
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,SET_BUSTER_BLADER),tp,LOCATION_MZONE,0,1,eqp) or (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if c:IsLocation(LOCATION_SZONE) then
        -- Unequip and Special Summon
        local tc=c:GetEquipTarget()
        if tc then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        end
    else
        -- Equip to "Buster Blader"
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local tg=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsSetCard,SET_BUSTER_BLADER),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if tg then
            Duel.Equip(tp,c,tg)
        end
    end
end

-- Condition to prevent banishing
function s.bancon(e)
    return e:GetHandler():IsLocation(LOCATION_SZONE) and e:GetHandler():GetEquipTarget()
end

-- Protection effect
function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and e:GetHandler():IsEquipped() end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsEquipped() then return end
    Duel.SendtoGrave(c,REASON_EFFECT)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_DESTRUCTION_SWORD)
    local count=g:GetClassCount(Card.GetCode)
    Duel.Damage(1-tp,count*400,REASON_EFFECT)
end