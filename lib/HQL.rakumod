unit module HQL; #hash query lang.
use MRM::Monadd;
use MRM;

multi hql-r(MRM::Monadd $tbl, *%query) is export {
  # this is just a demo so i'm not building this out
  my ($*id, $*sep, $*place);
  if ( $tbl.db.^name ~~ m:i[sqlite|mysql|oracle] ) {
    $*place = sub { '?' };
    $*sep = '.';
    $*id  = '"';
  } elsif ( $tbl.db.^name ~~ m:i[pg|postgres] ) {
    $*place = sub { '$' ~ @*params.elems; };
    $*sep   = '.';
    $*id    = '`';
  } else { die 'I do not know how to handle: ' ~ $tbl.db.^name; };
  try {
    CATCH { .say; }
    my $sql = sql-r($tbl, %query);
    ($tbl.new(|$_.hash) for |$tbl.db.query(|$sql).hashes);
  } // Nil;
}
multi hql-r(Str $tbl, *%query) is export { hql-r(mrm-table($tbl), |%query); }

sub sql-r($tbl, %filter) {
  my (@*params, $sql);
#  say [('SELECT * FROM '
#  ~ gen-id($tbl.tbl)
#  ~ (%filter.keys ?? gen-where(%filter) !! ''))
#  , |@*params
#  ].raku;

  [('SELECT * FROM '
  ~ gen-id($tbl.tbl)
  ~ (%filter.keys ?? gen-where(%filter) !! ''))
  , |@*params
  ];
}

sub gen-id(Str() $id) {
  my @s = $id.split($*sep);
  "{$*id}{@s.join($*id~$*sep~$*id)}{$*id}";# ~ $id ~ '"';
}

sub gen-pairs($kv, $type = 'AND') {
  my @pairs;
  if $kv ~~ Pair {
    my ($eq, $val);
    if $kv.key ~~ Str && $kv.key eq ('-or'|'-and') {
      @pairs.push: gen-pairs($kv.value, $kv.key.uc.substr(1));
      $eq := 'andor';
    } elsif $kv.value ~~ Hash {
      $eq  := $kv.value.keys[0];
      $val := $kv.value.values[0];
    } elsif $kv.value ~~ Block && $kv.value.().elems == 2 {
      $eq  := $kv.value.()[0];
      $val := $kv.value.()[1];
    } elsif $kv.value ~~ Array {
      my @arg;
      for @($kv.value) -> $x {
        @arg.push( gen-quote($x, True) );
      }
      $eq  := 'in';
      @pairs.push: gen-id($kv.key)~" $eq ("~@arg.join(', ')~")";
    } else {
      $eq  := '=';
      $val := $kv.value
    }
    @pairs.push: gen-id($kv.key)~" $eq "~gen-quote($val, True)
      if $eq ne ('andor'|'in');
  } elsif $kv ~~ Hash {
    for %($kv).pairs -> $x {
      @pairs.push: '( '~gen-pairs($x.key eq ('-or'|'-and') ?? $x.value !! $x, $x.key eq ('-or'|'-and') ?? $x.key.uc.substr(1) !! $type) ~ ' )';
    }
  } elsif $kv ~~ Array {
    my $arg;
    for @($kv) -> $x {
      $arg = $x.WHAT ~~ List ?? $x.pairs[0].value !! $x;
      @pairs.push: '( '~gen-pairs($arg, $type)~' )';
    }
  }
  @pairs.join(" $type ");
}

sub gen-quote(\val, $force = False) {
  if !$force && val =:= try val."{val.^name}"() {
    return gen-id(val);
  } else {
    push @*params, val;
    return $*place.();
  }
}

sub gen-where(%filter) {
  ' WHERE '
  ~ gen-pairs(%filter);
}
