; RUN: opt %s -passes="default<O2>" -S | FileCheck %s
; REQUIRES: x86-registered-target

; ModuleID = 'test.c'
source_filename = "test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@buffer_helper = dso_local global [64 x i64] zeroinitializer, align 16
@buffer = dso_local global [4 x [64 x i64]] zeroinitializer, align 16

; CHECK: load <4 x i64>, ptr
; CHECK: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK: load <4 x i64>, ptr
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 8589934590, i64 8589934590, i64 8589934590, i64 8589934590>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK: load <4 x i64>, ptr
; CHECK: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK: load <4 x i64>, ptr
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 8589934590, i64 8589934590, i64 8589934590, i64 8589934590>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT': store <4 x i64>

; CHECK: load <4 x i64>, ptr
; CHECK: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK: load <4 x i64>, ptr
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 8589934590, i64 8589934590, i64 8589934590, i64 8589934590>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK: load <4 x i64>, ptr
; CHECK: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK: load <4 x i64>, ptr
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 8589934590, i64 8589934590, i64 8589934590, i64 8589934590>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK: load <4 x i64>, ptr
; CHECK: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK: load <4 x i64>, ptr
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 8589934590, i64 8589934590, i64 8589934590, i64 8589934590>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK: load <4 x i64>, ptr
; CHECK: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK: load <4 x i64>, ptr
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 8589934590, i64 8589934590, i64 8589934590, i64 8589934590>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK: load <4 x i64>, ptr
; CHECK: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK: load <4 x i64>, ptr
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 8589934590, i64 8589934590, i64 8589934590, i64 8589934590>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK: load <4 x i64>, ptr
; CHECK: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK: load <4 x i64>, ptr
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 8589934590, i64 8589934590, i64 8589934590, i64 8589934590>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -8589934591, i64 -8589934591, i64 -8589934591, i64 -8589934591>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -562941363617791, i64 -562941363617791, i64 -562941363617791, i64 -562941363617791>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391, i64 -143554428589179391>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191, i64 -2170205185142300191>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK: load <2 x i64>
; CHECK-NEXT: shufflevector <2 x i64>

; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -7378697629483820647, i64 -7378697629483820647, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>

; CHECK: load <2 x i64>
; CHECK: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -7378697629483820647, i64 -7378697629483820647, i64 -7378697629483820647, i64 -7378697629483820647>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>
; CHECK-NEXT: shufflevector <2 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -7378697629483820647, i64 -7378697629483820647, i64 -7378697629483820647, i64 -7378697629483820647>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646, i64 7378697629483820646>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK: load <2 x i64>
; CHECK: load i64
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: shufflevector <2 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: insertelement <4 x i64>
; CHECK-NEXT: insertelement <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 -6148914691236517206, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: load i64
; CHECK-NEXT: load <4 x i64>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: insertelement <4 x i64>
; CHECK-NEXT: and <4 x i64> %{{.+}}, <i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205, i64 6148914691236517205>
; CHECK-NEXT: shufflevector <4 x i64>
; CHECK-NEXT: and <4 x i64>
; CHECK-NEXT: or <4 x i64>
; CHECK-NEXT: store <4 x i64>

; CHECK-NEXT: ret void

