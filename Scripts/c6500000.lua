--Scourge Right Arm of the Forbidden One
local s,id=GetID()
function s.initial_effect(c)
    -- Cambia el nombre en la mano o Cementerio
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetValue(81210420) -- ID de "Right Arm of the Forbidden One"
    c:RegisterEffect(e1)

    -- Descartar para buscar otra pieza de Exodia
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Protección para Exodia y Exodius en el campo
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.indtg)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

-- **Efecto de búsqueda**  
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function s.exodiafilter(c)
    return c:IsCode(81210420) and c:IsAbleToHand()
end

function s.altfilter(c)
    return c:IsCode(81210420) and c:IsFaceup()
end

function s.exodiamonfilter(c)
    return c:IsSetCard(0xde) and c:IsAbleToHand() -- "Exodia" en su nombre
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local has_exodia=Duel.IsExistingMatchingCard(s.exodiafilter,tp,LOCATION_DECK,0,1,nil)
    local has_exodiamon=Duel.IsExistingMatchingCard(s.exodiamonfilter,tp,LOCATION_DECK,0,1,nil)
    local has_alt=Duel.IsExistingMatchingCard(s.altfilter,tp,LOCATION_HAND,0,1,nil)
    
    if chk==0 then return has_exodia or (has_exodiamon and has_alt) end
    
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    
    local has_alt=Duel.IsExistingMatchingCard(s.altfilter,tp,LOCATION_HAND,0,1,nil)
    
    if has_alt then
        local g=Duel.SelectMatchingCard(tp,s.exodiamonfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        local g=Duel.SelectMatchingCard(tp,s.exodiafilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- **Protección para Exodia en el campo**  
function s.indtg(e,c)
    return c:IsSetCard(0xde) or c:IsCode(13893596) -- "Exodia" o "Exodius"
end
