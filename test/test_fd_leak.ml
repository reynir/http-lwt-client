open Lwt.Syntax

let endpoint = "https://opam.ocaml.org/repo" 

let main () =
  let f _resp _acc _data =
    Lwt.return_unit
  in
  (*let* r = Http_lwt_client.request "https://opam.ocaml.org/repo" f () in*)
  let* r = Http_lwt_client.request endpoint f () in
  match r with
  | Error `Msg e ->
    Printf.eprintf "Error in request: %s\n%!" e;
    exit 2
  | Ok (_resp, ()) ->
    let* () = Lwt_unix.sleep 1. in
    (* we assume fd 5 will be used for the tcp connection:
       - fds 0..2 are stdin, stdout, stderr
       - fd 3 is eventfd
       - fd 4 is to the DNS server
       - fd 5 is to the web server *)
    let fd : Unix.file_descr = Obj.magic 5 in
    match Unix.getsockname fd with
    | _name ->
      Printf.eprintf "Expected EBADF, but got sockname\n%!";
      exit 2
    | exception Unix.Unix_error (Unix.EBADF, _, _) ->
      Lwt.return_unit

let _ =
  Lwt_main.run (main ())