; Function Attrs: nounwind uwtable
define dso_local void @perm_columns64(i64* noalias noundef %buffer) #0 {
entry:
  %buffer.addr = alloca i64*, align 8
  %perm_mask_32 = alloca i64, align 8
  %perm_value_32 = alloca i8, align 1
  %j = alloca i8, align 1
  %perm_mask_16 = alloca i64, align 8
  %perm_value_16 = alloca i8, align 1
  %perm_value_16_cylce = alloca i8, align 1
  %j8 = alloca i8, align 1
  %j29 = alloca i8, align 1
  %perm_mask_8 = alloca i64, align 8
  %perm_value_8_cylce = alloca i8, align 1
  %perm_value_8 = alloca i8, align 1
  %j49 = alloca i8, align 1
  %j70 = alloca i8, align 1
  %perm_mask_4 = alloca i64, align 8
  %perm_value_4_cycle = alloca i8, align 1
  %perm_value_4 = alloca i8, align 1
  %j92 = alloca i8, align 1
  %j116 = alloca i8, align 1
  %perm_mask_2 = alloca i64, align 8
  %perm_value_2_cycle = alloca i8, align 1
  %perm_value_2 = alloca i8, align 1
  %j139 = alloca i8, align 1
  %j163 = alloca i8, align 1
  %perm_mask_1 = alloca i64, align 8
  %perm_value_1_cycle = alloca i8, align 1
  %perm_value_1 = alloca i8, align 1
  %j186 = alloca i8, align 1
  %j210 = alloca i8, align 1
  store i64* %buffer, i64** %buffer.addr, align 8, !tbaa !3
  %0 = bitcast i64* %perm_mask_32 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %0) #2
  store i64 8589934590, i64* %perm_mask_32, align 8, !tbaa !7
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_32) #2
  store i8 32, i8* %perm_value_32, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j) #2
  store i8 0, i8* %j, align 1, !tbaa !9
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i8, i8* %j, align 1, !tbaa !9
  %conv = zext i8 %1 to i32
  %cmp = icmp slt i32 %conv, 64
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j) #2
  br label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %3 = load i8, i8* %j, align 1, !tbaa !9
  %idxprom = zext i8 %3 to i64
  %arrayidx = getelementptr inbounds i64, i64* %2, i64 %idxprom
  %4 = load i64, i64* %arrayidx, align 8, !tbaa !7
  %and = and i64 %4, -8589934591
  %5 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %6 = load i8, i8* %j, align 1, !tbaa !9
  %conv2 = zext i8 %6 to i32
  %xor = xor i32 %conv2, 32
  %idxprom3 = sext i32 %xor to i64
  %arrayidx4 = getelementptr inbounds i64, i64* %5, i64 %idxprom3
  %7 = load i64, i64* %arrayidx4, align 8, !tbaa !7
  %and5 = and i64 %7, 8589934590
  %or = or i64 %and, %and5
  %8 = load i8, i8* %j, align 1, !tbaa !9
  %idxprom6 = zext i8 %8 to i64
  %arrayidx7 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom6
  store i64 %or, i64* %arrayidx7, align 8, !tbaa !7
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %9 = load i8, i8* %j, align 1, !tbaa !9
  %inc = add i8 %9, 1
  store i8 %inc, i8* %j, align 1, !tbaa !9
  br label %for.cond, !llvm.loop !10

for.end:                                          ; preds = %for.cond.cleanup
  %10 = bitcast i64* %perm_mask_16 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %10) #2
  store i64 562941363617790, i64* %perm_mask_16, align 8, !tbaa !7
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_16) #2
  store i8 16, i8* %perm_value_16, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_16_cylce) #2
  store i8 48, i8* %perm_value_16_cylce, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j8) #2
  store i8 0, i8* %j8, align 1, !tbaa !9
  br label %for.cond9

for.cond9:                                        ; preds = %for.inc26, %for.end
  %11 = load i8, i8* %j8, align 1, !tbaa !9
  %conv10 = zext i8 %11 to i32
  %cmp11 = icmp slt i32 %conv10, 16
  br i1 %cmp11, label %for.body14, label %for.cond.cleanup13

for.cond.cleanup13:                               ; preds = %for.cond9
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j8) #2
  br label %for.end28

for.body14:                                       ; preds = %for.cond9
  %12 = load i8, i8* %j8, align 1, !tbaa !9
  %idxprom15 = zext i8 %12 to i64
  %arrayidx16 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom15
  %13 = load i64, i64* %arrayidx16, align 8, !tbaa !7
  %and17 = and i64 %13, -562941363617791
  %14 = load i8, i8* %j8, align 1, !tbaa !9
  %conv18 = zext i8 %14 to i32
  %xor19 = xor i32 %conv18, 48
  %idxprom20 = sext i32 %xor19 to i64
  %arrayidx21 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom20
  %15 = load i64, i64* %arrayidx21, align 8, !tbaa !7
  %and22 = and i64 %15, 562941363617790
  %or23 = or i64 %and17, %and22
  %16 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %17 = load i8, i8* %j8, align 1, !tbaa !9
  %idxprom24 = zext i8 %17 to i64
  %arrayidx25 = getelementptr inbounds i64, i64* %16, i64 %idxprom24
  store i64 %or23, i64* %arrayidx25, align 8, !tbaa !7
  br label %for.inc26

