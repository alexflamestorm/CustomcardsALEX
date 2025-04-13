-- Curse of Dragonmist
local s,id=GetID()
function s.initial_effect(c)
    -- Treated as Normal if used as Fusion Material
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TYPE_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCondition(s.normcon)
    e0:SetValue(TYPE_NORMAL)
    c:RegisterEffect(e0)

    -- Protect Gaia/Champion by discard
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_HAND)
    e1:SetTarget(s.reptg)
    e1:SetValue(s.repval)
    e1:SetOperation(s.repop)
    c:RegisterEffect(e1)

    -- Wipe field on sent to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Fusion Summon from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(aux.exccon)
    e3:SetTarget(s.fustg)
    e3:SetOperation(s.fusop)
    c:RegisterEffect(e3)
end

-- Normal if used as fusion material
function s.normcon(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE) and c:IsReason(REASON_FUSION)
end

-- Destroy replacement effect
function s.repfilter(c,tp)
    return c:IsFaceup() and (c:IsCode(66889139) or c:IsSetCard(0xbd)) and c:IsControler(tp)
        and c:IsOnField() and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
        and e:GetHandler():IsDiscardable() end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
end

-- Destroy opponent's monsters if sent to GY
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,66889139),tp,LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstMatchingCard(aux.FaceupFilter(Card.IsCode,66889139),tp,LOCATION_MZONE,0,nil)
    if tc then
        local g=Duel.GetMatchingGroup(function(c,atk) return c:IsFaceup() and c:GetDefense()<atk end,
            tp,0,LOCATION_MZONE,nil,tc:GetAttack())
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end

-- Fusion summon using this card from GY
function s.fusfilter(c,e,tp,mg)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,tp)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
        return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
    local sc=sg:GetFirst()
    if sc then
        local mat=mg:Filter(Card.IsCanBeFusionMaterial,sc,sc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local fusmat=mat:SelectWithSumEqual(tp,Card.GetFusionLevel,sc:GetLevel(),1,99,sc)
        if #fusmat>0 then
            Duel.Remove(fusmat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            sc:SetMaterial(fusmat)
            Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            sc:CompleteProcedure()
        end
    end
end
