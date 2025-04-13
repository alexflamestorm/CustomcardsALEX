
--Lavalval Dragon Lord
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Synchro Summon
    Synchro.AddProcedure(c,Synchro.Tuner(nil),1,1,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),1,99)
    
    -- SS Laval monsters from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.sscon)
    e1:SetTarget(s.sstg)
    e1:SetOperation(s.ssop)
    c:RegisterEffect(e1)

    -- Revive + destroy column
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.rvcon)
    e2:SetTarget(s.rvtg)
    e2:SetOperation(s.rvop)
    c:RegisterEffect(e2)
end

-- Effect 1: On Synchro Summon
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.filter(c,e,tp)
    return c:IsSetCard(0x39) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        -- Restrict Extra Deck to FIRE monsters
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_FIRE)
end

-- Effect 2: Revive + destroy column
function s.rvcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.rvfilter(c)
    return c:IsDefense(200) and c:IsAbleToRemoveAsCost()
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_GRAVE,0,1,nil)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=Duel.SelectMatchingCard(tp,s.rvfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_COST)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Destroy cards in same column
        local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
        local colg=Group.CreateGroup()
        for tc in aux.Next(g) do
            if Duel.IsColumn(tc,c:GetColumnGroup()) then
                colg:AddCard(tc)
            end
        end
        if #colg>0 then
            Duel.Destroy(colg,REASON_EFFECT)
        end
    end
end