for.inc26:                                        ; preds = %for.body14
  %18 = load i8, i8* %j8, align 1, !tbaa !9
  %inc27 = add i8 %18, 1
  store i8 %inc27, i8* %j8, align 1, !tbaa !9
  br label %for.cond9, !llvm.loop !13

for.end28:                                        ; preds = %for.cond.cleanup13
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j29) #2
  store i8 16, i8* %j29, align 1, !tbaa !9
  br label %for.cond30

for.cond30:                                       ; preds = %for.inc46, %for.end28
  %19 = load i8, i8* %j29, align 1, !tbaa !9
  %conv31 = zext i8 %19 to i32
  %cmp32 = icmp slt i32 %conv31, 64
  br i1 %cmp32, label %for.body35, label %for.cond.cleanup34

for.cond.cleanup34:                               ; preds = %for.cond30
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j29) #2
  br label %for.end48

for.body35:                                       ; preds = %for.cond30
  %20 = load i8, i8* %j29, align 1, !tbaa !9
  %idxprom36 = zext i8 %20 to i64
  %arrayidx37 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom36
  %21 = load i64, i64* %arrayidx37, align 8, !tbaa !7
  %and38 = and i64 %21, -562941363617791
  %22 = load i8, i8* %j29, align 1, !tbaa !9
  %conv39 = zext i8 %22 to i32
  %sub = sub nsw i32 %conv39, 16
  %idxprom40 = sext i32 %sub to i64
  %arrayidx41 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom40
  %23 = load i64, i64* %arrayidx41, align 8, !tbaa !7
  %and42 = and i64 %23, 562941363617790
  %or43 = or i64 %and38, %and42
  %24 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %25 = load i8, i8* %j29, align 1, !tbaa !9
  %idxprom44 = zext i8 %25 to i64
  %arrayidx45 = getelementptr inbounds i64, i64* %24, i64 %idxprom44
  store i64 %or43, i64* %arrayidx45, align 8, !tbaa !7
  br label %for.inc46

for.inc46:                                        ; preds = %for.body35
  %26 = load i8, i8* %j29, align 1, !tbaa !9
  %inc47 = add i8 %26, 1
  store i8 %inc47, i8* %j29, align 1, !tbaa !9
  br label %for.cond30, !llvm.loop !14

for.end48:                                        ; preds = %for.cond.cleanup34
  %27 = bitcast i64* %perm_mask_8 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %27) #2
  store i64 143554428589179390, i64* %perm_mask_8, align 8, !tbaa !7
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_8_cylce) #2
  store i8 56, i8* %perm_value_8_cylce, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_8) #2
  store i8 8, i8* %perm_value_8, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j49) #2
  store i8 0, i8* %j49, align 1, !tbaa !9
  br label %for.cond50

for.cond50:                                       ; preds = %for.inc67, %for.end48
  %28 = load i8, i8* %j49, align 1, !tbaa !9
  %conv51 = zext i8 %28 to i32
  %cmp52 = icmp slt i32 %conv51, 8
  br i1 %cmp52, label %for.body55, label %for.cond.cleanup54

for.cond.cleanup54:                               ; preds = %for.cond50
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j49) #2
  br label %for.end69

for.body55:                                       ; preds = %for.cond50
  %29 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %30 = load i8, i8* %j49, align 1, !tbaa !9
  %idxprom56 = zext i8 %30 to i64
  %arrayidx57 = getelementptr inbounds i64, i64* %29, i64 %idxprom56
  %31 = load i64, i64* %arrayidx57, align 8, !tbaa !7
  %32 = load i64, i64* %perm_mask_8, align 8, !tbaa !7
  %neg = xor i64 %32, -1
  %and58 = and i64 %31, %neg
  %33 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %34 = load i8, i8* %j49, align 1, !tbaa !9
  %conv59 = zext i8 %34 to i32
  %xor60 = xor i32 %conv59, 56
  %idxprom61 = sext i32 %xor60 to i64
  %arrayidx62 = getelementptr inbounds i64, i64* %33, i64 %idxprom61
  %35 = load i64, i64* %arrayidx62, align 8, !tbaa !7
  %36 = load i64, i64* %perm_mask_8, align 8, !tbaa !7
  %and63 = and i64 %35, %36
  %or64 = or i64 %and58, %and63
  %37 = load i8, i8* %j49, align 1, !tbaa !9
  %idxprom65 = zext i8 %37 to i64
  %arrayidx66 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom65
  store i64 %or64, i64* %arrayidx66, align 8, !tbaa !7
  br label %for.inc67

