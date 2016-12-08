--
-- Author: hapigames
-- Date: 2014-12-12 11:33:33
--
require "AudioEngine"
module("MusicManager", package.seeall)

music_status = nil
effect_status = nil

MUSIC_PATH =  --音乐路径
{
	battle = "music/music/music_battle.mp3",
	login = "music/music/music_login.mp3",
	pyramid = "music/music/music_pyramid.mp3",
	main = "music/music/music_main.mp3",		
}

EFFECT_PATH = --音效路劲
{
	battle_defeat = "music/effect/effect_battle_defeat.mp3",
	battle_victory = "music/effect/effect_battle_victory.mp3",
	breed = "music/effect/effect_breed.mp3",
	btn_click = "music/effect/effect_btn.mp3",
	capture_fail = "music/effect/capture_fail.mp3",
	capture_succ = "music/effect/capture_succ.mp3",
	diamond = "music/effect/effect_diamond.mp3",
	dice = "music/effect/effect_dice.mp3",
	wild = "music/effect/drawcard.mp3",
	wild_item = "music/effect/wild_item.mp3",
	cat_run = "music/effect/cat_run.mp3",
	cat_attacked = "music/effect/cat_attacked.mp3",
	chest_open = "music/effect/chest_open.mp3",
	chest_drop = "music/effect/chest_drop.mp3",
	chest_hit = "music/effect/chest_hit.mp3",
	matrix_pikaqiu = "music/effect/matrix_pikaqiu.mp3",
	--消除
	eliminate_horizontal = "music/effect/effect_eliminate_horizontal.mp3",
	eliminate_vertical = "music/effect/effect_eliminate_horizontal.mp3",
	eliminate_bomb = "music/effect/effect_eliminate_bomb.mp3",
	eliminate_move = "music/effect/effect_eliminate_move.mp3",
	eliminate_once = "music/effect/effect_eliminate_one.mp3",
	amazing = "music/effect/amazing.mp3",
	good = "music/effect/good.mp3",
	wonderful = "music/effect/wonderful.mp3",

	goldhand = "music/effect/goldhand.mp3",
	right_tip = "music/effect/effect_right.mp3",
	error_tip = "music/effect/effect_error.mp3",
	start_game = "music/effect/effect_start_game.mp3",
	turntable = "music/effect/effect_turntable.mp3",
	upstar = "music/effect/effect_upstar.mp3",
	die = "music/effect/pet_die.mp3",
	effect_pet_hit = "music/effect/effect_pet_hit.mp3",
}

EFFECT_ITEM = {  
    play = 1,       -- "play background music"
    stop = 2,       -- "stop background music"
    pause = 3,      -- "pause background music"
    resume = 4,     -- "resume background music"

    REWINDMUSIC = 5,     -- "rewind background music"
    ISMUSICPLAY = 6,     -- "is background music playing"
    playEffect = 7,      -- "play effect"
    playEffect_loop = 8,   -- "play effect repeatly"
    stopEffect = 9,      -- "stop effect"
    NULOADEFFECT = 10,   -- "unload effect"

    ADDMUSICVOLUME = 11, -- "add background music volume"
    SUBMUSICVOLUME = 12, -- "sub background music volume"

    ADDEFFECTVOLUME = 13,-- "add effects volume"
    SUBEFFECTVOLUME = 14,-- "sub effects volume"
    
    PAUSEEFFECT = 15,    -- "pause effect"
    RESUMEEFFECT = 16,   -- "resume effect"

    pauseAllEffect = 17, -- "pause all effects"
   	resumeAllEffect = 18,-- "resume all effects"
    STOPALLEFFECT = 19   -- "stop all effects"   
 }

local musicmanager = cc.SimpleAudioEngine:getInstance()
local res = {}

function getMusicStatus()
	music_status = tonumber(Utils.userDefaultGet("Pokemon_Music_Status",true))
	if music_status == nil then
		Utils.userDefaultSet("Pokemon_Music_Status",'1',true)
		music_status = 1
	end

	return music_status
