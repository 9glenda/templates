let rec fib n = match n with 0 | 1 -> n | _ -> fib (n - 1) + fib (n - 2)

let () =
  for n = 1 to 16 do
    Printf.printf "%d, " (fib n)
  done;
  print_endline "..."
