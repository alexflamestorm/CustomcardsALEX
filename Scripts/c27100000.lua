--Forbidden Seal of Necrovalley
local s,id=GetID()
function s.initial_effect(c)
	--This card is unaffected by "Necrovalley"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_NECRO_VALLEY_IM)
	c:RegisterEffect(e0)

	--Activate one of the following effects
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Filters
function s.fusfilter(c)
	return c:IsSetCard(0x2e) and c:IsMonster()
end

function s.fusfilter2(c,e,tp,mg,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x2e) and c:IsLevelAbove(1)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,chkf)
end

function s.ritfilter(c,e,tp)
	return c:IsType(TYPE_RITUAL) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

function s.mfilter(c)
	return c:IsLevelAbove(1) and c:IsMonster() and (c:IsAbleToRemove() or c:IsAbleToGrave())
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,
		Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil),nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		--Fusion Summon
		local chkf=tp
		local mg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		local bg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_GRAVE,0,nil)
		if #bg>0 then
			Duel.ConfirmCards(tp,bg)
			mg:Merge(bg)
		end
		local sg=Duel.GetMatchingGroup(s.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
		if #sg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			if tc then
				local mat=mg:Filter(Card.IsCanBeFusionMaterial,tc,tc)
				if mat then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local fusmat=mat:SelectWithSumEqual(tp,Card.GetFusionLevel,tc:GetLevel(),1,mat:GetCount(),tc)
					tc:SetMaterial(fusmat)
					Duel.SendtoGrave(fusmat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
					Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
					tc:CompleteProcedure()
				end
			end
		end
	else
		--Ritual Summon
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local rc=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if rc then
			local lv=rc:GetLevel()
			local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
			local bg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_GRAVE,0,nil)
			mg:Merge(bg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local mat=mg:SelectWithSumEqual(tp,Card.GetLevel,lv,1,lv)
			if mat then
				for tc in aux.Next(mat) do
					if tc:IsLocation(LOCATION_GRAVE) then
						Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
					else
						Duel.Release(tc,REASON_COST)
					end
				end
				Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
				rc:CompleteProcedure()
			end
		end
	end
end