end

function getEffectStatus( )

	effect_status = tonumber(Utils.userDefaultGet("Pokemon_Effect_Status",true))
	if effect_status == nil then
		Utils.userDefaultSet("Pokemon_Effect_Status",'1',true)
		effect_status = 1
	end
	
	return effect_status
end

function setMusicStatus( value )
	if value then
		Utils.userDefaultSet("Pokemon_Music_Status",tostring(value),true)
	end
	music_status = value
end
function setEffectStatus( value )
	if value then
		Utils.userDefaultSet("Pokemon_Effect_Status",tostring(value),true)
	end
	effect_status = value
end

local function createMusic(cmd,music_path)
	
end
function ManagerMusic(cmd,music_path,isloop)

	local path = MUSIC_PATH[music_path]
	local tag = EFFECT_ITEM[cmd]
	-- musicmanager:preloadMusic(path)
	if tag == EFFECT_ITEM.PLAYMUSIC then
		musicmanager:playMusic(path,isloop)
	elseif tag == EFFECT_ITEM.STOPMUSIC then
		musicmanager:stopMusic(path) 
	elseif tag == EFFECT_ITEM.PAUSRMUSIC then
		musicmanager:pauseMusic(path) 
	elseif tag == EFFECT_ITEM.RESUMEMUSIC then
		musicmanager:resumeMusic(path)
	elseif tag == EFFECT_ITEM.REWINDMUSIC then
		musicmanager:rewindMusic(path)
	end
end

function ManagerEffect(cmd,effect_path,isloop)
	
	local path = EFFECT_PATH[effect_path]
	local tag = EFFECT_ITEM[cmd]
	-- musicmanager:preloadEffect(EFFECT_PATH[effect_path])
	if tag ==EFFECT_ITEM.PLAYEFFECT and getEffectStatus() == 1 then
		musicmanager:playEffect(EFFECT_PATH)
	elseif tag ==EFFECT_ITEM.PLAYEFFECTCIR and getEffectStatus() == 1 then
		musicmanager:playEffect(EFFECT_PATH,isloop)
	elseif tag == EFFECT_ITEM.STOPEFFECT  then
		musicmanager:stopEffect(EFFECT_PATH)
	elseif tag == EFFECT_ITEM.PAUSEEFFECT then
		musicmanager:pauseEffect(EFFECT_PATH)
	elseif tag == EFFECT_ITEM.RESUMEEFFECT then
		musicmanager:resumeEffect(EFFECT_PATH)
	elseif tag == EFFECT_ITEM.RESUMEALLEFFECT then
		musicmanager:resumeAllEffect()
	elseif tag == EFFECT_ITEM.PAUSEALLEFFECT then
		musicmanager:pauseAllEffect()
	elseif tag == EFFECT_ITEM.STOPALLEFFECT then
		musicmanager:stopAllEffect()
	end
end

function addEffectVolume(db)
	musicmanager:setEffectVolume(musicmanager:getEffectVolume() + db)
end
function subEffectVolume(db)
	musicmanager:setEffectVolume(musicmanager:getEffectVolume() - db)
end

function addMusicVolume(db)
	musicmanager:setMusicVolume(musicmanager:getMusicVolume() + db)
end
function subMusicVolume(db)
	musicmanager:setMusicVolume(musicmanager:getMusicVolume() - db)
end

--backgroundmusic
function mainbackground()
	local mainSound = MUSIC_PATH.main
	if res[MUSIC_PATH.main] == nil and getMusicStatus() == 1 then
		if musicmanager:isMusicPlaying(mainSound) then 
			musicmanager:resumeMusic(mainSound)
		else
			musicmanager:playMusic(mainSound,true)
		end
	end
	res[MUSIC_PATH.main] = mainSound
end
function mainMusic( )
	local res = MUSIC_PATH.main
	if getMusicStatus() == 1 then
		musicmanager:playMusic(res,true)
	end
	
