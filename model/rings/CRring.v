(*
Copyright © 2006-2008 Russell O’Connor

Permission is hereby granted, free of charge, to any person obtaining a copy of
this proof and associated documentation files (the "Proof"), to deal in
the Proof without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Proof, and to permit persons to whom the Proof is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Proof.

THE PROOF IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE PROOF OR THE USE OR OTHER DEALINGS IN THE PROOF.
*)

Require Export CoRN.reals.fast.CRFieldOps.
Require Export CoRN.model.abgroups.CRabgroup.
Require Export CoRN.algebra.CRings.
Require Import CoRN.reals.fast.CRcorrect.
Require Import CoRN.tactics.Rational.
Require Import CoRN.tactics.CornTac.

(**
** Example of a ring: $\langle$#&lang;#[CR],[+],[*]$\rangle$#&rang;#
*)

Local Open Scope uc_scope.

Lemma CRmult_strext : bin_op_strext CRasCSetoid CRmult.
Proof.
 intros x1 x2 y1 y2 H.
 simpl in *.
 autorewrite with CRtoCauchy_IR in H.
 assert (X:(CRasCauchy_IR x1[*]CRasCauchy_IR y1)[#](CRasCauchy_IR x2[*]CRasCauchy_IR y2)).
  stepl (CRasCauchy_IR (x1*y1)%CR); [| now apply eq_symmetric; apply CR_mult_as_Cauchy_IR_mult].
  stepr (CRasCauchy_IR (x2*y2)%CR); [| now apply eq_symmetric; apply CR_mult_as_Cauchy_IR_mult].
  apply CR_ap_as_Cauchy_IR_ap_1.
  assumption.
 destruct (bin_op_strext_unfolded _ _ _ _ _ _ X);[left|right];
   apply CR_ap_as_Cauchy_IR_ap_2; assumption.
Qed.

Definition CRmultasBinOp : CSetoid_bin_op CRasCSetoid :=
Build_CSetoid_bin_fun _ _ _ _ CRmult_strext.

Lemma CRmultAssoc : associative CRmultasBinOp.
Proof.
 intros x y z.
 change (x*(y*z)==(x*y)*z)%CR.
 rewrite <- CR_eq_as_Cauchy_IR_eq.
 stepl ((CRasCauchy_IR x)[*](CRasCauchy_IR (y*z)%CR)); [| now apply CR_mult_as_Cauchy_IR_mult].
 stepl ((CRasCauchy_IR x)[*]((CRasCauchy_IR y)[*](CRasCauchy_IR z))); [| now
   apply  bin_op_is_wd_un_op_rht; apply CR_mult_as_Cauchy_IR_mult].
 stepr ((CRasCauchy_IR (x*y)%CR)[*](CRasCauchy_IR z)); [| now apply CR_mult_as_Cauchy_IR_mult].
 stepr (((CRasCauchy_IR x)[*](CRasCauchy_IR y))[*](CRasCauchy_IR z)); [| now
   apply bin_op_is_wd_un_op_lft; apply CR_mult_as_Cauchy_IR_mult].
 apply mult_assoc_unfolded.
Qed.

Lemma CRisCRing : is_CRing CRasCAbGroup 1%CR CRmultasBinOp.
Proof.
 apply Build_is_CRing with CRmultAssoc.
    split.
     intros x.
     change (x*1==x)%CR.
     rewrite <- CR_eq_as_Cauchy_IR_eq.
     stepl ((CRasCauchy_IR x)[*](CRasCauchy_IR (inject_Q_CR 1))); [| now apply CR_mult_as_Cauchy_IR_mult].
     stepl ((CRasCauchy_IR x)[*][1]); [| now
       apply bin_op_is_wd_un_op_rht; apply: CR_inject_Q_as_Cauchy_IR_inject_Q].
     rational.
    intros x.
    change ((inject_Q_CR 1%Q)*x==x)%CR.
    rewrite <- CR_eq_as_Cauchy_IR_eq.
    stepl ((CRasCauchy_IR (inject_Q_CR 1))[*](CRasCauchy_IR x)); [| now apply CR_mult_as_Cauchy_IR_mult].
    stepl ([1][*](CRasCauchy_IR x)); [| now
      apply bin_op_is_wd_un_op_lft; apply: CR_inject_Q_as_Cauchy_IR_inject_Q].
    rational.
   intros x y.
   change (x*y==y*x)%CR.
   rewrite <- CR_eq_as_Cauchy_IR_eq.
   stepl ((CRasCauchy_IR x)[*](CRasCauchy_IR y)); [| now apply CR_mult_as_Cauchy_IR_mult].
   stepr ((CRasCauchy_IR y)[*](CRasCauchy_IR x)); [| now apply CR_mult_as_Cauchy_IR_mult].
   rational.
  intros x y z.
  change (x*(y+z)==x*y+x*z)%CR.
  rewrite <- CR_eq_as_Cauchy_IR_eq.
  stepl ((CRasCauchy_IR x)[*](CRasCauchy_IR (y+z)%CR)); [| now apply CR_mult_as_Cauchy_IR_mult].
  stepl ((CRasCauchy_IR x)[*]((CRasCauchy_IR y)[+](CRasCauchy_IR z))); [| now
    apply bin_op_is_wd_un_op_rht; apply CR_plus_as_Cauchy_IR_plus].
  stepr ((CRasCauchy_IR (x*y)%CR)[+](CRasCauchy_IR (x*z)%CR)); [| now apply CR_plus_as_Cauchy_IR_plus].
  stepr (((CRasCauchy_IR x)[*](CRasCauchy_IR y))[+]((CRasCauchy_IR x)[*](CRasCauchy_IR z))).
   apply dist.
  apply cs_bin_op_wd; apply CR_mult_as_Cauchy_IR_mult.
 change (CRapartT 1 0)%CR.
 apply CR_ap_as_Cauchy_IR_ap_2.
 eapply ap_wd.
   apply one_ap_zero.
  apply: CR_inject_Q_as_Cauchy_IR_inject_Q.
 apply: CR_inject_Q_as_Cauchy_IR_inject_Q.
Qed.

Definition CRasCRing : CRing :=
Build_CRing _ _ _ CRisCRing.

Canonical Structure CRasCRing.