for.inc67:                                        ; preds = %for.body55
  %38 = load i8, i8* %j49, align 1, !tbaa !9
  %inc68 = add i8 %38, 1
  store i8 %inc68, i8* %j49, align 1, !tbaa !9
  br label %for.cond50, !llvm.loop !15

for.end69:                                        ; preds = %for.cond.cleanup54
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j70) #2
  store i8 8, i8* %j70, align 1, !tbaa !9
  br label %for.cond71

for.cond71:                                       ; preds = %for.inc89, %for.end69
  %39 = load i8, i8* %j70, align 1, !tbaa !9
  %conv72 = zext i8 %39 to i32
  %cmp73 = icmp slt i32 %conv72, 64
  br i1 %cmp73, label %for.body76, label %for.cond.cleanup75

for.cond.cleanup75:                               ; preds = %for.cond71
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j70) #2
  br label %for.end91

for.body76:                                       ; preds = %for.cond71
  %40 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %41 = load i8, i8* %j70, align 1, !tbaa !9
  %idxprom77 = zext i8 %41 to i64
  %arrayidx78 = getelementptr inbounds i64, i64* %40, i64 %idxprom77
  %42 = load i64, i64* %arrayidx78, align 8, !tbaa !7
  %43 = load i64, i64* %perm_mask_8, align 8, !tbaa !7
  %neg79 = xor i64 %43, -1
  %and80 = and i64 %42, %neg79
  %44 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %45 = load i8, i8* %j70, align 1, !tbaa !9
  %conv81 = zext i8 %45 to i32
  %sub82 = sub nsw i32 %conv81, 8
  %idxprom83 = sext i32 %sub82 to i64
  %arrayidx84 = getelementptr inbounds i64, i64* %44, i64 %idxprom83
  %46 = load i64, i64* %arrayidx84, align 8, !tbaa !7
  %47 = load i64, i64* %perm_mask_8, align 8, !tbaa !7
  %and85 = and i64 %46, %47
  %or86 = or i64 %and80, %and85
  %48 = load i8, i8* %j70, align 1, !tbaa !9
  %idxprom87 = zext i8 %48 to i64
  %arrayidx88 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom87
  store i64 %or86, i64* %arrayidx88, align 8, !tbaa !7
  br label %for.inc89

for.inc89:                                        ; preds = %for.body76
  %49 = load i8, i8* %j70, align 1, !tbaa !9
  %inc90 = add i8 %49, 1
  store i8 %inc90, i8* %j70, align 1, !tbaa !9
  br label %for.cond71, !llvm.loop !16

for.end91:                                        ; preds = %for.cond.cleanup75
  %50 = bitcast i64* %perm_mask_4 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %50) #2
  store i64 2170205185142300190, i64* %perm_mask_4, align 8, !tbaa !7
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_4_cycle) #2
  store i8 60, i8* %perm_value_4_cycle, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_4) #2
  store i8 4, i8* %perm_value_4, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j92) #2
  store i8 0, i8* %j92, align 1, !tbaa !9
  br label %for.cond93

for.cond93:                                       ; preds = %for.inc113, %for.end91
  %51 = load i8, i8* %j92, align 1, !tbaa !9
  %conv94 = zext i8 %51 to i32
  %52 = load i8, i8* %perm_value_4, align 1, !tbaa !9
  %conv95 = zext i8 %52 to i32
  %cmp96 = icmp slt i32 %conv94, %conv95
  br i1 %cmp96, label %for.body99, label %for.cond.cleanup98

for.cond.cleanup98:                               ; preds = %for.cond93
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j92) #2
  br label %for.end115

