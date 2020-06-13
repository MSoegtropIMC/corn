(*
Copyright © 2008 Russell O’Connor

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
Require Export CoRN.reals.fast.RasterizeQ.
Require Import CoRN.reals.fast.Interval.
Require Export CoRN.metric2.Graph.
Require Import CoRN.model.totalorder.QMinMax.
Require Export CoRN.model.totalorder.QposMinMax.
Require Import CoRN.tactics.CornTac CoRN.tactics.AlgReflection.

Section Plot.
(**
* Plotting
Plotting a uniformly continuous function on a finite interval consists
of producing the graph of a function as a compact set, approximating that
graph, and finally rasterizing that approximation.

A range for the plot must be provided.  We choose to clamp the plotted
function so that it lies inside the specified range.  Thus we plot
[compose (clip b t) f] rather than [f].
*)
Variable (l r:Q).
Hypothesis Hlr : l < r.

Variable (b t:Q).
Hypothesis Hbt : b < t.

Local Open Scope uc_scope.

Let clip := uc_compose (boundBelow b) (boundAbove t).

Variable f : Q_as_MetricSpace --> CR.

Lemma plFEQ : PrelengthSpace (FinEnum stableQ).
Proof.
 apply FinEnum_prelength.
  apply locatedQ.
 apply QPrelengthSpace.
Qed.

Definition graphQ f := CompactGraph_b f stableQ2 plFEQ (CompactIntervalQ (Qlt_le_weak _ _ Hlr)).

Lemma graphQ_bonus : forall e x y,
 In (x, y) (approximate (graphQ (uc_compose clip f)) e) -> l <= x <= r /\ b <= y <= t.
Proof.
 intros [e|] x y;[|intros; contradiction].
 simpl.
 unfold Cjoin_raw.
 Opaque  CompactIntervalQ.
 simpl.
 unfold FinCompact_raw.
 rewrite map_map.
 rewrite -> in_map_iff.
 unfold graphPoint_b_raw.
 simpl.
 unfold Couple_raw.
 simpl.
 intros [z [Hz0 Hz1]].
 inversion Hz0.
 rewrite <- H0.
 clear Hz0 x y H0 H1.
 split; auto with *.
 eapply CompactIntervalQ_bonus_correct.
 apply Hz1.
Qed.

Variable n m : nat.
Hypothesis Hn : eq_nat n 0 = false.
Hypothesis Hm : eq_nat m 0 = false.

Let w := proj1_sig (Qpos_sub _ _ Hlr).
Let h := proj1_sig (Qpos_sub _ _ Hbt).

(*
Variable err : Qpos.
*)
Let err := Qpos_max ((1 # 4 * P_of_succ_nat (pred n)) * w)
 ((1 # 4 * P_of_succ_nat (pred m)) * h).

(** [PlotQ] is the function that does all the work. *)
Definition PlotQ := RasterizeQ2 (approximate (graphQ (uc_compose clip f)) err) n m t l b r.

Local Open Scope raster.

(** The resulting plot is close to the graph of [f] *)
Theorem Plot_correct :
ball (proj1_sig (err + Qpos_max ((1 # 2 * P_of_succ_nat (pred n)) * w)
        ((1 # 2 * P_of_succ_nat (pred m)) * h))%Qpos)
 (graphQ (uc_compose clip f))
 (Cunit (InterpRaster PlotQ (l,t) (r,b))).
Proof.
 assert (Hw:=(proj2_sig (Qpos_sub _ _ Hlr))).
 assert (Hh:=(proj2_sig (Qpos_sub _ _ Hbt))).
 fold w in Hw.
 fold h in Hh.
 change (r == l + proj1_sig w) in Hw.
 change (t == b + proj1_sig h) in Hh.
 apply ball_triangle with (Cunit (approximate (graphQ (uc_compose clip f)) err)).
  apply ball_approx_r.
 unfold Compact.
 rewrite -> ball_Cunit.
 apply ball_sym.
 assert (L:st_eq ((l,t):Q2) (l,b + proj1_sig h)).
  split; simpl.
   reflexivity.
  auto.
 set (Z0:=(l, t):Q2) in *.
 set (Z1:=(r, b):Q2) in *.
 set (Z:=(l, (b + proj1_sig h)):Q2) in *.
 rewrite -> L.
 setoid_replace Z1 with (l+proj1_sig w,b).
  unfold Z, PlotQ.
  (* TODO: figure out why rewrite Hw, Hh hangs *)
  replace (RasterizeQ2 (approximate (graphQ (uc_compose clip f)) err) n m t l b r)
    with (RasterizeQ2 (approximate (graphQ (uc_compose clip f)) err) n m (b + proj1_sig h) l b (l + proj1_sig w)) by now rewrite Hw, Hh.
  destruct n; try discriminate.
  destruct m; try discriminate.
  split. apply Qpos_nonneg.
  apply (RasterizeQ2_correct).
  intros.
  rewrite <- Hw.
  rewrite <- Hh.
  destruct (InStrengthen _ _ H) as [[zx xy] [Hz0 [Hz1 Hz2]]].
  simpl in Hz1, Hz2.
  rewrite -> Hz1, Hz2.
  eapply graphQ_bonus.
  apply Hz0.
 split; simpl; auto with *.
Qed.

End Plot.

(** Some nice notation for the graph of f. *)
Notation "'graphCR' f [ l '..' r ]" :=
 (graphQ l r (refl_equal _) f) (f at level 0) : raster.
