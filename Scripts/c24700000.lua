-- Nitro Over Warrior
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon procedure
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)

    -- Destroy and Special Summon Nitro monster from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.dscon)
    e1:SetTarget(s.dstg)
    e1:SetOperation(s.dsop)
    c:RegisterEffect(e1)

    -- On destruction, Special Summon Nitro Synchro + Set Spell
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOFIELD)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Condition: This card is battling
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetBattleTarget(e:GetHandler())~=nil
end

-- Target a Nitro monster in Deck and destroy the battle target
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.nitfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.nitfilter(c,e,tp)
    return c:IsSetCard(0x23) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetBattleTarget(c)
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToBattle() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.nitfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- Check if destroyed by battle or effect
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end

-- Target Synchro Nitro monster in Extra Deck and set Spell
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x23) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
            and Duel.GetLocationCountFromEx(tp)>0
            and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.setfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.SSet(tp,sg)
            -- Cannot activate this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_ACTIVATE)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetValue(s.aclimit)
            e1:SetLabelObject(sg:GetFirst())
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
function s.aclimit(e,re,tp)
    return re:GetHandler()==e:GetLabelObject()
end
