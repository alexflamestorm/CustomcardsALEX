-- Ghost Wurm, The Underworld Alternative
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon & effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Search Ghost Fusion when used as Fusion Material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Special Summon condition: Reveal Ghost Fusion
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.ghfusionfilter,tp,LOCATION_HAND,0,1,nil)
end
function s.ghfusionfilter(c)
    return c:IsCode(100000999) and not c:IsPublic() -- Change 100000999 to the actual ID of "Ghost Fusion"
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end

    -- Reveal Ghost Fusion
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local rf=Duel.SelectMatchingCard(tp,s.ghfusionfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
    if rf then
        Duel.ConfirmCards(1-tp,rf)
    end

    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        local atk=tc:GetAttack()
        local lv=tc:GetLevel()
        if atk<0 then atk=0 end
        -- Set target monster ATK to 0
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)

        -- Special Summon Token
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and lv>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,atk,0,lv,RACE_ZOMBIE,ATTRIBUTE_DARK) then
            local token=Duel.CreateToken(tp,id+1)
            Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Search when used as material for Dragon or Zombie
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetHandler():GetReasonCard()
    return (rc:IsRace(RACE_DRAGON) or rc:IsRace(RACE_ZOMBIE)) and 
        (e:GetHandler():IsLocation(LOCATION_GRAVE) or e:GetHandler():IsLocation(LOCATION_REMOVED))
end
function s.thfilter(c)
    return (c:IsCode(100000999) or (c:IsSetCard(0x99f) and not c:IsCode(id))) and c:IsAbleToHand()
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
