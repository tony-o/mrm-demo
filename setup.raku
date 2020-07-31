#!/usr/bin/env raku

use DB::SQLite;

my \db = DB::SQLite.new(filename => '/tmp/test.sqlite3');

db.execute('create table if not exists usr (user_id integer primary key autoincrement,email varchar(64), passwd varchar(128));');
db.execute('delete from usr where 1=1;');
db.execute('UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME="usr";');
for 0..10 -> $x {
  db.query('insert into usr (email, passwd) values (?,?)', "user$x\@abc.com", "pass");
}

