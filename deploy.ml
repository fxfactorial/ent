#!/usr/bin/env ocaml

(* Need topfind to make require work, need require to use podge package *)
#use "topfind"
#require "podge"

module U = Yojson.Basic.Util
module A = Podge.ANSITerminal

type cmd = Scp of string * string
         | Ssh of string * string

type error_condition = Copy_error | Exec_error

let command = function
  | Scp (source, target) ->
    Printf.sprintf "scp %s root@%s:~/" source target
  | Ssh (target, cmd) ->
    Printf.sprintf "ssh root@%s \"%s\"" target cmd

let usage () =
  {|This deploy script is meant to be run
from the makefile with `make deploy`|} |> print_endline;
  exit 1

let () =
  if Array.length Sys.argv <> 3 then usage ()
  else begin
    let scp_cmd = Sys.(Scp (argv.(1), argv.(2))) |> command in
    Printf.sprintf "Deploying binary to remote device: %s" scp_cmd
    |> A.colored_message |> print_endline;
    Sys.command scp_cmd
    |> function
      outcome when outcome <> 0 ->
      A.colored_message ~m_color:Podge.T.Red "Was unable to copy over the binary"
      |> prerr_endline
    | _ ->
      let ssh_cmd_sign =
        Sys.(Ssh (argv.(2), "ldid -S /var/root/" ^ argv.(1))) |> command
      in
      Printf.sprintf "Signing binary on remote device: %s" ssh_cmd_sign
      |> A.colored_message |> print_endline;
      Sys.command ssh_cmd_sign |> ignore;
      let ssh_cmd = Sys.(Ssh (argv.(2), "/var/root/" ^ argv.(1))) |> command in
      Printf.sprintf "Executing binary on remote device: %s" ssh_cmd
      |> A.colored_message |> print_endline;
      Sys.command ssh_cmd
      |> function
        outcome when outcome <> 0 ->
        A.colored_message ~m_color:Podge.T.Red "Was unable to execute the binary"
        |> prerr_endline
      | _ ->
        A.colored_message "Deployed and tested successfully"
        |> print_endline

  end
