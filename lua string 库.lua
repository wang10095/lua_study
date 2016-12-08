lua string 库 (2012-09-12 09:25:53)转载▼
标签： 杂谈	
--lua中字符串索引从前往后是1,2,……，从后往前是-1，-2……。
--string库中所有的function都不会直接操作字符串，只返回一个结果。
--------------------------------------------------------------------------------------------------
【基本函数】

函数	描述	示例	结果
len	计算字符串长度	string.len("abcd")	4
rep	返回字符串s的n个拷贝	string.rep("abcd",2)	abcdabcd
lower	返回字符串全部字母大写	string.lower("AbcD")	abcd
upper	返回字符串全部字母小写	string.upper("AbcD")	ABCD
format	返回一个类似printf的格式化字符串
string.format("the value is:%d",4)	the value is:4
sub	returns substring from index i to j of s	string.sub("abcd",2)	bcd
string.sub("abcd",-2)	cd
string.sub("abcd",2,-2)	bc
string.sub("abcd",2,3)	bc
find	在字符串中查找	string.find("cdcdcdcd","ab")	nil
string.find("cdcdcdcd","cd")	1 2
string.find("cdcdcdcd","cd",7)	7 8
gsub	在字符串中替换	string.gsub("abcdabcd","a","z");	zbcdzbcd 2
string.gsub("aaaa","a","z",3);	zzza 3
byte	返回字符的整数形式	string.byte("ABCD",4)	68
char	将整型数字转成字符并连接	string.char(97,98,99,100)	abcd--------------------------------------------------------------------------------------------------
【基本模式串】

字符类	描述	示例	结果
.	任意字符	string.find("",".")	nil
%s	空白符	string.find("ab cd","%s%s")	3 4
%S	非空白符	string.find("ab cd","%S%S")	1 2
%p	标点字符	string.find("ab,.cd","%p%p")	3 4
%P	非标点字符	string.find("ab,.cd","%P%P")	1 2
%c	控制字符	string.find("abcd\t\n","%c%c")	5 6
%C	非控制字符	string.find("\t\nabcd","%C%C")	3 4
%d	数字	string.find("abcd12","%d%d")	5 6
%D	非数字	string.find("12abcd","%D%D")	3 4
%x	十六进制数字	string.find("efgh","%x%x")	1 2
%X	非十六进制数字	string.find("efgh","%X%X")	3 4
%a	字母	string.find("AB12","%a%a")	1 2
%A	非字母	string.find("AB12","%A%A")	3 4
%l	小写字母	string.find("ABab","%l%l")	3 4
%L	大写字母	string.find("ABab","%L%L")	1 2
%u	大写字母	string.find("ABab","%u%u")	1 2
%U	非大写字母	string.find("ABab","%U%U")	3 4
%w	字母和数字	string.find("a1()","%w%w")	1 2
%W	非字母非数字	string.find("a1()","%W%W")	3 4
--------------------------------------------------------------------------------------------------
【转义字符%】

字符类	描述	示例	结果
%	转义字符	string.find("abc%..","%%")	4 4
string.find("abc..d","%.%.")	4 5
--------------------------------------------------------------------------------------------------
【用[]创建字符集，"-"为连字符，"^"表示字符集的补集】

字符类	描述	示例	结果
[01]	匹配二进制数	string.find("32123","[01]")	3 3
[AB][CD]	匹配AC、AD、BC、BD	string.find("ABCDEF","[AB][CD]")	2 3
[[]]	匹配一对方括号[]	string.find("ABC[]D","[[]]")	4 5
[1-3]	匹配数字1-3	string.find("312","[1-3][1-3][1-3]")	1 3
[b-d]	匹配字母b-d	string.find("dbc","[b-d][b-d][b-d]")	1 3
[^%s]	匹配任意非空字符	string.find(" a ","[^%s]")	3 3
[^%d]	匹配任意非数字字符	string.find("123a","[^%d]")	4 4
[^%a]	匹配任意非字母字符	string.find("abc1","[^%a]")	4 4
--------------------------------------------------------------------------------------------------
【用"()"进行捕获】

字符类	描述	示例	结果
()	捕获字符串	string.find("12ab","(%a%a)")	3 4 ab
string.find("ab12","(%d%d)")	3 4 12
--------------------------------------------------------------------------------------------------
【模式修饰符】

修饰符	描述	示例	结果
+	表示1个或多个，匹配最多个	string.find("aaabbb","(a+b)")	1 4 aaab
string.find("cccbbb","(a+b)")	nil
-	表示0个或多个，匹配最少个	string.find("zzxyyy","(xy-)")	3 3 x
string.find("zzzyyy","(x-y)")	4 4 y
*	表示0个或多个，匹配最多个	string.find("mmmnnn","(m*n)")	1 4 mmmb
string.find("lllnnn","(m*n)")	4 4 n
?	表示0个或1个	string.find("aaabbb","(a?b)")	3 4 ab
string.find("cccbbb","(a?b)")	4 4 b