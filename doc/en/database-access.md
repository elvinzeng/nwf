# Database Access For Postgres
## Config
Configure your db connection parameters in webserver.config.xml
```xml
<config>
    <table name='db'>
      <string name='host'>127.0.0.1</string>
      <string name='user_name'>postgres</string>
      <string name='user_password'>123456</string>
      <string name='database'>test</string>
      <string name='port'>5432</string>
    </table>  
  </config>
```
## Generate SQL
You can use sqlGenerator to create some simple sql script.
Before you create INSERT or UPDATE sql,you need to create a lua file for db entity like this  
```lua
local student = commonlib.gettable("entity.student");  
student.tbName = "student";  
student.fields = {
	id = {notNil = true, isPrimaryKey = true},
	name = {notNil = true},
	age = {notNil = true},
	class_id = {notNil = false},
	create_time = {notNil = false},
	is_deleted = {notNil = false}
}
```
then
```lua
local tb = {id="nextval('pf_upm_sys_user_sys_user_id_seq')",name="zhangsan",age=10};

local sqlGenerator = commonlib.gettable("nwf.db.sqlGenerator");
	
local sql = sqlGenerator:insert(commonlib.gettable("entity.student"))
			:value(tb)
			:get();
--update will ignore to set id with new value
sql = sqlGenerator:update(commonlib.gettable("entity.student"))
		  :value(tb)
		  :where("id = ",tb.id)
		  :_and(nil,"create_time = now()")
		  :get();

sql = sqlGenerator:select(" s.name , s.age ")
		  :append("FROM student s LEFT JOIN class c ON c.id = s.id")
		  :where(nil,"create_time = now()")
		  :get();
```
##  Use DbTemplete
```lua
local dbTemplate = commonlib.gettable("nwf.db.dbTemplate");
```
### Basic Usage
```lua
dbTemplate.execute(sql)
dbTemplate.executeWithTransaction(sql1,sql2,...)
```

### Release Control For Connection Object
```lua
dbTemplate.executeWithReleaseCtrl(sql, conn, release ,openTransaction)

local openTransaction = true
local conn = dbTemplate.executeWithReleaseCtrl(sql1, nil, false, openTransaction)
dbTemplate.executeWithReleaseCtrl(sql2, conn, false, openTransaction)
...
--release conn until last execute
dbTemplate.executeWithReleaseCtrl(sqlN, conn, true, openTransaction)
```

### Association
#### Tips
* set alias for field, [mainTbPrefix_alias], [fromTbPrefix1_alias], [fromTbPrefix2_alias]...
* primary key set alias like mainTbPrefix_id, fromTbPrefix1_id ...
* tbAliasPrefix = {mainTbPrefix, fromTbPrefix1, fromTbPrefix2, ...}
* if you want query without association , set tbAliasPrefix = nil 

```lua
dbTemplate:queryFirst(sql, tbAliasPrefix)

local sql = SELECT c.id as class_id,
		   c.name as class_name,
		   s.id as student_id,
		   s.name as student_name,
		   s.age as student_age,
		   s.class_id as student_classId ,
		   x.id as xxx_id,
		   x.name as xxx_name,
		   x.class_id as xxx_classId 
	   FROM class c 
	   LEFT JOIN student s ON s.class_id = c.id
	   LEFT JOIN xxx x ON x.class_id = c.id
	   WHERE c.id = 2;
local data,err = dbTemplate:queryFirst(sql, {"class","student","xxx"});
```

### Pagination
#### Tips
* `countSql` can not be nil, `pageIndex` and `pageSize` must lager than 0
* use `LIMIT %d OFFSET %d` in your sql
```lua
dbTemplate:queryList(sql, tbAliasPrefix, countSql, pageIndex, pageSize)

local sql = SELECT c.id as class_id,
		   c.name as class_name,
		   s.id as student_id,
		   s.name as student_name,
		   s.age as student_age,
		   s.class_id as student_classId ,
		   x.id as xxx_id,
		   x.name as xxx_name,
		   x.class_id as xxx_classId 
           FROM (SELECT id, name FROM class LIMIT %d OFFSET %d) c 
	   LEFT JOIN student s ON s.class_id = c.id
	   LEFT JOIN xxx x ON x.class_id = c.id;
local data,err = dbTemplate:queryList(sql, {"class","student","xxx"}, " select count(1) from class ", 1, 3);
```

