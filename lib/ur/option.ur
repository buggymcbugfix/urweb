datatype t = datatype Basis.option

val monad = mkMonad {Return = @@Some,
                     Bind = fn [a] [b] (m1 : t a) (m2 : a -> t b) =>
                               case m1 of
                                   None => None
                                 | Some v => m2 v}

fun eq [a] (_ : eq a) =
    mkEq (fn x y =>
             case (x, y) of
                 (None, None) => True
               | (Some x, Some y) => x = y
               | _ => False)

fun ord [a] (_ : ord a) =
    mkOrd {Lt = fn x y =>
                   case (x, y) of
                       (None, Some _) => True
                     | (Some x, Some y) => x < y
                     | _ => False,
           Le = fn x y =>
                   case (x, y) of
                       (None, _) => True
                     | (Some x, Some y) => x <= y
                     | _ => False}

fun isNone [a] x =
    case x of
        None => True
      | Some _ => False

fun isSome [a] x =
    case x of
        None => False
      | Some _ => True

fun mp [a] [b] f x =
    case x of
        None => None
      | Some y => Some (f y)

fun app [m] [a] (_ : monad m) (f : a -> m {}) x =
    case x of
        None => return ()
      | Some y => f y

fun bind [a] [b] f x =
    case x of
        None => None
      | Some y => f y

fun get [a] (x : a) (o : option a) =
    case o of
        None => x
      | Some v => v

(* unsafeGet with a message of the caller's choosing. *)
fun getOrError [a] (message : xbody) (o : option a) : a =
    case o of
        None   => error message
      | Some v => v

fun unsafeGet [a] (o : option a) : a =
    getOrError <xml>Option.unsafeGet: encountered None</xml> o

fun mapM [m] (_ : monad m) [a] [b] (f : a -> m b) (x : t a) : m (t b) =
    case x of
        None => return None
      | Some y => z <- f y; return (Some z)

fun fold [a] [b] (none : b) (some : a -> b) (o : t a) : b =
    case o of
        None => none
      | Some v => some v

fun guard (b : bool) : t unit = if b then Some () else None
