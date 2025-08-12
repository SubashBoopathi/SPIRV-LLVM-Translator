; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc -spirv-text -o - | FileCheck %s --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc -o - | FileCheck %s --check-prefix=CHECK-LLVM

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64"
 
; CHECK-SPIRV-DAG: Name [[#TRUNC32_16:]] "f32tof16"
; CHECK-SPIRV-DAG: Name [[#EXT16_32:]] "f16tof32"
; CHECK-SPIRV-DAG: Name [[#TRUNC32_16v3:]] "f32tof16v3"
; CHECK-SPIRV-DAG: Name [[#EXT16_32v3:]] "f16tof32v3"
; CHECK-SPIRV-DAG: Name [[#F32toS32:]] "f32tos32"
; CHECK-SPIRV-DAG: Name [[#F32toS16:]] "f32tos16"
; CHECK-SPIRV-DAG: Name [[#F32toS8:]] "f32tos8"
; CHECK-SPIRV-DAG: Name [[#F16toS32:]] "f16tos32"
; CHECK-SPIRV-DAG: Name [[#F16toS16:]] "f16tos16"
; CHECK-SPIRV-DAG: Name [[#F16toS8:]] "f16tos8"
; CHECK-SPIRV-DAG: Name [[#F32toU32v2:]] "f32tou32v2"
; CHECK-SPIRV-DAG: Name [[#F32toU16v2:]] "f32tou16v2"
; CHECK-SPIRV-DAG: Name [[#F32toU8v2:]] "f32tou8v2"
; CHECK-SPIRV-DAG: Name [[#F16toU32v2:]] "f16tou32v2"
; CHECK-SPIRV-DAG: Name [[#F16toU16v2:]] "f16tou16v2"
; CHECK-SPIRV-DAG: Name [[#F16toU8v2:]] "f16tou8v2"

; CHECK-SPIRV-DAG: TypeFloat [[#F32:]] 32
; CHECK-SPIRV-DAG: TypeFloat [[#F16:]] 16
; CHECK-SPIRV-DAG: TypeVector [[#F32v2:]] [[#F32]] 2
; CHECK-SPIRV-DAG: TypeVector [[#F16v2:]] [[#F16]] 2
; CHECK-SPIRV-DAG: TypeVector [[#F32v3:]] [[#F32]] 3
; CHECK-SPIRV-DAG: TypeVector [[#F16v3:]] [[#F16]] 3
; CHECK-SPIRV-DAG: TypeInt [[#U32:]] 32 0
; CHECK-SPIRV-DAG: TypeInt [[#U16:]] 16 0
; CHECK-SPIRV-DAG: TypeInt [[#U8:]] 8 0
; CHECK-SPIRV-DAG: TypeVector [[#U32v2:]] [[#U32]] 2
; CHECK-SPIRV-DAG: TypeVector [[#U16v2:]] [[#U16]] 2
; CHECK-SPIRV-DAG: TypeVector [[#U8v2:]] [[#U8]] 2

; CHECK-SPIRV: Function [[#F16]] [[#TRUNC32_16]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F32]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: FConvert [[#F16]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd 

; CHECK-LLVM: define spir_func half @f32tof16
; CHECK-LLVM: fptrunc float
; CHECK-LLVM: ret half

define half @f32tof16(float %a) {
    %r = fptrunc float %a to half
    ret half %r
}

; CHECK-SPIRV: Function [[#F32]] [[#EXT16_32]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F16]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: FConvert [[#F32]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd 

; CHECK-LLVM: define spir_func float @f16tof32
; CHECK-LLVM: fpext half
; CHECK-LLVM: ret float

define float @f16tof32(half %a) {
  %r = fpext half %a to float
  ret float %r
}

; CHECK-SPIRV: Function [[#F16v3]] [[#TRUNC32_16v3]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F32v3]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: FConvert [[#F16v3]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd 

; CHECK-LLVM: define spir_func <3 x half> @f32tof16v3
; CHECK-LLVM: call spir_func <3 x half> @_Z13convert_half3Dv3_f
; CHECK-LLVM: ret <3 x half>

define <3 x half> @f32tof16v3(<3 x float> %a) {
    %r = fptrunc <3 x float> %a to <3 x half>
    ret <3 x half> %r
}

; CHECK-SPIRV: Function [[#F32v3]] [[#EXT16_32v3]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F16v3]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: FConvert [[#F32v3]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd 

; CHECK-LLVM: define spir_func <3 x float> @f16tof32v3
; CHECK-LLVM: call spir_func <3 x float> @_Z14convert_float3Dv3_Dh
; CHECK-LLVM: ret <3 x float>

define <3 x float> @f16tof32v3(<3 x half> %a) {
  %r = fpext <3 x half> %a to <3 x float>
  ret <3 x float> %r
}

; CHECK-SPIRV: Function [[#U32]] [[#F32toS32]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F32]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToS [[#U32]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd 

; CHECK-LLVM: define spir_func i32 @f32tos32
; CHECK-LLVM: fptosi float
; CHECK-LLVM: ret i32

define i32 @f32tos32(float %a) {
  %r = fptosi float %a to i32
  ret i32 %r
}

; CHECK-SPIRV: Function [[#U16]] [[#F32toS16]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F32]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToS [[#U16]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd 

; CHECK-LLVM: define spir_func i16 @f32tos16
; CHECK-LLVM: fptosi float
; CHECK-LLVM: ret i16

define i16 @f32tos16(float %a) {
  %r = fptosi float %a to i16
  ret i16 %r
}

; CHECK-SPIRV: Function [[#U8]] [[#F32toS8]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F32]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToS [[#U8]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func i8 @f32tos8
; CHECK-LLVM: fptosi float
; CHECK-LLVM: ret i8

define i8 @f32tos8(float %a) {
  %r = fptosi float %a to i8
  ret i8 %r
}

; CHECK-SPIRV: Function [[#U32]] [[#F16toS32]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F16]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToS [[#U32]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func i32 @f16tos32
; CHECK-LLVM: fptosi half
; CHECK-LLVM: ret i32

define i32 @f16tos32(half %a) {
  %r = fptosi half %a to i32
  ret i32 %r
}

; CHECK-SPIRV: Function [[#U16]] [[#F16toS16]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F16]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToS [[#U16]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func i16 @f16tos16
; CHECK-LLVM: fptosi half
; CHECK-LLVM: ret i16

define i16 @f16tos16(half %a) {
  %r = fptosi half %a to i16
  ret i16 %r
}

; CHECK-SPIRV: Function [[#U8]] [[#F16toS8]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F16]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToS [[#U8]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func i8 @f16tos8
; CHECK-LLVM: fptosi half
; CHECK-LLVM: ret i8

define i8 @f16tos8(half %a) {
  %r = fptosi half %a to i8
  ret i8 %r
}

; CHECK-SPIRV: Function [[#U32v2]] [[#F32toU32v2]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F32v2]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToU [[#U32v2]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func <2 x i32> @f32tou32v2
; CHECK-LLVM: call spir_func <2 x i32> @_Z13convert_uint2Dv2_f
; CHECK-LLVM: ret <2 x i32>

define <2 x i32> @f32tou32v2(<2 x float> %a) {
  %r = fptoui <2 x float> %a to <2 x i32>
  ret <2 x i32> %r
}

; CHECK-SPIRV: Function [[#U16v2]] [[#F32toU16v2]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F32v2]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToU [[#U16v2]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func <2 x i16> @f32tou16v2
; CHECK-LLVM: call spir_func <2 x i16> @_Z15convert_ushort2Dv2_f
; CHECK-LLVM: ret <2 x i16>

define <2 x i16> @f32tou16v2(<2 x float> %a) {
  %r = fptoui <2 x float> %a to <2 x i16>
  ret <2 x i16> %r
}

; CHECK-SPIRV: Function [[#U8v2]] [[#F32toU8v2]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F32v2]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToU [[#U8v2]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func <2 x i8> @f32tou8v2
; CHECK-LLVM: call spir_func <2 x i8> @_Z14convert_uchar2Dv2_f
; CHECK-LLVM: ret <2 x i8>

define <2 x i8> @f32tou8v2(<2 x float> %a) {
  %r = fptoui <2 x float> %a to <2 x i8>
  ret <2 x i8> %r
}

; CHECK-SPIRV: Function [[#U32v2]] [[#F16toU32v2]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F16v2]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToU [[#U32v2]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func <2 x i32> @f16tou32v2
; CHECK-LLVM: call spir_func <2 x i32> @_Z13convert_uint2Dv2_Dh
; CHECK-LLVM: ret <2 x i32>

define <2 x i32> @f16tou32v2(<2 x half> %a) {
  %r = fptoui <2 x half> %a to <2 x i32>
  ret <2 x i32> %r
}

; CHECK-SPIRV: Function [[#U16v2]] [[#F16toU16v2]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F16v2]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToU [[#U16v2]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func <2 x i16> @f16tou16v2
; CHECK-LLVM: call spir_func <2 x i16> @_Z15convert_ushort2Dv2_Dh
; CHECK-LLVM: ret <2 x i16>

define <2 x i16> @f16tou16v2(<2 x half> %a) {
  %r = fptoui <2 x half> %a to <2 x i16>
  ret <2 x i16> %r
}

; CHECK-SPIRV: Function [[#U8v2]] [[#F16toU8v2]] [[#]] [[#]]
; CHECK-SPIRV-NEXT: FunctionParameter [[#F16v2]] [[#A:]]
; CHECK-SPIRV: Label
; CHECK-SPIRV: ConvertFToU [[#U8v2]] [[#R:]] [[#A]]
; CHECK-SPIRV: ReturnValue [[#R]]
; CHECK-SPIRV: FunctionEnd

; CHECK-LLVM: define spir_func <2 x i8> @f16tou8v2
; CHECK-LLVM: call spir_func <2 x i8> @_Z14convert_uchar2Dv2_Dh
; CHECK-LLVM: ret <2 x i8>

define <2 x i8> @f16tou8v2(<2 x half> %a) {
  %r = fptoui <2 x half> %a to <2 x i8>
  ret <2 x i8> %r
}
