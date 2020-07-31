unit role MRM::Monadd[$tbl, List() $cols];

has @!data;
has Bool $!is-dirty;

submethod BUILD (*%x) {
  $cols.values.map: -> $kv {
    @!data[$kv.value[0]] = %x{$kv.key}
      or die sprintf 'Got bad type while creating %s (%s)',
                     $kv.key, %x{$kv.value[0]}
      if %x{$kv.key}:exists
      || ($kv.value[1].^can('mandatory') && $kv.value[1].mandatory);
  };
  die 'Empty row?' unless @!data.elems;
}

method blend(%x) {
  $cols.values.map: -> $kv {
    @!data[$kv.value[0]] = %x{$kv.key}
      or die sprintf 'Got bad type while creating %s (%s)',
                     $kv.key, %x{$kv.value[0]}
      if %x{$kv.key}:exists;
  };
  $!is-dirty = True;
  self;
}

method idx(Int $i) { @!data[$i]; }
method m-idx(Int $i) { $cols[$i]; }
method tbl { $tbl; }
