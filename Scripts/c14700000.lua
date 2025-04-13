-- Doriado, Elemental Spirit of the Voiceless Voice
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Ritual Summon con "Sprite's Blessing"
    Ritual.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),nil,99,nil,nil,nil,nil,aux.Stringid(id,0))

    -- Tratamiento como todos los Atributos y como Guerrero
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_DARK+ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_ADD_RACE)
    e2:SetValue(RACE_WARRIOR)
    c:RegisterEffect(e2)

    -- Gana DEF igual a la DEF de todos los "Voiceless Voice" y Ritual LIGHT que controlas
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.defval)
    c:RegisterEffect(e3)

    -- Agregar "Barrier of the Voiceless Voice" o un monstruo "Voiceless Voice"
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.thcon)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)

    -- Invocar "Lo, the Prayers of the Voiceless Voice"
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+1)
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end

-- Ganar DEF basado en "Voiceless Voice" y Rituales LIGHT
function s.defval(e,c)
    local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsRace,RACE_SPELLCASTER),c:GetControler(),LOCATION_MZONE,0,nil)
    return g:GetSum(Card.GetDefense)
end

-- Condición para buscar si fue Invocado por Ritual
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.thfilter1(c)
    return c:IsCode(100000200) and c:IsAbleToHand() -- "Barrier of the Voiceless Voice"
end
function s.thfilter2(c)
    return c:IsSetCard(0x2a7) and c:IsMonster() and c:IsAbleToHand() -- "Voiceless Voice"
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
        or (Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,100000201) -- "Barrier of the Voiceless Voice"
        and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=nil
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,100000201) then
        g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK,0,1,1,nil)
    else
        g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter1),tp,LOCATION_DECK,0,1,1,nil)
    end
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Condición para invocar "Lo, the Prayers of the Voiceless Voice"
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,100000202) -- "Lo, the Prayers of the Voiceless Voice"
end
function s.spfilter(c,e,tp)
    return c:IsCode(100000202) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        -- Lo es inmune a efectos del oponente
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetValue(s.efilter)
        e1:SetOwnerPlayer(tp)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
function s.efilter(e,re)
    return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
