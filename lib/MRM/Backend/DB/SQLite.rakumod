unit module MRM::Backend::DB::SQLite;

sub query-tables(\db --> Hash) is export {
  my @a = db.query('select name from sqlite_master where type = \'table\' and name not like \'sqlite_%\'').arrays;
  my $p = db.db.prepare('select * from PRAGMA_table_info(?)');
  my %b;
  @a.map: -> $a {
    for $p.execute($a[0]).hashes -> %a {
      %b{$a}{%a<name>} = (%a<cid>, %a<type>, db);
    }
  };
  $p.finish;
  %b;
}
