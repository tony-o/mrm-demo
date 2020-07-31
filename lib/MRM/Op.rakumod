unit module MRM::Op;
use MRM::Monadd;

proto infix:<<">>=">> (
   \a, \b
) is export { * }

multi infix:<<">>=">> (
  MRM::Monadd \a,
  Callable \b)
{
  return Nil unless defined a;
  if a ~~ Array() {
    my @c;
    # do something here to perform all.
  }
  my \c = b.(a);
  c ~~ MRM::Monadd ?? c !! a;
}
multi infix:<<">>=">> (Nil, Any \b) { Nil; }
multi infix:<<">>=">> (Any, Any \b) { Nil but True; }
