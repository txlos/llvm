; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-darwin -mattr=+mmx,+sse2 | FileCheck --check-prefix=X32 %s
; RUN: llc < %s -mtriple=x86_64-darwin -mattr=+mmx,+sse2 | FileCheck --check-prefix=X64 %s

; If there is no explicit MMX type usage, always promote to XMM.

define void @test0(<1 x i64>* %x) {
; X32-LABEL: test0:
; X32:       ## %bb.0: ## %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; X32-NEXT:    movlps %xmm0, (%eax)
; X32-NEXT:    retl
;
; X64-LABEL: test0:
; X64:       ## %bb.0: ## %entry
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,2,3]
; X64-NEXT:    movq %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
  %tmp2 = load <1 x i64>, <1 x i64>* %x
  %tmp6 = bitcast <1 x i64> %tmp2 to <2 x i32>
  %tmp9 = shufflevector <2 x i32> %tmp6, <2 x i32> undef, <2 x i32> < i32 1, i32 1 >
  %tmp10 = bitcast <2 x i32> %tmp9 to <1 x i64>
  store <1 x i64> %tmp10, <1 x i64>* %x
  ret void
}

define void @test1() {
; X32-LABEL: test1:
; X32:       ## %bb.0: ## %entry
; X32-NEXT:    pushl %edi
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    subl $8, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    .cfi_offset %edi, -8
; X32-NEXT:    pxor %mm0, %mm0
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    movsd %xmm0, (%esp)
; X32-NEXT:    movq (%esp), %mm1
; X32-NEXT:    xorl %edi, %edi
; X32-NEXT:    maskmovq %mm1, %mm0
; X32-NEXT:    addl $8, %esp
; X32-NEXT:    popl %edi
; X32-NEXT:    retl
;
; X64-LABEL: test1:
; X64:       ## %bb.0: ## %entry
; X64-NEXT:    pxor %mm0, %mm0
; X64-NEXT:    movq {{.*}}(%rip), %rax
; X64-NEXT:    movq %rax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq -{{[0-9]+}}(%rsp), %mm1
; X64-NEXT:    xorl %edi, %edi
; X64-NEXT:    maskmovq %mm1, %mm0
; X64-NEXT:    retq
entry:
  %tmp528 = bitcast <8 x i8> zeroinitializer to <2 x i32>
  %tmp529 = and <2 x i32> %tmp528, bitcast (<4 x i16> < i16 -32640, i16 16448, i16 8224, i16 4112 > to <2 x i32>)
  %tmp542 = bitcast <2 x i32> %tmp529 to <4 x i16>
  %tmp543 = add <4 x i16> %tmp542, < i16 0, i16 16448, i16 24672, i16 28784 >
  %tmp555 = bitcast <4 x i16> %tmp543 to <8 x i8>
  %tmp556 = bitcast <8 x i8> %tmp555 to x86_mmx
  %tmp557 = bitcast <8 x i8> zeroinitializer to x86_mmx
  tail call void @llvm.x86.mmx.maskmovq( x86_mmx %tmp557, x86_mmx %tmp556, i8* null)
  ret void
}

@tmp_V2i = common global <2 x i32> zeroinitializer

define void @test2() nounwind {
; X32-LABEL: test2:
; X32:       ## %bb.0: ## %entry
; X32-NEXT:    movl L_tmp_V2i$non_lazy_ptr, %eax
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0,0,1,1]
; X32-NEXT:    movlps %xmm0, (%eax)
; X32-NEXT:    retl
;
; X64-LABEL: test2:
; X64:       ## %bb.0: ## %entry
; X64-NEXT:    movq _tmp_V2i@{{.*}}(%rip), %rax
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; X64-NEXT:    movq %xmm0, (%rax)
; X64-NEXT:    retq
entry:
  %0 = load <2 x i32>, <2 x i32>* @tmp_V2i, align 8
  %1 = shufflevector <2 x i32> %0, <2 x i32> undef, <2 x i32> zeroinitializer
  store <2 x i32> %1, <2 x i32>* @tmp_V2i, align 8
  ret void
}

