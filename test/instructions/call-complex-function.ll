; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc -spirv-text -o - | FileCheck %s  --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc -o - | FileCheck %s --check-prefix=CHECK-LLVM

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64"

; CHECK-SPIRV-DAG: Name [[#FUN:]] "fun"
; CHECK-SPIRV-DAG: Name [[#FOO:]] "foo"
; CHECK-SPIRV-DAG: Name [[#GOO:]] "goo"

; CHECK-SPIRV-DAG: TypeInt [[#I16:]] 16
; CHECK-SPIRV-DAG: TypeInt [[#I32:]] 32
; CHECK-SPIRV-DAG: TypeInt [[#I64:]] 64
; CHECK-SPIRV-DAG: TypeFunction [[#FN3:]] [[#I32]] [[#I32]] [[#I16]] [[#I64]]
; CHECK-SPIRV-DAG: TypeStruct [[#PAIR:]] [[#I32]] [[#I16]]
; CHECK-SPIRV-DAG: TypeFunction [[#FN1:]] [[#I32]] [[#I32]]
; CHECK-SPIRV-DAG: TypeFunction [[#FN2:]] [[#I32]] [[#PAIR]] [[#I64]]
; CHECK-SPIRV-DAG: Undef [[#PAIR]] [[#UNDEF:]]

declare i32 @fun(i32 %value)

; CHECK-SPIRV: Function [[#I32]] [[#FUN]] [[#]] [[#FN1]]
; CHECK-SPIRV: FunctionParameter [[#I32]] [[#]]
; CHECK-SPIRV-DAG: FunctionEnd 

; CHECK-LLVM: define spir_func i32 @foo
; CHECK-LLVM: extractvalue
; CHECK-LLVM: call spir_func i32 @fun
; CHECK-LLVM: ret i32

define i32 @foo({i32, i16} %in, i64 %unused) {
  %first = extractvalue {i32, i16} %in, 0
  %bar = call i32 @fun(i32 %first)
  ret i32 %bar
}

; CHECK-SPIRV: Function [[#I32]] [[#FOO]] 0 [[#FN2]]
; CHECK-SPIRV-DAG: FunctionParameter [[#PAIR]] [[#IN:]] 
; CHECK-SPIRV-DAG: FunctionParameter [[#I64]] [[#]]
; CHECK-SPIRV: CompositeExtract [[#I32]] [[#FIRST:]] [[#IN]] 0
; CHECK-SPIRV: FunctionCall [[#I32]] [[#BAR:]] [[#FUN]] [[#FIRST]]
; CHECK-SPIRV: ReturnValue [[#BAR]]
; CHECK-SPIRV: FunctionEnd
; CHECK-SPIRV: Function [[#I32]] [[#GOO]] [[#]] [[#FN3]]
; CHECK-SPIRV-DAG: FunctionParameter [[#I32]] [[#A:]] 
; CHECK-SPIRV-DAG: FunctionParameter [[#I16]] [[#B:]] 
; CHECK-SPIRV-DAG: FunctionParameter [[#I64]]  [[#C:]]
; CHECK-SPIRV: CompositeInsert [[#PAIR]] [[#AGG1:]] [[#A]] [[#UNDEF]] 0
; CHECK-SPIRV: CompositeInsert [[#PAIR]] [[#AGG2:]] [[#B]] [[#AGG1]] 1
; CHECK-SPIRV: FunctionCall [[#I32]] [[#RET:]] [[#FOO]] [[#AGG2]] [[#C]]
; CHECK-SPIRV: ReturnValue [[#RET]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func i32 @goo
; CHECK-LLVM: insertvalue
; CHECK-LLVM: insertvalue
; CHECK-LLVM: call spir_func i32 @foo
; CHECK-LLVM: i32 %ret

define i32 @goo(i32 %a, i16 %b, i64 %c) {
  %agg1 = insertvalue {i32, i16} undef, i32 %a, 0
  %agg2 = insertvalue {i32, i16} %agg1, i16 %b, 1
  %ret = call i32 @foo({i32, i16} %agg2, i64 %c)
  ret i32 %ret
}
