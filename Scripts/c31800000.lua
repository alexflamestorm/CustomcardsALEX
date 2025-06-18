--Earthbound Servant Geo Malev-pholis
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.matfilter,aux.FilterBoolFunction(Card.IsType,TYPE_FUSION))

    -- Special Summon 2 Earthbound from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Cannot be targeted by card effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.etarget)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- Shuffle GY/banish & apply effects
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCondition(aux.bdocon)
    e3:SetTarget(s.bdtg)
    e3:SetOperation(s.bdop)
    c:RegisterEffect(e3)

    -- Revival if leaves field by opponent
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.revcon)
    e4:SetTarget(s.revtg)
    e4:SetOperation(s.revop)
    c:RegisterEffect(e4)
end

function s.matfilter(c)
    return c:IsSetCard(0x21) and not c:IsType(TYPE_FUSION)
end

-- Special Summon 2 from GY
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
    if #g>=2 then
        local sg=g:Select(tp,2,2,nil)
        for tc in sg:Iter() do
            if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_SET_ATTACK_FINAL)
                e1:SetValue(math.floor(tc:GetBaseAttack()/2))
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                -- Destroy during opponent’s next End Phase
                local e2=Effect.CreateEffect(e:GetHandler())
                e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
                e2:SetCode(EVENT_PHASE+PHASE_END)
                e2:SetCountLimit(1)
                e2:SetCondition(s.descon)
                e2:SetOperation(s.desop)
                e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
                e2:SetLabelObject(tc)
                Duel.RegisterEffect(e2,tp)
            end
        end
        Duel.SpecialSummonComplete()
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    return tc and tc:IsOnField()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsOnField() then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- Cannot target Earthbound
function s.etarget(e,c)
    return c:IsSetCard(0x21)
end

-- Shuffle and apply bonus
function s.bdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g1=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
    local g2=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    if chk==0 then return #g1+#g2>0 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,#g1+#g2,PLAYER_ALL,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
    local g2=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    local total=g1:Clone()
    total:Merge(g2)
    if #total>0 then
        Duel.SendtoDeck(total,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        local ct1=g1:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
        local ct2=g2:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
        if ct2>0 then
            Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
        end
        if ct1>0 then
            Duel.Draw(tp,2,REASON_EFFECT)
        end
    end
end

-- Revival
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return rp==1-tp and c:IsPreviousControler(tp)
end
function s.revfilter(c,e,tp)
    return c:IsSetCard(0x21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