define <4 x float> @pr35869() nounwind {
; X32-LABEL: pr35869:
; X32:       ## %bb.0:
; X32-NEXT:    movl $64, %eax
; X32-NEXT:    movd %eax, %mm0
; X32-NEXT:    pxor %mm1, %mm1
; X32-NEXT:    punpcklbw %mm1, %mm0 ## mm0 = mm0[0],mm1[0],mm0[1],mm1[1],mm0[2],mm1[2],mm0[3],mm1[3]
; X32-NEXT:    pcmpgtw %mm0, %mm1
; X32-NEXT:    movq %mm0, %mm2
; X32-NEXT:    punpckhwd %mm1, %mm2 ## mm2 = mm2[2],mm1[2],mm2[3],mm1[3]
; X32-NEXT:    xorps %xmm0, %xmm0
; X32-NEXT:    cvtpi2ps %mm2, %xmm0
; X32-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0,0]
; X32-NEXT:    punpcklwd %mm1, %mm0 ## mm0 = mm0[0],mm1[0],mm0[1],mm1[1]
; X32-NEXT:    cvtpi2ps %mm0, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: pr35869:
; X64:       ## %bb.0:
; X64-NEXT:    movl $64, %eax
; X64-NEXT:    movd %eax, %mm0
; X64-NEXT:    pxor %mm1, %mm1
; X64-NEXT:    punpcklbw %mm1, %mm0 ## mm0 = mm0[0],mm1[0],mm0[1],mm1[1],mm0[2],mm1[2],mm0[3],mm1[3]
; X64-NEXT:    pcmpgtw %mm0, %mm1
; X64-NEXT:    movq %mm0, %mm2
; X64-NEXT:    punpckhwd %mm1, %mm2 ## mm2 = mm2[2],mm1[2],mm2[3],mm1[3]
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    cvtpi2ps %mm2, %xmm0
; X64-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0,0]
; X64-NEXT:    punpcklwd %mm1, %mm0 ## mm0 = mm0[0],mm1[0],mm0[1],mm1[1]
; X64-NEXT:    cvtpi2ps %mm0, %xmm0
; X64-NEXT:    retq
  %1 = tail call x86_mmx @llvm.x86.mmx.punpcklbw(x86_mmx bitcast (<8 x i8> <i8 64, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0> to x86_mmx), x86_mmx bitcast (<8 x i8> zeroinitializer to x86_mmx))
  %2 = tail call x86_mmx @llvm.x86.mmx.pcmpgt.w(x86_mmx bitcast (<4 x i16> zeroinitializer to x86_mmx), x86_mmx %1)
  %3 = tail call x86_mmx @llvm.x86.mmx.punpckhwd(x86_mmx %1, x86_mmx %2)
  %4 = tail call <4 x float> @llvm.x86.sse.cvtpi2ps(<4 x float> zeroinitializer, x86_mmx %3)
  %5 = shufflevector <4 x float> %4, <4 x float> undef, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %6 = tail call x86_mmx @llvm.x86.mmx.punpcklwd(x86_mmx %1, x86_mmx %2)
  %7 = tail call <4 x float> @llvm.x86.sse.cvtpi2ps(<4 x float> %5, x86_mmx %6)
  ret <4 x float> %7
}

declare void @llvm.x86.mmx.maskmovq(x86_mmx, x86_mmx, i8*)
declare x86_mmx @llvm.x86.mmx.pcmpgt.w(x86_mmx, x86_mmx)
declare x86_mmx @llvm.x86.mmx.punpcklbw(x86_mmx, x86_mmx)
declare x86_mmx @llvm.x86.mmx.punpcklwd(x86_mmx, x86_mmx)
declare x86_mmx @llvm.x86.mmx.punpckhwd(x86_mmx, x86_mmx)
declare <4 x float> @llvm.x86.sse.cvtpi2ps(<4 x float>, x86_mmx)
