(*===-- llvm_tapir_opts.ml - LLVM OCaml Interface -------------*- OCaml -*-===*
 *
 *                     The LLVM Compiler Infrastructure
 *
 * This file is distributed under the University of Illinois Open Source
 * License. See LICENSE.TXT for details.
 *
 *===----------------------------------------------------------------------===*)

(** Tapir pass to install Cilky (or other target-specific) stuff in place of
    detach/sync instructions. *)
external add_lower_tapir_to_target :
  [ `Module ] Llvm.PassManager.t -> unit
  = "llvm_add_lower_tapir_to_target"

(** Tapir pass to spawn loops with recursive divide-and-conquer. *)
external add_loop_spawning :
  [ `Module ] Llvm.PassManager.t -> unit
  = "llvm_add_loop_spawning"
