unit module MRM;
use MRM::Monadd;

my (%state,%tbl-cache);

sub mrm-index($db) is export {
  my $backend = $db.WHAT.^name;
  require ::('MRM::Backend::' ~ "$backend");
  die "No backend for $backend, did you forget to install it?" 
    if ::('MRM::Backend::' ~ "$backend") ~~ Failure;
  %state{$db.WHICH} = ::('MRM::Backend::' ~ "$backend\::EXPORT::DEFAULT::&query-tables").($db);
  for %state{$db.WHICH}.keys -> $k {
    %tbl-cache{$k} //=  %state{$db.WHICH}{$k};
  }
}

sub mrm-table($tbl, :$db?) is export {
  $db
  ?? (%state{$db.WHICH}{$tbl}=conflate($tbl, %state{$db.WHICH}{$tbl}))
  !! (%tbl-cache{$tbl}=conflate($tbl, %tbl-cache{$tbl}));
}

sub conflate($tbl, $cols) {
  return $cols if $cols ~~ MRM::Monadd;
  MRM::Monadd[$tbl, $cols];
}
