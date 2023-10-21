open Core

let slice (lst : 'a list) (slice_start : int) (slice_end : int) : 'a list =
  let rec aux lst cnt =
    match lst, cnt with
    | [], _ -> []
    | h :: t, x when x >= slice_start && x <= slice_end -> h :: aux t (x + 1)
    | _ :: t, x -> aux t (x + 1)
  in
  aux lst 0
;;

let%expect_test "slice" =
  print_s
    ([%sexp_of: string list]
       (slice [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i"; "j" ] 2 6));
  [%expect {| (c d e f g) |}]
;;

let rec fib = function
  | 0 -> 0
  | 1 -> 1
  | n -> fib (n - 1) + fib (n - 2)
;;

let%expect_test "fib" =
  printf "%d,%d,%d" (fib 1) (fib 2) (fib 3);
  [%expect {| 1,1,2 |}]
;;