end
function loginbackground()
	print(" login music "..getMusicStatus() )
	local loginSound = MUSIC_PATH.login
	if getMusicStatus() == 1 then
		musicmanager:playMusic(loginSound,true)
	end
end

function pyramidbackground()
	local res = MUSIC_PATH.pyramid
	if getMusicStatus() == 1 then
		musicmanager:playMusic(res,true)
	end
end

function battlebackground()
	print(" battle music "..getMusicStatus() )
	local res = MUSIC_PATH.battle
	if getMusicStatus() == 1 then
		musicmanager:playMusic(res,true)
	end
end

function stopAllMusic()
	for i=1 ,4 do
		if getMusicStatus() == 0 then
			musicmanager:stopMusic(MUSIC_PATH[i])
		end
	end
end

function resumeMusic( )
	for i=1,#MUSIC_PATH do
		musicmanager:resumeMusic(MUSIC_PATH[i])
	end
end
function stopEffect()
	for i=1,#EFFECT_PATH do
		if getEffectStatus() == 0 then
			musicmanager:stopEffect(EFFECT_PATH[i])
		end
	end
end
function resumeEffect()
	for i=1,#EFFECT_PATH do
		musicmanager:resumeEffect(EFFECT_PATH[i])
	end
end


--effect
function battle_defeat()
	local res = EFFECT_PATH.battle_defeat
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end

function battle_victory()
	local res = EFFECT_PATH.battle_victory
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end

function playBtnClickEffect()
	local res = EFFECT_PATH.btn_click
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end

function eliminate_horizontal( )
	local res = EFFECT_PATH.eliminate_horizontal
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end

function eliminate_vertical( )
	local res = EFFECT_PATH.eliminate_horizontal
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function eliminate_bomb( )
	local res = EFFECT_PATH.eliminate_bomb
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
	
end
function eliminate_once()
	local res = EFFECT_PATH.eliminate_once
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
	
end
function eliminate_move()	
	local res = EFFECT_PATH.eliminate_move
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
	
end
function start_game( )
	local res = EFFECT_PATH.start_game
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
	
end
function error_tip( )
	local res = EFFECT_PATH.error_tip
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function right_tip( )
	local res = EFFECT_PATH.right_tip
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function capture_fail( )
	local res = EFFECT_PATH.capture_fail
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function capture_succ(  )
 	local res = EFFECT_PATH.capture_succ
 	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end

function upstar()
	local res = EFFECT_PATH.upstar
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end

function breed()
	local res = EFFECT_PATH.breed
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end

function dice()
	local res = EFFECT_PATH.dice
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function amazing( )
	local res = EFFECT_PATH.amazing
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function good( )
	local res = EFFECT_PATH.good
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function wonderful( )
	local res = EFFECT_PATH.wonderful
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function goldhand( )
	local res = EFFECT_PATH.goldhand
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function wild()
	local res = EFFECT_PATH.wild
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function wild_item( )
	local res = EFFECT_PATH.wild_item
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function turntable( )
	local res = EFFECT_PATH.turntable
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function playSkillSoundEffect(skill_id)
	local res = "music/skill/" .. skill_id .. ".mp3"
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function playPetDieEffect(  )
	local res = EFFECT_PATH.die
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function playPetHitEffect(  )
	local res = EFFECT_PATH.effect_pet_hit
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function cat_run()
	local res = EFFECT_PATH.cat_run
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function cat_attacked( )
	local res = EFFECT_PATH.cat_attacked
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function chest_hit( )
	local res = EFFECT_PATH.chest_hit
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function chest_drop( )
	local res = EFFECT_PATH.chest_drop
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function chest_open( )
	local res = EFFECT_PATH.chest_open
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end
function matrix_pikaqiu( )
	local res = EFFECT_PATH.matrix_pikaqiu
	if getEffectStatus() == 1 then
		musicmanager:playEffect(res)
	end
end