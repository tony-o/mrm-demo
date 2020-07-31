unit module YAQL;
use MRM::Monadd;
use MRM;

# this needs to be indirected to YAQL backends but for demo:
multi yaql(MRM::Monadd $tbl, *%query) is export {
  # this is just a demo so i'm not building this out
  try {
    $tbl.new: |$tbl.m-idx(0).value[2].query('select * from ' ~ $tbl.tbl ~
                                (%query.keys
                                 ?? ' where ' ~ %query.keys.join(' = ? AND ') ~ ' = ?'
                                 !! ''
                                )
                                , |%query.values).hash;
  } // Nil;
}

multi yaql(Str $tbl, *%query) is export { yaql(mrm-table($tbl), |%query); }
