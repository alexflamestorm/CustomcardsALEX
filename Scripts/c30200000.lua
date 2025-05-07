--Heroic Champion - Achilles (Custom)
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x6f),4,2)
    c:EnableReviveLimit()

    -- Quick Effect: Destroy 1 card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Rank-Up into Heroic Champion - Excalibur
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.rkcon)
    e2:SetCost(s.rkcost)
    e2:SetOperation(s.rkop)
    c:RegisterEffect(e2)
end

-- E1: Destroy 1 opponent card
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- E2: Rank-Up into Excalibur
function s.rkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.rkfilter(c)
    return c:IsSetCard(0x6f) and c:IsAbleToRemove()
end
function s.rkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.rkfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.IsExistingMatchingCard(s.rkfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local h=Duel.SelectMatchingCard(tp,s.rkfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    h:Merge(g)
    Duel.Remove(h,POS_FACEUP,REASON_COST)
end
function s.rkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp,tp,c)<=0 then return end
    local sc=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_EXTRA,0,nil,82956492):GetFirst() -- Heroic Champion - Excalibur
    if sc then
        Duel.SpecialSummonRule(tp,sc,SUMMON_TYPE_XYZ,e,c,1)
        sc:SetMaterial(Group.FromCards(c))
        Duel.Overlay(sc,Group.FromCards(c:GetOverlayGroup()))
        Duel.Overlay(sc,Group.FromCards(c))
        sc:SetStatus(STATUS_SPSUMMON_TURN,true)
        sc:CompleteProcedure()
        -- Set ATK to 4000
        local e1=Effect.CreateEffect(sc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(4000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        sc:RegisterEffect(e1)
    end
end
