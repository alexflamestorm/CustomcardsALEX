-- Red-Eyes Armory
local s,id=GetID()
function s.initial_effect(c)
    -- Activate Ritual Summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Banish from GY to add Red-Eyes monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Ritual Summon logic
function s.ritfilter(c,e,tp,m,exmat)
    return c:IsType(TYPE_RITUAL) and c:IsRace(RACE_DRAGON) and c:IsLevelBelow(8)
        and (c:IsCode(100000201) or true) -- "Lord of the Archfiend" placeholder
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
        and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end

function s.fusfilter(c,lv)
    return c:IsType(TYPE_FUSION) and not c:IsType(TYPE_EFFECT)
        and c:IsLevel(lv) and c:IsAbleToGraveAsCost()
end

function s.refilter(c)
    return c:IsSetCard(0x3b) or (c:IsFusionSetCard(0x3b) and c:IsType(TYPE_FUSION))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,nil,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetRitualMaterial(tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rc=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if not rc then return end
    local lv=rc:GetLevel()
    local fus=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,0,1,nil,lv)
    local matGroup
    if #fus>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.SendtoGrave(fus,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
        matGroup=fus
    else
        mg=mg:Filter(Card.IsCanBeRitualMaterial,rc,rc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        matGroup=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,lv,1,lv,rc)
        if not matGroup then return end
        Duel.ReleaseRitualMaterial(matGroup)
    end
    Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
    rc:CompleteProcedure()

    -- Change name if Red-Eyes or Red-Eyes Fusion Monster used
    if matGroup:IsExists(s.refilter,1,nil) then
        local e1=Effect.CreateEffect(rc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(CARD_REDEYES_B_DRAGON)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        rc:RegisterEffect(e1)
    end
end

-- GY effect: add Red-Eyes monster
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end
function s.thfilter(c)
    return c:IsSetCard(0x3b) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
