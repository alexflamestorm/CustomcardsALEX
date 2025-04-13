--Curse of Dragon-Magical Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion materials
    Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)

    -- Name becomes "Gaia the Dragon Champion"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetCondition(s.namecon)
    e1:SetValue(66889139) -- Gaia the Dragon Champion
    c:RegisterEffect(e1)

    -- Cannot be targeted
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.namecon)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- Battle damage minimum to 2600
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)

    -- Special Summon destroyed monsters
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.spcon)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)

    -- To store destroyed monsters
    if not s.global_check then
        s.global_check=true
        s[0]=Group.CreateGroup()
        s[1]=Group.CreateGroup()
        s[0]:KeepAlive()
        s[1]:KeepAlive()
        local ge=Effect.CreateEffect(c)
        ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_BATTLE_DESTROYED)
        ge:SetOperation(s.regop)
        Duel.RegisterEffect(ge,0)
    end
end

-- Fusion Materials
function s.matfilter1(c,fc,sumtype,tp)
    return c:IsLevel(5) and c:IsRace(RACE_DRAGON,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
    return c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
end

-- Condition: This card was Fusion Summoned using a Warrior
function s.namecon(e)
    local c=e:GetHandler()
    return c:GetMaterial():IsExists(Card.IsRace,1,nil,RACE_WARRIOR)
end

-- Battle damage becomes 2600 if lower
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    if ep==1-tp and ev<2600 and Duel.GetBattleDamage(ep)>0 then
        Duel.ChangeBattleDamage(ep,2600)
    end
end

-- Register destroyed monsters
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        local rc=tc:GetReasonCard()
        if rc and rc:IsCode(id) and rc:IsControler(tc:GetPreviousControler()) then
            s[tc:GetPreviousControler()]:AddCard(tc)
        end
        tc=eg:GetNext()
    end
end

-- Special Summon them during End Phase
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return s[1-tp]:GetCount()>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=s[1-tp]
    if g:GetCount()==0 then return end
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    if ft<g:GetCount() then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        g=g:Select(tp,ft,ft,nil)
    end
    for tc in aux.Next(g) do
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            -- Change name
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetValue(31560081) -- Gaia the Fierce Knight
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            -- Set ATK to 2300
            local e2=e1:Clone()
            e2:SetCode(EFFECT_SET_ATTACK_FINAL)
            e2:SetValue(2300)
            tc:RegisterEffect(e2)
            -- Negate effects
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e3)
            local e4=e3:Clone()
            e4:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e4)
        end
    end
    Duel.SpecialSummonComplete()
    g:Clear()
end

