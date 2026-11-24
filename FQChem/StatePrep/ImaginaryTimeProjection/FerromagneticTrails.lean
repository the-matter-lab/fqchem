module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
import Mathlib.Tactic

/-! # Canonical-path edge orderings for the subgraphs-world chain

Jerrum and Sinclair, Section 4. Take maximal trails, starting at an odd vertex
while one exists. After any prefix at most two currently odd vertices lie
outside the original odd set. The ordering depends only on the edge difference.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

def unitMask (v : Fin n) : Spin n := fun i => decide (i=v)
def ends (v w : Fin n) := exchange (unitMask v) (unitMask w)

private theorem sameEnds (s : Fin n) : ends s s = aligned n := by funext i; simp [ends,exchange,aligned]
private theorem joinEnds (s t r : Fin n) : exchange (ends s t) (ends t r) = ends s r := by
  funext i
  simp [ends,exchange]

private theorem otherEnd {e : Spin n} {s : Fin n} (h : e s=true)
    (pair : ∃ a b : Fin n, a ≠ b ∧ e=pairMask a b) : ∃ t, e=ends s t := by
  obtain ⟨a,b,hne,rfl⟩ := pair
  have eq (u v : Fin n) (h : u≠v) : pairMask u v = ends u v := by
    funext i
    by_cases hi : i=u <;> by_cases hj : i=v <;> simp_all [ends,exchange,unitMask,pairMask]
  simp [pairMask] at h
  rcases h with rfl|rfl
  · exact ⟨_,eq _ _ hne⟩
  · exact ⟨_,by rw [eq _ _ hne]; funext i; exact Bool.xor_comm ..⟩

theorem boundaryUnion {A B : Finset (Spin n)} (dis : Disjoint A B) :
    boundary (A ∪ B) = exchange (boundary A) (boundary B) := by
  induction A using Finset.induction_on with
  | empty => funext i; simp [boundary_empty,exchange,aligned]
  | @insert e A he ih =>
    have sep := Finset.disjoint_insert_left.mp dis
    rw [Finset.insert_union, boundary_insert (by simpa [he] using sep.1), boundary_insert he, ih sep.2]
    funext i; simp [exchange]

private theorem boundaryQuiet {D : Finset (Spin n)} (v : Fin n) (h : ∀ e∈D, e v=false) :
    boundary D v=false := by
  induction D using Finset.induction_on with
  | empty => simp [boundary_empty,aligned]
  | @insert e D he ih =>
    rw [boundary_insert he]
    change (e v ^^ boundary D v) = false
    rw [h _ (Finset.mem_insert_self _ _),ih (fun d hd => h d (Finset.mem_insert_of_mem hd))]
    rfl

private structure Trail (D : Finset (Spin n)) (s : Fin n) where
  edges : List (Spin n)
  last : Fin n
  unique : edges.Nodup
  allowed : edges.toFinset ⊆ D
  full : boundary edges.toFinset = ends s last
  prefixes : ∀ k, ∃ v, boundary (edges.take k).toFinset = ends s v
  stopped : ∀ e∈D, e last=true → e∈edges
  used : (∃ e∈D, e s=true) → edges ≠ []

private theorem maximalTrail (g : Glass n) (D : Finset (Spin n)) (hD : D ⊆ g.bonds)
    (s : Fin n) : Nonempty (Trail D s) := by
  by_cases active : ∃ e∈D, e s=true
  · obtain ⟨e,he,hs⟩ := active
    obtain ⟨t,et⟩ := otherEnd hs (g.twoSite e (hD he))
    obtain ⟨rest⟩ := maximalTrail g (D.erase e) ((Finset.erase_subset _ _).trans hD) t
    have fresh : e ∉ rest.edges := fun h => Finset.notMem_erase e D (rest.allowed (List.mem_toFinset.mpr h))
    refine ⟨⟨e::rest.edges,rest.last,List.nodup_cons.mpr ⟨fresh,rest.unique⟩,?_,?_,?_,?_,by simp⟩⟩
    · intro d hd
      simp only [List.toFinset_cons,Finset.mem_insert] at hd
      exact hd.elim (fun h => h ▸ he) (fun h => Finset.mem_of_mem_erase (rest.allowed h))
    · rw [List.toFinset_cons,boundary_insert (by simpa using fresh),rest.full]
      exact (congrArg (fun d => exchange d (ends t rest.last)) et).trans (joinEnds ..)
    · intro k
      cases k with
      | zero => exact ⟨s,by simp [boundary_empty,sameEnds]⟩
      | succ k =>
        obtain ⟨v,hv⟩ := rest.prefixes k
        refine ⟨v,?_⟩
        simp only [List.take_succ_cons,List.toFinset_cons]
        rw [boundary_insert (fun h => fresh (List.mem_of_mem_take (List.mem_toFinset.mp h))),hv,et,joinEnds]
    · intro d hd hl
      by_cases same : d=e
      · simp [same]
      · exact List.mem_cons_of_mem _ (rest.stopped d (Finset.mem_erase.mpr ⟨same,hd⟩) hl)
  · refine ⟨⟨[],s,by simp,by simp,by simp [boundary_empty,sameEnds],
      fun _ => ⟨s,by simp [boundary_empty,sameEnds]⟩,?_,fun h => (active h).elim⟩⟩
    intro e he hs; exact (active ⟨e,he,hs⟩).elim
termination_by D.card
decreasing_by exact Finset.card_erase_lt_of_mem he

