#!/usr/bin/env raku

use lib 'lib';
use MRM;
use MRM::Op;
use YAQL;
use DB::SQLite;

sub dumpUser($a) {
  printf ":user-id(%d) :email(%s) :passwd(%s)\n",
         $a.idx(0), $a.idx(1), $a.idx(2);
}

sub saveUser($a) {
  warn 'saving user';
}

mrm-index(DB::SQLite.new(filename => '/tmp/test.sqlite3'));
(yaql('usr', user_id => 5)
  >>= &dumpUser or warn 'user 5 does not exist')
  >>= (-> $a { $a.blend({ email => 'test@email.com' }) })
  >>= &dumpUser
  >>= &saveUser or warn 'failed to save user 5!';

(yaql('usr', user_id => 15, )
  >>= &dumpUser or warn 'user 15 does not exist')
  >>= &saveUser or warn 'failed to save user 15!';
