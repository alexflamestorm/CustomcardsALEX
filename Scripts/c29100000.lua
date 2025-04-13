--Battlin' Boxer Challenger
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    Link.AddProcedure(c,nil,2,2,s.matfilter)
    c:EnableReviveLimit()

    -- GY send and ATK gain
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.lkcon)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- Revive and Xyz Summon at End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.rescon)
    e2:SetOperation(s.resop)
    c:RegisterEffect(e2)
end

-- Link Material must be FIRE
function s.matfilter(g,lc,sumtype,tp)
    return g:IsExists(Card.IsAttribute,2,nil,ATTRIBUTE_FIRE)
end

-- Check for Link Summon
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Send FIRE to GY and gain ATK
function s.tgfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local atk=g:GetFirst():GetAttack()
        if atk<0 then atk=0 end
        -- Set ATK = sent monster + 100
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(atk+100)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- Check if destroyed and sent to GY
function s.rescon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY)
end

-- During End Phase, revive and Xyz Summon
function s.resop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c)
    if not c:IsRelateToEffect(e) or Duel.GetTurnPlayer()~=tp then return end
    -- Schedule for End Phase
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetLabelObject(c)
    e1:SetOperation(s.endop)
    Duel.RegisterEffect(e1,tp)
end

function s.xyzfilter(c,e,tp,mc)
    return c:IsSetCard(0x84) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
        and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.endop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject()
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.BreakEffect()
        local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
            if xyz then
                Duel.XyzSummon(tp,xyz,c)
            end
        end
    end
end
