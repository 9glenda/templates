let comma_separated_to_list input = String.split_on_char ',' input

let () =
  let input_string = "apple,banana,orange,grape" in
  let result_list = comma_separated_to_list input_string in
  List.iter (fun s -> Printf.printf "%s\n" s) result_list