for.body99:                                       ; preds = %for.cond93
  %53 = load i8, i8* %j92, align 1, !tbaa !9
  %idxprom100 = zext i8 %53 to i64
  %arrayidx101 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom100
  %54 = load i64, i64* %arrayidx101, align 8, !tbaa !7
  %55 = load i64, i64* %perm_mask_4, align 8, !tbaa !7
  %neg102 = xor i64 %55, -1
  %and103 = and i64 %54, %neg102
  %56 = load i8, i8* %j92, align 1, !tbaa !9
  %conv104 = zext i8 %56 to i32
  %57 = load i8, i8* %perm_value_4_cycle, align 1, !tbaa !9
  %conv105 = zext i8 %57 to i32
  %xor106 = xor i32 %conv104, %conv105
  %idxprom107 = sext i32 %xor106 to i64
  %arrayidx108 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom107
  %58 = load i64, i64* %arrayidx108, align 8, !tbaa !7
  %59 = load i64, i64* %perm_mask_4, align 8, !tbaa !7
  %and109 = and i64 %58, %59
  %or110 = or i64 %and103, %and109
  %60 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %61 = load i8, i8* %j92, align 1, !tbaa !9
  %idxprom111 = zext i8 %61 to i64
  %arrayidx112 = getelementptr inbounds i64, i64* %60, i64 %idxprom111
  store i64 %or110, i64* %arrayidx112, align 8, !tbaa !7
  br label %for.inc113

for.inc113:                                       ; preds = %for.body99
  %62 = load i8, i8* %j92, align 1, !tbaa !9
  %inc114 = add i8 %62, 1
  store i8 %inc114, i8* %j92, align 1, !tbaa !9
  br label %for.cond93, !llvm.loop !17

for.end115:                                       ; preds = %for.cond.cleanup98
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j116) #2
  %63 = load i8, i8* %perm_value_4, align 1, !tbaa !9
  store i8 %63, i8* %j116, align 1, !tbaa !9
  br label %for.cond117

for.cond117:                                      ; preds = %for.inc136, %for.end115
  %64 = load i8, i8* %j116, align 1, !tbaa !9
  %conv118 = zext i8 %64 to i32
  %cmp119 = icmp slt i32 %conv118, 64
  br i1 %cmp119, label %for.body122, label %for.cond.cleanup121

for.cond.cleanup121:                              ; preds = %for.cond117
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j116) #2
  br label %for.end138

for.body122:                                      ; preds = %for.cond117
  %65 = load i8, i8* %j116, align 1, !tbaa !9
  %idxprom123 = zext i8 %65 to i64
  %arrayidx124 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom123
  %66 = load i64, i64* %arrayidx124, align 8, !tbaa !7
  %67 = load i64, i64* %perm_mask_4, align 8, !tbaa !7
  %neg125 = xor i64 %67, -1
  %and126 = and i64 %66, %neg125
  %68 = load i8, i8* %j116, align 1, !tbaa !9
  %conv127 = zext i8 %68 to i32
  %69 = load i8, i8* %perm_value_4, align 1, !tbaa !9
  %conv128 = zext i8 %69 to i32
  %sub129 = sub nsw i32 %conv127, %conv128
  %idxprom130 = sext i32 %sub129 to i64
  %arrayidx131 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom130
  %70 = load i64, i64* %arrayidx131, align 8, !tbaa !7
  %71 = load i64, i64* %perm_mask_4, align 8, !tbaa !7
  %and132 = and i64 %70, %71
  %or133 = or i64 %and126, %and132
  %72 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %73 = load i8, i8* %j116, align 1, !tbaa !9
  %idxprom134 = zext i8 %73 to i64
  %arrayidx135 = getelementptr inbounds i64, i64* %72, i64 %idxprom134
  store i64 %or133, i64* %arrayidx135, align 8, !tbaa !7
  br label %for.inc136

for.inc136:                                       ; preds = %for.body122
  %74 = load i8, i8* %j116, align 1, !tbaa !9
  %inc137 = add i8 %74, 1
  store i8 %inc137, i8* %j116, align 1, !tbaa !9
  br label %for.cond117, !llvm.loop !18

