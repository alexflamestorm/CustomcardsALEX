--Summoning of The Skull Archfiends
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_RITUAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Filters
function s.archfiendMatFilter(c)
    return c:IsRace(RACE_FIEND) and c:IsSetCard(0x23) and c:IsAttack(2500) and c:IsDefense(1200)
end

-- Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    return true
end

-- Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,nil,TYPE_FUSION)
    local b2=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,TYPE_RITUAL)
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
        Duel.SelectOption(tp,aux.Stringid(id,0))
        op=0
    elseif b2 then
        Duel.SelectOption(tp,aux.Stringid(id,1))
        op=1
    else
        return
    end

    if op==0 then
        -- Fusion Summon
        local chkf=tp
        local mat1=Duel.GetMatchingGroup(Card.IsOnField,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
        local mat2=Duel.GetMatchingGroup(s.archfiendMatFilter,tp,LOCATION_DECK,0,nil)
        local mg=mat1:Clone()
        mg:Merge(mat2)
        local sg=Duel.GetMatchingGroup(Auxiliary.FusionMonsterFilter(Card.IsRace,RACE_FIEND),tp,LOCATION_EXTRA,0,nil)
        if sg:GetCount()>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local fus=sg:Select(tp,1,1,nil):GetFirst()
            local mat=Fusion.SelectFusionMaterial(tp,fus,mg,nil,chkf)
            if mat then
                local deckmat=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
                Duel.SendtoGrave(deckmat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
                mat:Sub(deckmat)
                Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
                Duel.SpecialSummon(fus,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
                fus:CompleteProcedure()
            end
        end
    else
        -- Ritual Summon
        local rg=Duel.GetMatchingGroup(aux.RitualMonsterFilter(Card.IsRace,RACE_FIEND),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
        if #rg==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local rc=rg:Select(tp,1,1,nil):GetFirst()
        local lv=rc:GetLevel()
        local handmat=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
        local deckmat=Duel.GetMatchingGroup(s.archfiendMatFilter,tp,LOCATION_DECK,0,nil)
        handmat:Merge(deckmat)
        Auxiliary.GCheckAdditional=aux.RitualCheckAdditional(rc,lv,"Equal")
        local mat=handmat:SelectWithSumEqual(tp,Card.GetRitualLevel,lv,1,handmat:GetCount(),rc)
        Auxiliary.GCheckAdditional=nil
        if mat then
            local deckmat=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
            Duel.SendtoGrave(deckmat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
            mat:Sub(deckmat)
            Duel.ReleaseRitualMaterial(mat)
            Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
            rc:CompleteProcedure()
        end
    end
end
