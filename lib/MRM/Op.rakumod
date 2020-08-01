unit module MRM::Op;
use MRM::Monadd;

proto infix:<<">>=">> (
   \a, \b
) is export
{ * }

multi infix:<<">>=">> (
  List \a where { $_.grep(* ~~ MRM::Monadd|Nil).elems == $_.elems },
  \b where { $_ ~~ Callable || ($_ ~~ List && $_[0] ~~ Callable) }
  --> List())
{
  return Nil unless \a.elems;
  my @r;
  my \f  = b ~~ Callable ?? b !! b[0];
  my \fp = b ~~ Callable ?? Nil !! b[1];
  a.map: -> \z {
    try {
      CATCH { default { fp.() if fp ~~ Callable; @r.push: Nil; } };
      if z ~~ Nil {
        @r.push: fp;
      } else {
        my \c = f.(z);
        @r.push: c ~~ MRM::Monadd ?? c !! z;
      }
    };
  };
  @r;
}
multi infix:<<">>=">> (Nil, Any \b) { Nil; }
multi infix:<<">>=">> (Any, Any \b) { Nil but True; }
