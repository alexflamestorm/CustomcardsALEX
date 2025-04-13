-- Nordic Relic Ultima - Mjollnir
local s,id=GetID()
function s.initial_effect(c)
    -- Activar: Invocar desde el GY y equipar
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Efecto de batalla: El oponente no puede activar cartas/efectos hasta el final del Damage Step
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetCondition(s.batcon)
    e2:SetValue(s.aclimit)
    c:RegisterEffect(e2)

    -- Si es enviada al GY mientras está equipada a un "Aesir", busca 1 "Nordic Relic"
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

-- Seleccionar objetivo para revivir
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x42,0x43) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

-- Revivir y equipar
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) then
        Duel.Equip(tp,c,tc)
        -- Hacer que la carta equipada sea un Equip Spell
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetValue(s.eqlimit)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        -- Negar efectos si es "Nordic"
        if tc:IsSetCard(0x42) then
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
    end
end
function s.eqlimit(e,c)
    return c:IsSetCard(0x42,0x43)
end

-- Condición para restringir activaciones en batalla
function s.batcon(e)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and Duel.GetAttacker()==ec
end
function s.aclimit(e,re,tp)
    return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_FZONE)
end

-- Si se manda al GY mientras está equipada a un "Aesir", busca una "Nordic Relic"
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetPreviousEquipTarget()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and ec and ec:IsSetCard(0x43)
end
function s.thfilter(c)
    return c:IsSetCard(0x4b) and not c:IsCode(id) and c:IsAbleToHand()
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

