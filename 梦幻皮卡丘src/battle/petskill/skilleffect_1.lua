SkillEffect_1 = class("SkillEffect_1")

function SkillEffect_1:play(caller)
	print("play skill effect 1", caller.targets, caller.targets[1])
	local atlas = string.format(TextureManager.RES_PATH.SPINE_SKILL_EFFECT_ATLAS, 1)
	local json = string.format(TextureManager.RES_PATH.SPINE_SKILL_EFFECT_JSON, 1)
	local winSize = cc.Director:getInstance():getWinSize()
	local startPos = cc.p(winSize.width, winSize.height)

	for i in pairs(caller.targets) do
		target = caller.targets[i]
		local targetPos = cc.pAdd(cc.pAdd(target:getPosition(), Constants.ENEMY_POS), cc.p(40, 0))
		local travelTime = cc.pGetDistance(startPos, targetPos) * 0.5/Constants.PET_SPEED
		local angle = -math.deg(math.atan((targetPos.y - startPos.y)/(targetPos.x - startPos.x)))
		local spine = sp.SkeletonAnimation:create(json, atlas, 1)
		spine:setPosition(startPos)
		spine:setAnimation(0, "part1", true)
		caller.container:addChild(spine)
		spine:setRotation(angle)
		local se = self
		local hitHandler = function()
			local t = target
			return function(sender)
					spine:setRotation(0)
					spine:setAnimation(0, "part2", false)
					print("to hit target")
					caller:hitTargets({t})
				end
		end
		spine:runAction(cc.Sequence:create(
							cc.DelayTime:create((i - 1)*0.25),
							cc.MoveTo:create(travelTime, targetPos),
							cc.CallFunc:create(hitHandler())
						))
	end
end

function SkillEffect_1:hitTarget(target)
end

return SkillEffect_1:new()