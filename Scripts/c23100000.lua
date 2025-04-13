-- Blue-Eyes Prime Silver Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon
    Xyz.AddProcedure(c,nil,8,3)
    c:EnableReviveLimit()

    -- Unaffected if Blue-Eyes White Dragon is material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- Attack again after battle
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetCondition(s.atkcon)
    e2:SetCost(s.atkcost)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Main Phase 2 effect: Revive Blue-Eyes and search
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.mp2con)
    e3:SetCost(s.mp2cost)
    e3:SetTarget(s.mp2tg)
    e3:SetOperation(s.mp2op)
    c:RegisterEffect(e3)

    -- track detached material count
    s[0]=0
end

-- Check if Blue-Eyes White Dragon is material
function s.immcon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,89631139)
end
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Attack again condition
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and Duel.GetTurnPlayer()==tp and e:GetHandler():GetBattledGroupCount()>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
    if s[tp]==nil then s[tp]=0 end
    s[tp]=s[tp]+1
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetValue(aux.ChangeBattleDamageHalve)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end

-- Main Phase 2 revive condition
function s.mp2con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_MAIN2 and s[tp] and s[tp]>0
end
function s.mp2cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(s[tp])
end
function s.spfilter(c)
    return c:IsSetCard(0xdd) and not c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.mp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetLabel()
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.mp2op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=e:GetLabel()
    if not c:IsRelateToEffect(e) then return end
    Duel.Destroy(c,REASON_EFFECT)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        Duel.BreakEffect()
        local opt=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_DECK,0,1,1,nil,94820406,86240887)
        if #opt>0 then
            Duel.SendtoHand(opt,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,opt)
        end
    end
    s[tp]=0 -- reset count
end
