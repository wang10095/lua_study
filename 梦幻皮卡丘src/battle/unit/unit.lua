require "model/model"
require "model/pet"

Unit = class("Unit", function(parameters)
	return Model:create("Unit", {
	   index = 0,
	   type = 1,
	   mid = 0,
	   sprite = {},
	   spine = {}
	})
end)

Unit.UNIT_TYPE = {
	UNIT_PET = 1,
	UNIT_DEMON = 2, 
	UNIT_BOSS = 3
}

Unit.SPINE_TYPE = {
	BREATH = "breath",
	ATTACK = "attack",
	CAST = "cast",
	HIT = "hit",
	WALK = "walk",
}

function Unit:create(type)
end

function Unit:moveTo(pos)
end

function Unit:attack()
end

function Unit:attacked()
end

function Unit:die()
end