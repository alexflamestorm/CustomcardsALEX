--Shin Buster Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,nil,8,2,nil,nil,99) 
    
    -- Alternative Xyz Summon using 1 Level 8 DARK Dragon Tuner
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetValue(SUMMON_TYPE_XYZ)
    e1:SetCondition(s.xyzcon)
    e1:SetOperation(s.xyzop)
    c:RegisterEffect(e1)

    -- Protection if it has a Synchro or Tuner as material
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetCondition(s.protcon)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- Change all monsters to Dragon
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_RACE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
    e3:SetValue(RACE_DRAGON)
    e3:SetCondition(s.protcon)
    c:RegisterEffect(e3)

    -- Special Summon Token
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetCost(s.tokencost)
    e4:SetTarget(s.tokentg)
    e4:SetOperation(s.tokenop)
    c:RegisterEffect(e4)

    -- GY Effect: Add LIGHT "Destruction Sword" monster + Change GY monsters to Dragons
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,{id,1})
    e5:SetTarget(s.gytg)
    e5:SetOperation(s.gyop)
    c:RegisterEffect(e5)
end

-- Condition to Xyz Summon using 1 Level 8 DARK Dragon Tuner
function s.xyzfilter(c,tp)
    return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(8) and c:IsType(TYPE_TUNER) and c:IsFaceup()
end
function s.xyzcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(s.xyzfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    local tc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if tc then
        local g=Group.FromCards(tc)
        Duel.Overlay(c,g)
    end
end

-- Condition for protection and race change
function s.protcon(e)
    local c=e:GetHandler()
    return c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SYNCHRO+TYPE_TUNER)
end

-- Token Summon cost
function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Token Summon
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 
        and Duel.IsPlayerCanSpecialSummonMonster(tp,100000007,0,TYPES_TOKEN_MONSTER,400,300,1,RACE_DRAGON,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0 then return end
    local token=Duel.CreateToken(tp,100000007)
    Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
end

-- GY Effect: Add LIGHT "Destruction Sword" monster + Change GY monsters to Dragons
function s.thfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(SET_DESTRUCTION_SWORD) and c:IsAbleToHand()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    -- All monsters in the GY become Dragons
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_RACE)
    e1:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
    e1:SetValue(RACE_DRAGON)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end