def twoDefects (D P : Finset (Spin n)) : Prop :=
  ∃ S : Finset (Fin n), S.card ≤ 2 ∧ ∀ i, i ∉ S → boundary D i=false → boundary P i=false

private theorem startingVertex (g : Glass n) (D : Finset (Spin n)) (hD : D⊆g.bonds) (hn : D.Nonempty) :
    ∃ s, (∃ e∈D, e s=true) ∧ ((∃ i, boundary D i=true) → boundary D s=true) := by
  by_cases odd : ∃ i, boundary D i=true
  · obtain ⟨s,hs⟩ := odd
    refine ⟨s,?_,fun _ => hs⟩
    by_contra! none
    have h := boundaryQuiet s (fun e he => Bool.eq_false_iff.mpr (none e he))
    rw [hs] at h; contradiction
  · obtain ⟨e,he⟩ := hn
    obtain ⟨a,b,_,eq⟩ := g.twoSite e (hD he)
    exact ⟨a,⟨e,he,by simp [eq,pairMask]⟩,fun h => (odd h).elim⟩

/-- The edges of any two-site subgraph admit an ordering with no repetitions and
at most two extra odd vertices at every prefix, relative to its final boundary. -/
theorem canonicalOrdering (g : Glass n) (D : Finset (Spin n)) (hD : D⊆g.bonds) :
    ∃ order : List (Spin n), order.Nodup ∧ order.toFinset = D ∧
      ∀ k, twoDefects D (order.take k).toFinset := by
  by_cases hn : D.Nonempty
  · obtain ⟨s,active,hs⟩ := startingVertex g D hD hn
    obtain ⟨T⟩ := maximalTrail g D hD s
    let P := T.edges.toFinset
    let R := D \ P
    have split : P ∪ R = D := Finset.union_sdiff_of_subset T.allowed
    have sep : Disjoint P R := Finset.disjoint_sdiff
    have tern : boundary D = exchange (boundary P) (boundary R) := split ▸ boundaryUnion sep
    have stop : boundary R T.last=false := boundaryQuiet _ fun e he => by
      have mem := Finset.mem_sdiff.mp he
      exact Bool.eq_false_iff.mpr (fun hv => mem.2 (List.mem_toFinset.mpr (T.stopped e mem.1 hv)))
    have fin : ∀ v, boundary D v=false → boundary P v=false := by
      intro v hv
      by_cases same : s=T.last
      · simp [P,T.full,same,sameEnds,aligned]
      have lastOdd : boundary D T.last=true := by
        rw [tern]; simp [exchange,P,T.full,ends,unitMask,Ne.symm same,stop]
      have firstOdd := hs ⟨_,lastOdd⟩
      have neq : v≠s := fun h => by subst v; simp_all
      have neql : v≠T.last := fun h => by subst v; simp_all
      simp [P,T.full,ends,exchange,unitMask,neq,neql]
    have rem (v) (hv : boundary D v=false) : boundary R v=false := by
      have h := congrFun tern v
      simpa [exchange,hv,fin v hv] using h.symm
    have smaller : R ⊂ D := by
      refine Finset.ssubset_iff_subset_ne.mpr ⟨Finset.sdiff_subset,?_⟩
      intro eq
      obtain ⟨e,he⟩ := List.exists_mem_of_ne_nil _ (T.used active)
      have present := T.allowed (List.mem_toFinset.mpr he)
      exact (Finset.mem_sdiff.mp ((eq.symm ▸ present) : e∈R)).2 (List.mem_toFinset.mpr he)
    obtain ⟨tail,nd,cov,good⟩ := canonicalOrdering g R (smaller.subset.trans hD)
    refine ⟨T.edges ++ tail, List.nodup_append.mpr ⟨T.unique,nd,?_⟩,?_,?_⟩
    · intro a ha b hb eq
      subst b
      exact Finset.disjoint_left.mp sep (List.mem_toFinset.mpr ha) (cov ▸ List.mem_toFinset.mpr hb)
    · rw [List.toFinset_append,cov]; exact split
    · intro k
      by_cases pre : k ≤ T.edges.length
      · rw [List.take_append_of_le_length pre]
        obtain ⟨v,hv⟩ := T.prefixes k
        refine ⟨{s,v},(Finset.card_insert_le ..).trans (by simp),?_⟩
        intro i hi _
        simp only [Finset.mem_insert,Finset.mem_singleton,not_or] at hi
        simp [hv,ends,exchange,unitMask,hi.1,hi.2]
      · rw [List.take_append,List.take_of_length_le (by omega : T.edges.length≤k),List.toFinset_append]
        let U := (tail.take (k-T.edges.length)).toFinset
        have sub : U ⊆ R := by
          rw [← cov]
          exact fun _ h => List.mem_toFinset.mpr (List.mem_of_mem_take (List.mem_toFinset.mp h))
        obtain ⟨V,hV,vg⟩ := good (k-T.edges.length)
        refine ⟨V,hV,?_⟩
        intro i hi hd
        change boundary (P∪U) i=false
        rw [boundaryUnion (sep.mono_right sub)]
        simp [exchange,fin i hd,show boundary U i=false from vg i hi (rem i hd)]
  · have z := Finset.not_nonempty_iff_eq_empty.mp hn
    refine ⟨[],by simp,by simp [z],fun k => ⟨∅,by simp,?_⟩⟩
    simp [boundary_empty,aligned]
termination_by D.card
decreasing_by exact Finset.card_lt_card smaller

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
