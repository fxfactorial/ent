#!/usr/bin/env ocaml
(* Need topfind to make require work, need require to use podge package *)
#use "topfind"
#require "podge"

module U = Yojson.Basic.Util
module A = Podge.ANSITerminal

type cmd = Scp of int * string
         | Ssh of int * string

type error_condition = Copy_error | Exec_error

let connected_devices () =
  Podge.Unix.read_process_output "gandalf -s"
  |> Podge.List.drop ~n:5
  |> String.concat ""
  |> Yojson.Basic.from_string
  |> U.to_list
  |> List.fold_left
    (fun accum item -> U.(member "Local Port" item |> to_int) :: accum) []

let command = function
  | Scp (port, target) ->
    Printf.sprintf "scp -P %d %s root@localhost:~/" port target
  | Ssh (port, cmd) ->
    Printf.sprintf "ssh root@localhost -p %d \"%s\"" port cmd

let usage () =
  "This deploy script assumes that it was started\n\
   from the makefile with `make deploy` and that gandalf is running"
  |> print_endline;
  exit 1

let with_gandalf udid ~f =
  let f_name = Filename.temp_file "gandalf" "deployment" in
  let f_chan = open_out f_name in
  Printf.sprintf "%s:2000:22" udid |> output_string f_chan;
  close_out f_chan;
  let gandalf_pid =
    Unix.(create_process "gandalf" [|"gandalf"; "-m"; f_name|] stdin stdout stderr)
  in
  Unix.sleep 1;
  f ();
  Unix.kill gandalf_pid 5

let cmd_result ~error_msg = function
  | outcome when outcome <> 0 ->
    A.colored_message ~m_color:Podge.T.Red error_msg |> prerr_endline;
    exit 1
  | _ -> ()

let () =
  if Array.length Sys.argv <> 3 then usage ()
  else
    with_gandalf Sys.argv.(2) begin fun () ->
      let devices = connected_devices () in
      devices |> List.iter begin fun i_device ->
        let scp_cmd = Sys.(Scp (i_device, argv.(1))) |> command in
        Printf.sprintf "Deploying binary to remote device: %s" scp_cmd
        |> A.colored_message |> print_endline;
        Sys.command scp_cmd
        |> cmd_result ~error_msg:"Was unable to copy over the binary";
        let ssh_cmd_sign =
          Sys.(Ssh (i_device, "ldid -S /var/root/" ^ argv.(1))) |> command
        in
        Printf.sprintf "Signing binary on remote device: %s" ssh_cmd_sign
        |> A.colored_message |> print_endline;
        Sys.command ssh_cmd_sign
        |> cmd_result
          ~error_msg:(Printf.sprintf "Signing binary on remote device: %s" ssh_cmd_sign);
        let ssh_cmd = Sys.(Ssh (i_device, "/var/root/" ^ argv.(1))) |> command in
        Printf.sprintf "Executing binary on remote device: %s" ssh_cmd
        |> print_endline;
        Sys.command ssh_cmd
        |> cmd_result ~error_msg:"Was unable to execute the binary";
        A.colored_message "Deployed and tested successfully"
        |> print_endline
      end
    end
