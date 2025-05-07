--Heroic Champion of Battlin' Boxer - Excalibur King Dempsey
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Xyz Summon procedure
    Xyz.AddProcedure(c,nil,5,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
    
    -- Limit to 1 on field
    c:SetUniqueOnField(1,0,id)
    
    -- Cannot be used as Xyz Material
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetValue(1)
    c:RegisterEffect(e0)

    -- Unaffected by opponent's effects during Battle Phase
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetCondition(s.battlecon)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- All Warriors gain 800 ATK
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
    e2:SetValue(800)
    c:RegisterEffect(e2)

    -- Double ATK when opponent activates a card or effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.doubleatk)
    c:RegisterEffect(e3)

    -- Set up to 4 Spell/Traps on Xyz Summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.setcon)
    e4:SetOperation(s.setop)
    c:RegisterEffect(e4)

    -- Negate effect targeting/destroying card
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,3))
    e5:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.negcon)
    e5:SetCost(s.negcost)
    e5:SetOperation(s.negop)
    c:RegisterEffect(e5)
end

function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(tp) and lc:IsType(TYPE_XYZ)
end
function s.xyzop(e,tp,chk)
    return chk==true
end

function s.battlecon(e)
    local ph=Duel.GetCurrentPhase()
    return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.doubleatk(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(c:GetAttack()*2)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.setfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsSetCard(0x6f) or c:IsSetCard(0x84)) and c:IsSSetable()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sg=g:Select(tp,1,math.min(4,#g),nil)
        Duel.SSet(tp,sg)
    end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainNegatable(ev) and (re:IsHasCategory(CATEGORY_DESTROY) or re:IsHasProperty(EFFECT_FLAG_CARD_TARGET))
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if tc then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(re:GetHandler(),REASON_EFFECT)
    end
end
