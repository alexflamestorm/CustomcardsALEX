-- Cyberdark Nova
-- Editado por DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Invocación por Xyz (Edit-DrakayStudios)
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),4,2)
    c:EnableReviveLimit()

    -- Equip up to 3 Dragon/Machine from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.eqcon)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Detach 1, Special Summon 1 equipped monster and add Cyberdark S/T
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Destruction Replacement
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.reptg)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end

-- Xyz Summon condition
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

-- Equip operation
function s.eqfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_MACHINE) or c:IsRace(RACE_DRAGON))
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_GRAVE,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local sg=g:Select(tp,1,3,nil)
    for tc in aux.Next(sg) do
        Duel.Equip(tp,tc,c,true,true)
        -- Register flag to know it was equipped by effect
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
        -- Equip limit
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(1)
        tc:RegisterEffect(e1)
    end
end

-- Cost to detach 1
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Target: 1 equipped monster + optional Cyberdark S/T
function s.eqmonfilter(c)
    return c:IsFaceup() and c:GetFlagEffect(id)>0 and c:GetEquipTarget()
end
function s.cdstfilter(c)
    return c:IsSetCard(0x4093) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local eqg=Duel.GetMatchingGroup(s.eqmonfilter,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return #eqg>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local eqg=Duel.GetMatchingGroup(s.eqmonfilter,tp,LOCATION_SZONE,0,nil)
    if #eqg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=eqg:Select(tp,1,1,nil):GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Optionally add Cyberdark S/T
        local g=Duel.GetMatchingGroup(s.cdstfilter,tp,LOCATION_GRAVE,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
    end
end

-- Destruction Replacement
function s.repfilter(c)
    return c:GetFlagEffect(id)>0 and c:GetEquipTarget()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_SZONE,0,1,nil) end
    return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_SZONE,0,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
