-- Red-Eyes Darkness Flare Metal Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c,nil,8,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
    
    -- Gain ATK/DEF
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

    -- Burn and Special Summon Normal
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.cost)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)

    -- Attach card as material
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.matcon)
    e4:SetTarget(s.mattg)
    e4:SetOperation(s.matop)
    c:RegisterEffect(e4)
end

-- Xyz Summon with Red-Eyes Flare Metal Dragon
function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsCode(16178681) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
    if chk==0 then return true end
end

-- Gain 500 ATK/DEF per Dragon in GY
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_DRAGON)*500
end

-- Detach and burn/summon Normal Monster
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.filter(c,e,tp)
    return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local atk=math.floor(tc:GetBaseAttack()/2)
        if atk>0 then
            Duel.Damage(1-tp,atk,REASON_EFFECT)
        end
    end
end

-- Attach a card as material
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    return true
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    local tc=g:GetFirst()
    if tc and not tc:IsImmuneToEffect(e) and e:GetHandler():IsRelateToEffect(e) then
        Duel.Overlay(e:GetHandler(),Group.FromCards(tc))
    end
end

