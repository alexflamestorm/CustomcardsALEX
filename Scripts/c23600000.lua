-- Rank-Up-Magic Constellar Force
local s,id=GetID()
function s.initial_effect(c)
    -- Rank-Up
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    -- GY effect: copy detach effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

function s.filter(c,e,tp)
    local rk=c:GetRank()
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
        and Duel.IsExistingMatchingCard(s.rkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
end

function s.rkfilter(c,e,tp,mc,rk)
    return c:IsSetCard(0x53) and c:IsType(TYPE_XYZ)
        and c:GetRank()==rk and mc:IsCanBeXyzMaterial(c)
        and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
    local rk=tc:GetRank()+1
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.rkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,rk)
    local sc=g:GetFirst()
    if sc then
        local mg=tc:GetOverlayGroup()
        if #mg>0 then
            Duel.Overlay(sc,mg)
        end
        sc:SetMaterial(Group.FromCards(tc))
        Duel.Overlay(sc,Group.FromCards(tc))
        Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end

-- GY effect
function s.xyzgyfilter(c)
    return c:IsSetCard(0x53) and c:IsType(TYPE_XYZ) and c:IsAbleToGraveAsCost()
        and c:GetEffectCount(EFFECT_TYPE_IGNITION)>0
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_XYZ) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_XYZ)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsSetCard(0x53) and tc:IsType(TYPE_XYZ) then
        local effs={tc:GetCardEffect(EFFECT_TYPE_IGNITION)}
        for _,eff in ipairs(effs) do
            if eff:GetOperation() then
                eff:GetOperation()(e,tp,eg,ep,ev,re,r,rp)
                break
            end
        end
    end
end
