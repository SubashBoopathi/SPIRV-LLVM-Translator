; This test ensures that LLVM IR bitwise instructions result in logical SPIR-V instructions
; when applied to i1 type

; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc -spirv-text -o - | FileCheck %s --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc -o - | FileCheck %s --check-prefix=CHECK-LLVM

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64"

; CHECK-SPIRV-DAG: TypeInt [[#Char:]] 8 0
; CHECK-SPIRV-DAG: TypeVector [[#Vec2Char:]] [[#Char]] [[#]]
; CHECK-SPIRV-DAG: TypeBool [[#Bool:]]
; CHECK-SPIRV-DAG: TypeVector [[#Vec2Bool:]] [[#Bool]] [[#]]

; CHECK-SPIRV: BitwiseAnd [[#Char]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: BitwiseOr [[#Char]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: BitwiseXor [[#Char]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: BitwiseAnd [[#Vec2Char]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: BitwiseOr [[#Vec2Char]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: BitwiseXor [[#Vec2Char]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: LogicalAnd [[#Bool]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: LogicalOr [[#Bool]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: LogicalNotEqual [[#Bool]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: LogicalAnd [[#Vec2Bool]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: LogicalOr [[#Vec2Bool]] [[#]] [[#]] [[#]]
; CHECK-SPIRV: LogicalNotEqual [[#Vec2Bool]] [[#]] [[#]] [[#]]

; CHECK-LLVM: define spir_func void @test1
; CHECK-LLVM: and
; CHECK-LLVM: or
; CHECK-LLVM: xor

define void @test1(i8 noundef %arg1, i8 noundef %arg2) {
  %cond1 = and i8 %arg1, %arg2
  %cond2 = or i8 %arg1, %arg2
  %cond3 = xor i8 %arg1, %arg2
  ret void
}

; CHECK-LLVM: define spir_func void @test1v
; CHECK-LLVM: and
; CHECK-LLVM: or
; CHECK-LLVM: xor

define void @test1v(<2 x i8> noundef %arg1, <2 x i8> noundef %arg2) {
  %cond1 = and <2 x i8> %arg1, %arg2
  %cond2 = or <2 x i8> %arg1, %arg2
  %cond3 = xor <2 x i8> %arg1, %arg2
  ret void
}

; CHECK-LLVM: define spir_func void @test2
; CHECK-LLVM: call spir_func float @_Z4fabsf(float %real)
; CHECK-LLVM: fcmp oeq
; CHECK-LLVM: fcmp oeq
; CHECK-LLVM: and 

define void @test2(float noundef %real, float noundef %imag) {
entry:
  %realabs = tail call spir_func noundef float @_Z16__spirv_ocl_fabsf(float noundef %real)
  %cond1 = fcmp oeq float %realabs, 1.000000e+00
  %cond2 = fcmp oeq float %imag, 0.000000e+00
  %cond3 = and i1 %cond1, %cond2
  br i1 %cond3, label %midlbl, label %cleanup
midlbl:
  br label %cleanup
cleanup:
  ret void
}

; CHECK-LLVM: define spir_func void @test3
; CHECK-LLVM: and
; CHECK-LLVM: or
; CHECK-LLVM: icmp ne

define void @test3(i1 noundef %arg1, i1 noundef %arg2) {
  %cond1 = and i1 %arg1, %arg2
  %cond2 = or i1 %arg1, %arg2
  %cond3 = xor i1 %arg1, %arg2
  ret void
}

; CHECK-LLVM: define spir_func void @test3v
; CHECK-LLVM: and
; CHECK-LLVM: or
; CHECK-LLVM: icmp ne

define void @test3v(<2 x i1> noundef %arg1, <2 x i1> noundef %arg2) {
  %cond1 = and <2 x i1> %arg1, %arg2
  %cond2 = or <2 x i1> %arg1, %arg2
  %cond3 = xor <2 x i1> %arg1, %arg2
  ret void
}

declare dso_local spir_func noundef float @_Z16__spirv_ocl_fabsf(float noundef)
