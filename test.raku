#!/usr/bin/env raku

use lib 'lib';
use MRM;
use MRM::Op;
use HQL;
use DB::SQLite;

sub dumpUser($a) {
  die if (0..100).roll < 50 && $a.idx(0) != 5;
  printf ":user-id(%d) :email(%s) :passwd(%s)\n",
         $a.idx(0), $a.idx(1), $a.idx(2);
}

sub reportFail {
  say 'I failed to do a thing.';
}

sub saveUser($a) {
  say 'saving user';
}

mrm-index(DB::SQLite.new(filename => '/tmp/test.sqlite3'));

hql-r('usr', user_id => 5)
  >>= &dumpUser
  >>= &saveUser or reportFail;

say 'update user 15:';
hql-r('usr', user_id => 15, )
  >>= &dumpUser
  >>= &saveUser or reportFail;

say 'dump all users:';
hql-r('usr') >>= (&dumpUser, &reportFail);