for.end138:                                       ; preds = %for.cond.cleanup121
  %75 = bitcast i64* %perm_mask_2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %75) #2
  store i64 7378697629483820646, i64* %perm_mask_2, align 8, !tbaa !7
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_2_cycle) #2
  store i8 62, i8* %perm_value_2_cycle, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_2) #2
  store i8 2, i8* %perm_value_2, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j139) #2
  store i8 0, i8* %j139, align 1, !tbaa !9
  br label %for.cond140

for.cond140:                                      ; preds = %for.inc160, %for.end138
  %76 = load i8, i8* %j139, align 1, !tbaa !9
  %conv141 = zext i8 %76 to i32
  %77 = load i8, i8* %perm_value_2, align 1, !tbaa !9
  %conv142 = zext i8 %77 to i32
  %cmp143 = icmp slt i32 %conv141, %conv142
  br i1 %cmp143, label %for.body146, label %for.cond.cleanup145

for.cond.cleanup145:                              ; preds = %for.cond140
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j139) #2
  br label %for.end162

for.body146:                                      ; preds = %for.cond140
  %78 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %79 = load i8, i8* %j139, align 1, !tbaa !9
  %idxprom147 = zext i8 %79 to i64
  %arrayidx148 = getelementptr inbounds i64, i64* %78, i64 %idxprom147
  %80 = load i64, i64* %arrayidx148, align 8, !tbaa !7
  %81 = load i64, i64* %perm_mask_2, align 8, !tbaa !7
  %neg149 = xor i64 %81, -1
  %and150 = and i64 %80, %neg149
  %82 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %83 = load i8, i8* %j139, align 1, !tbaa !9
  %conv151 = zext i8 %83 to i32
  %84 = load i8, i8* %perm_value_2_cycle, align 1, !tbaa !9
  %conv152 = zext i8 %84 to i32
  %xor153 = xor i32 %conv151, %conv152
  %idxprom154 = sext i32 %xor153 to i64
  %arrayidx155 = getelementptr inbounds i64, i64* %82, i64 %idxprom154
  %85 = load i64, i64* %arrayidx155, align 8, !tbaa !7
  %86 = load i64, i64* %perm_mask_2, align 8, !tbaa !7
  %and156 = and i64 %85, %86
  %or157 = or i64 %and150, %and156
  %87 = load i8, i8* %j139, align 1, !tbaa !9
  %idxprom158 = zext i8 %87 to i64
  %arrayidx159 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom158
  store i64 %or157, i64* %arrayidx159, align 8, !tbaa !7
  br label %for.inc160

for.inc160:                                       ; preds = %for.body146
  %88 = load i8, i8* %j139, align 1, !tbaa !9
  %inc161 = add i8 %88, 1
  store i8 %inc161, i8* %j139, align 1, !tbaa !9
  br label %for.cond140, !llvm.loop !19

for.end162:                                       ; preds = %for.cond.cleanup145
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j163) #2
  %89 = load i8, i8* %perm_value_2, align 1, !tbaa !9
  store i8 %89, i8* %j163, align 1, !tbaa !9
  br label %for.cond164

for.cond164:                                      ; preds = %for.inc183, %for.end162
  %90 = load i8, i8* %j163, align 1, !tbaa !9
  %conv165 = zext i8 %90 to i32
  %cmp166 = icmp slt i32 %conv165, 64
  br i1 %cmp166, label %for.body169, label %for.cond.cleanup168

for.cond.cleanup168:                              ; preds = %for.cond164
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j163) #2
  br label %for.end185

