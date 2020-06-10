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

Require Import CoRN.algebra.RSetoid.
Require Import CoRN.metric2.Metric.
Require Import CoRN.metric2.UniformContinuity.
Require Export CoRN.reals.fast.CRFieldOps.
Require Export CoRN.model.rings.CRring.
Require Export CoRN.algebra.CFields.
Require Import CoRN.reals.fast.CRcorrect.
Require Import CoRN.tactics.CornTac.

(**
** Example of a field: $\langle$#&lang;#[CR],[+],[*]$\rangle$#&rang;#
*)

Local Open Scope uc_scope.

Lemma CRisCField : is_CField CRasCRing CRinvT.
Proof.
 intros x x_.
 split.
  change (x*(CRinvT x x_)==1)%CR.
  rewrite <- CR_eq_as_Cauchy_IR_eq.
  stepl ((CRasCauchy_IR x)[*](CRasCauchy_IR (CRinvT x x_))); [| now apply CR_mult_as_Cauchy_IR_mult].
  stepl ((CRasCauchy_IR x)[*](f_rcpcl (CRasCauchy_IR x) (CR_nonZero_as_Cauchy_IR_nonZero_1 _ x_))); [| now
    apply bin_op_is_wd_un_op_rht; apply CR_inv_as_Cauchy_IR_inv].
  eapply eq_transitive.
   apply field_mult_inv.
  apply: CR_inject_Q_as_Cauchy_IR_inject_Q.
 change ((CRinvT x x_)*x==1)%CR.
 rewrite <- CR_eq_as_Cauchy_IR_eq.
 stepl ((CRasCauchy_IR (CRinvT x x_))[*](CRasCauchy_IR x)); [| now apply CR_mult_as_Cauchy_IR_mult].
 stepl ((f_rcpcl (CRasCauchy_IR x) (CR_nonZero_as_Cauchy_IR_nonZero_1 _ x_))[*](CRasCauchy_IR x)); [| now
   apply bin_op_is_wd_un_op_lft; apply CR_inv_as_Cauchy_IR_inv].
 eapply eq_transitive.
  apply field_mult_inv_op.
 apply: CR_inject_Q_as_Cauchy_IR_inject_Q.
Qed.

Lemma CRinv_strext : forall x y x_ y_, CRapartT (CRinvT x x_) (CRinvT y y_) -> CRapartT x y.
Proof.
 intros x y x_ y_ H.
 apply CR_ap_as_Cauchy_IR_ap_2.
 apply cf_rcpsx with
   (CR_nonZero_as_Cauchy_IR_nonZero_1 _ x_) (CR_nonZero_as_Cauchy_IR_nonZero_1 _ y_).
 stepl (CRasCauchy_IR (CRinvT x x_)%CR); [| now
   apply eq_symmetric; apply (CR_inv_as_Cauchy_IR_inv_short x x_)].
 stepr (CRasCauchy_IR (CRinvT y y_)%CR); [| now
   apply eq_symmetric; apply (CR_inv_as_Cauchy_IR_inv_short y y_)].
 apply CR_ap_as_Cauchy_IR_ap_1.
 apply H.
Qed.

Definition CRasCField : CField :=
Build_CField CRasCRing CRinvT CRisCField CRinv_strext.

Canonical Structure CRasCField.
