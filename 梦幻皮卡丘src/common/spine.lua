module ("Spine", package.seeall)

local spine_caches = {}

local basePath = "spine/"
local function createSpinePart(scene, name,part, isloop,scale)
    local json = basePath.."spine_"..scene.."/".."spine_"..scene.."_"..name..".json"
    local atlas = basePath.."spine_"..scene.."/".."spine_"..scene.."_"..name..".atlas"
    if scale == nil then
        skeletonNode = sp.SkeletonAnimation:create(json, atlas)
    else
        skeletonNode = sp.SkeletonAnimation:create(json, atlas,scale)
    end
    local animation_ = part
    skeletonNode:setAnimation(0, animation_, isloop)
    return skeletonNode
end

function spineMix(node,scene,name,part1,part2,isloop1,isloop2,scale)--点击骨骼动画
    -- node:removeAllChildren()
    local json = basePath.."spine_"..scene.."/".."spine_"..scene.."_"..name..".json"
    local atlas = basePath.."spine_"..scene.."/".."spine_"..scene.."_"..name..".atlas"
   
    if scale == nil then
        skeletonNode = sp.SkeletonAnimation:create(json, atlas)
    else
        skeletonNode = sp.SkeletonAnimation:create(json, atlas,scale)
    end

    skeletonNode:setMix(part1, part2, 0.1)
    skeletonNode:setAnimation(0, part1, isloop1)
    skeletonNode:addAnimation(0, part2, isloop2)

    local size = node:getContentSize()
    skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2)))
    skeletonNode:setTag(999)
    node:addChild(skeletonNode)
    return skeletonNode
end

function addTouchEffectSpine(scene,position)
    local json = "spine/spine_main/spine_main_click.json"
    local atlas = "spine/spine_main/spine_main_click.atlas"
    local skeletonNode = sp.SkeletonAnimation:create(json, atlas)
    skeletonNode:setTimeScale(1.2)
    skeletonNode:setAnimation(0, "part1", false)
    -- local node = scene:getParent()
    local pos = scene:convertToNodeSpace(position)
    -- skeletonNode:setPosition(Arp(cc.p(position.x-25, position.y-25)))
    skeletonNode:setPosition(cc.p(pos.x, pos.y))
    scene:addChild(skeletonNode)
end

function addSpine(node, scene, name, part,isloop,scale)
    -- node:removeAllChildren()
    local retSpine = createSpinePart(scene, name, part,isloop,scale)
    local size = node:getContentSize()
    retSpine:setPosition(Arp(cc.p(size.width/2, size.height/2)))
    node:addChild(retSpine)
end

function addToNode(node, spine)
    local size = node:getContentSize()
    local offset = 30
    spine:setPosition(Arp(cc.p(size.width/2, offset)))
    node:addChild(spine)
end

function addPetSpine(node, sid)
    local atlas = string.format(TextureManager.RES_PATH.SPINE_PET, sid) .. ".atlas"
    local json = string.format(TextureManager.RES_PATH.SPINE_PET_JSON, sid) .. ".json"
    local retSpine = sp.SkeletonAnimation:create(json, atlas, 1)
    retSpine:setAnimation(0, "walk", true)
    addToNode(node, retSpine)
end

function addDemonSpine(node, sid)
    local atlas = string.format(TextureManager.RES_PATH.DEMON_SPINE_ATLAS, sid)
    local json = string.format(TextureManager.RES_PATH.DEMON_SPINE_JSON, sid)
    local retSpine = sp.SkeletonAnimation:create(json, atlas, 1)
    retSpine:setAnimation(0, "breath", true)
    addToNode(node, retSpine)
end

function loadSpines(spineList, onComplete)
    if #spineList < 1 then
        return
    end
    local idx = 1
    local maxIdx = #spineList
    local co = coroutine.create(function()
    end)
end

function destroySpines(spineList)
end

function getSpineCache(spineName)
end