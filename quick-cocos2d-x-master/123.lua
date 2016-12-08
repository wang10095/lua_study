--cd /Users/wangjunwei/Desktop/Pokemon/flash 
--localhost:flash wangjunwei$ cp TuiEditor\ Export.jsfl ~/Library/Application\ Support/Adobe/Flash\ CS6/en_US/Configuration/Commands/
-- 四川省成都市新都区斑竹园镇忠义路毗河明珠（红旗超市对面）
-- print(string.find(string.sub('adsf12dfad','%d')))
-- print(os.date("%H"))
--更新配置 http://192.168.1.110/admin_develop/update_pokemon.html  
-- https://192.168.1.100/svn/product/client/Pokemon
-- awk -F"'" '{print $2}' restore_list > restore_list_path
-- http://blog.sina.com.cn/s/blog_78ea87380102v4s9.html  --不删除动态链接库

-- Subject = {}
-- function Subject:new(o)
--  	o = o or {}
--  	setmetatable(o,self)
--  	self.__index = self
--  	return o
-- end

-- ConcreteSubject = Subject:new()
-- function ConcreteSubject:Attach(theconcreteobserver) --注册观察者
--  	if self.observers == nil then
--   		self.observers = {}
--  	end
--  	table.insert(self.observers,theconcreteobserver)
-- end

-- function ConcreteSubject:Detach(theconcreteobserver)--消除观察者
--  	for k, v in pairs(self.observers) do
--   		if v == theconcreteobserver then
--   		 	table.remove(self.observers,k)
--    			break
--  		end
--  	end
-- end

-- function ConcreteSubject:Notify() --通知
--  	for _, v in pairs(self.observers) do
--   		v:Update()
--  	end
-- end

-- Observer = {}
-- function Observer:new(o)
--  	o = o or {}
--  	setmetatable(o,self)
-- 	self.__index = self
-- 	return o
-- end

-- ConcreteObserver = Observer:new()
-- function ConcreteObserver:new(s,n)
-- 	o = {}
-- 	setmetatable(o,self)
-- 	self.__index = self
-- 	o.subject = s
-- 	o.observername = n
-- 	return o
-- end

-- function ConcreteObserver:Update() --更新
-- 	--显示小红点
--  	print("li大喊："..self.observername.."!!"..self.subject.subjectstate)
-- end

-- --搜集所有需要通知的信息
-- s = ConcreteSubject:new()  --登记
-- s:Attach(ConcreteObserver:new(s,"张"))
-- zhongxintong = ConcreteObserver:new(s,"钟")
-- chenwenyuan  = ConcreteObserver:new(s,"陈")
-- s:Attach(zhongxintong)
-- s:Attach(chenwenyuan)
-- s.subjectstate = "lj来了!!"
-- s:Notify()
-- --操作完毕可以让小红点消失
-- s:Detach(zhongxintong) -- 退出
-- s:Detach(chenwenyuan)
-- s.subjectstate = "lj疯走了!!"
-- s:Notify()
require "/Users/wangjunwei/Desktop/321"
module("Constants", package.seeall)

NewsTable = { --通知列表
	UP_SKILL_LEVEL = {eventName="event_skillup_promt",status=false }, --升级
}















