-- Red-Eyes Dark Burning Meteor
local s,id=GetID()
function s.initial_effect(c)
    -- Destroy opponent's monsters
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Fusion Summon from GY
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.fustg)
    e2:SetOperation(s.fusop)
    c:RegisterEffect(e2)
end

-- Cost: Tribute 1 "Red-Eyes" monster
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroupCost(tp,aux.FilterFaceupFunction(Card.IsSetCard,0x3b),1,false,nil,nil) end
    local g=Duel.SelectReleaseGroupCost(tp,aux.FilterFaceupFunction(Card.IsSetCard,0x3b),1,1,false,nil,nil)
    e:SetLabelObject(g:GetFirst())
    Duel.Release(g,REASON_COST)
end

-- Target & Destroy Opponent's Monsters
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=e:GetLabelObject()
    local atk=tc:GetBaseAttack()
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    local g=nil
    if tc:IsType(TYPE_FUSION) then
        g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    else
        g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetAttack()<=atk end,tp,0,LOCATION_MZONE,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

-- Destroy Operation
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    local atk=tc:GetBaseAttack()
    local g=nil
    if tc:IsType(TYPE_FUSION) then
        g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    else
        g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetAttack()<=atk end,tp,0,LOCATION_MZONE,nil)
    end
    Duel.Destroy(g,REASON_EFFECT)
end

-- Fusion Summon from GY
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAbleToGrave),tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) 
        and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsAbleToGrave),tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if #g1>0 and #g2>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local mg=g1:Select(tp,1,99,nil)
        Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g2:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
        if tc then
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end
