# mrm

test.raku is the main file to be concerned with here.

there are two major components to this demo: `YAQL` and `MRM`


## MRM

`MRM` is minimal framework designed around describing the backend

`MRM::Monadd` is a monad-ish object that allows you use a different type of flow control in your application.  the goal with this is to be able to pass a junction to handle side effects.  in this way it becomes immediately useful in things like user management (note: the example shows junctions to handle side effects, that currently doesn't work in this repo as its just in prototyping phase):

```perl6
...
my $x = yaql('usr', user_id => $id)
        <<= (&logUpdate|{ error => 'user does not exist' })
        <<= (-> $m { $m.blend(%new-data) }|{ error => 'failure to blend' })
        <<= (&saveUser & { success => 1 });
# $x: any of
#       { error => 'user does not exist' }
#       { error => 'failure to blend'    }
#       { success => 1 }
...
```

current pattern is:

```perl6
my $usr = $users.find({ user_id => $id }).first;
if $usr {
  logUpdate($usr);
  if $usr.blend(%new-data) {
    $usr.save;
    return { success => 1 };
  }
  return { error => 'failure to blend' };
}
return { error => 'user does not exist' };
```

it saves typing but more importantly it keeps the side effect _next_ to the cause and makes it easier to read.

the other thing this does it breaks the tight coupling between query language and the backend.  the query lang could easily be changed without breaking or changing any of the pattern involved with updating a user.  need your backend to use a remote auth API? great, write or use the query language for that and you're done refactoring.  if you want that today you need to integrate a backend into the thing describing models.

## YAQL

`YAQL` is just a basic `hash => sql` translator.  Same crap that already exists.  in this repo it's only available to do a select as an example.  this could easily be hot swapped for something generating an `MRM:Monadd`

