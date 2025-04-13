-- Red-Eyes Darkness Flare Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon
    Xyz.AddProcedure(c,nil,9,2,s.xyzfilter,aux.Stringid(id,0),3,s.xyzop)
    c:EnableReviveLimit()
    
    -- Cannot be targeted or destroyed by card effects while it has material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.indcon)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- Destroy 1 monster & Inflict 1200 damage if opponent Special Summons
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

-- Allow Xyz Summon using a "Red-Eyes" monster that was Special Summoned from the Extra Deck
function s.xyzfilter(c,tp,xyzc)
    return c:IsSetCard(0x3b) and c:IsSummonLocation(LOCATION_EXTRA) 
end
function s.xyzop(e,tp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end

-- Condition for protection effects
function s.indcon(e)
    return e:GetHandler():GetOverlayCount()>0
end

-- Check if opponent Special Summoned a monster
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp
end

-- Target 1 monster on the field for destruction
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end

-- Destroy the targeted monster and inflict 1200 damage
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
            Duel.Damage(1-tp,1200,REASON_EFFECT)
        end
    end
end