for.body169:                                      ; preds = %for.cond164
  %91 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %92 = load i8, i8* %j163, align 1, !tbaa !9
  %idxprom170 = zext i8 %92 to i64
  %arrayidx171 = getelementptr inbounds i64, i64* %91, i64 %idxprom170
  %93 = load i64, i64* %arrayidx171, align 8, !tbaa !7
  %94 = load i64, i64* %perm_mask_2, align 8, !tbaa !7
  %neg172 = xor i64 %94, -1
  %and173 = and i64 %93, %neg172
  %95 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %96 = load i8, i8* %j163, align 1, !tbaa !9
  %conv174 = zext i8 %96 to i32
  %97 = load i8, i8* %perm_value_2, align 1, !tbaa !9
  %conv175 = zext i8 %97 to i32
  %sub176 = sub nsw i32 %conv174, %conv175
  %idxprom177 = sext i32 %sub176 to i64
  %arrayidx178 = getelementptr inbounds i64, i64* %95, i64 %idxprom177
  %98 = load i64, i64* %arrayidx178, align 8, !tbaa !7
  %99 = load i64, i64* %perm_mask_2, align 8, !tbaa !7
  %and179 = and i64 %98, %99
  %or180 = or i64 %and173, %and179
  %100 = load i8, i8* %j163, align 1, !tbaa !9
  %idxprom181 = zext i8 %100 to i64
  %arrayidx182 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom181
  store i64 %or180, i64* %arrayidx182, align 8, !tbaa !7
  br label %for.inc183

for.inc183:                                       ; preds = %for.body169
  %101 = load i8, i8* %j163, align 1, !tbaa !9
  %inc184 = add i8 %101, 1
  store i8 %inc184, i8* %j163, align 1, !tbaa !9
  br label %for.cond164, !llvm.loop !20

for.end185:                                       ; preds = %for.cond.cleanup168
  %102 = bitcast i64* %perm_mask_1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %102) #2
  store i64 -6148914691236517206, i64* %perm_mask_1, align 8, !tbaa !7
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_1_cycle) #2
  store i8 63, i8* %perm_value_1_cycle, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %perm_value_1) #2
  store i8 1, i8* %perm_value_1, align 1, !tbaa !9
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j186) #2
  store i8 0, i8* %j186, align 1, !tbaa !9
  br label %for.cond187

for.cond187:                                      ; preds = %for.inc207, %for.end185
  %103 = load i8, i8* %j186, align 1, !tbaa !9
  %conv188 = zext i8 %103 to i32
  %104 = load i8, i8* %perm_value_1, align 1, !tbaa !9
  %conv189 = zext i8 %104 to i32
  %cmp190 = icmp slt i32 %conv188, %conv189
  br i1 %cmp190, label %for.body193, label %for.cond.cleanup192

for.cond.cleanup192:                              ; preds = %for.cond187
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j186) #2
  br label %for.end209

for.body193:                                      ; preds = %for.cond187
  %105 = load i8, i8* %j186, align 1, !tbaa !9
  %idxprom194 = zext i8 %105 to i64
  %arrayidx195 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom194
  %106 = load i64, i64* %arrayidx195, align 8, !tbaa !7
  %107 = load i64, i64* %perm_mask_1, align 8, !tbaa !7
  %neg196 = xor i64 %107, -1
  %and197 = and i64 %106, %neg196
  %108 = load i8, i8* %j186, align 1, !tbaa !9
  %conv198 = zext i8 %108 to i32
  %109 = load i8, i8* %perm_value_1_cycle, align 1, !tbaa !9
  %conv199 = zext i8 %109 to i32
  %xor200 = xor i32 %conv198, %conv199
  %idxprom201 = sext i32 %xor200 to i64
  %arrayidx202 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom201
  %110 = load i64, i64* %arrayidx202, align 8, !tbaa !7
  %111 = load i64, i64* %perm_mask_1, align 8, !tbaa !7
  %and203 = and i64 %110, %111
  %or204 = or i64 %and197, %and203
  %112 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %113 = load i8, i8* %j186, align 1, !tbaa !9
  %idxprom205 = zext i8 %113 to i64
  %arrayidx206 = getelementptr inbounds i64, i64* %112, i64 %idxprom205
  store i64 %or204, i64* %arrayidx206, align 8, !tbaa !7
  br label %for.inc207

for.inc207:                                       ; preds = %for.body193
  %114 = load i8, i8* %j186, align 1, !tbaa !9
  %inc208 = add i8 %114, 1
  store i8 %inc208, i8* %j186, align 1, !tbaa !9
  br label %for.cond187, !llvm.loop !21

for.end209:                                       ; preds = %for.cond.cleanup192
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %j210) #2
  %115 = load i8, i8* %perm_value_1, align 1, !tbaa !9
  store i8 %115, i8* %j210, align 1, !tbaa !9
  br label %for.cond211

for.cond211:                                      ; preds = %for.inc230, %for.end209
  %116 = load i8, i8* %j210, align 1, !tbaa !9
  %conv212 = zext i8 %116 to i32
  %cmp213 = icmp slt i32 %conv212, 64
  br i1 %cmp213, label %for.body216, label %for.cond.cleanup215

for.cond.cleanup215:                              ; preds = %for.cond211
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %j210) #2
  br label %for.end232

for.body216:                                      ; preds = %for.cond211
  %117 = load i8, i8* %j210, align 1, !tbaa !9
  %idxprom217 = zext i8 %117 to i64
  %arrayidx218 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom217
  %118 = load i64, i64* %arrayidx218, align 8, !tbaa !7
  %119 = load i64, i64* %perm_mask_1, align 8, !tbaa !7
  %neg219 = xor i64 %119, -1
  %and220 = and i64 %118, %neg219
  %120 = load i8, i8* %j210, align 1, !tbaa !9
  %conv221 = zext i8 %120 to i32
  %121 = load i8, i8* %perm_value_1, align 1, !tbaa !9
  %conv222 = zext i8 %121 to i32
  %sub223 = sub nsw i32 %conv221, %conv222
  %idxprom224 = sext i32 %sub223 to i64
  %arrayidx225 = getelementptr inbounds [64 x i64], [64 x i64]* @buffer_helper, i64 0, i64 %idxprom224
  %122 = load i64, i64* %arrayidx225, align 8, !tbaa !7
  %123 = load i64, i64* %perm_mask_1, align 8, !tbaa !7
  %and226 = and i64 %122, %123
  %or227 = or i64 %and220, %and226
  %124 = load i64*, i64** %buffer.addr, align 8, !tbaa !3
  %125 = load i8, i8* %j210, align 1, !tbaa !9
  %idxprom228 = zext i8 %125 to i64
  %arrayidx229 = getelementptr inbounds i64, i64* %124, i64 %idxprom228
  store i64 %or227, i64* %arrayidx229, align 8, !tbaa !7
  br label %for.inc230

for.inc230:                                       ; preds = %for.body216
  %126 = load i8, i8* %j210, align 1, !tbaa !9
  %inc231 = add i8 %126, 1
  store i8 %inc231, i8* %j210, align 1, !tbaa !9
  br label %for.cond211, !llvm.loop !22

for.end232:                                       ; preds = %for.cond.cleanup215
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_1) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_1_cycle) #2
  %127 = bitcast i64* %perm_mask_1 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %127) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_2) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_2_cycle) #2
  %128 = bitcast i64* %perm_mask_2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %128) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_4) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_4_cycle) #2
  %129 = bitcast i64* %perm_mask_4 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %129) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_8) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_8_cylce) #2
  %130 = bitcast i64* %perm_mask_8 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %130) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_16_cylce) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_16) #2
  %131 = bitcast i64* %perm_mask_16 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %131) #2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %perm_value_32) #2
  %132 = bitcast i64* %perm_mask_32 to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %132) #2
  ret void
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="haswell" "target-features"="+avx,+avx2,+bmi,+bmi2,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+rdrnd,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsaveopt" }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"clang version 14.0.6 (git@github.com:OpenCilk/opencilk-project.git 663595447257caa2441f8f142b59d4f0e92c9271)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!8, !8, i64 0}
!8 = !{!"long", !5, i64 0}
!9 = !{!5, !5, i64 0}
!10 = distinct !{!10, !11, !12}
!11 = !{!"llvm.loop.mustprogress"}
!12 = !{!"llvm.loop.unroll.enable"}
!13 = distinct !{!13, !11, !12}
!14 = distinct !{!14, !11, !12}
!15 = distinct !{!15, !11, !12}
!16 = distinct !{!16, !11, !12}
!17 = distinct !{!17, !11, !12}
!18 = distinct !{!18, !11, !12}
!19 = distinct !{!19, !11, !12}
!20 = distinct !{!20, !11, !12}
!21 = distinct !{!21, !11, !12}
!22 = distinct !{!22, !11, !12}
