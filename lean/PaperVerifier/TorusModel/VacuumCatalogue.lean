/-
  Explicit finite-certificate core for the vacuum catalogue.

  The source's winding scan and its machine-readable rows are data, not
  axioms.  The certificate below exposes the exact completeness and cardinality
  obligations.  Lean then proves the stated 76/16/52 conclusions from those
  obligations; no catalogue row is silently fabricated by this theorem.
-/
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Image

namespace TorusModel

structure VacuumCatalogueCertificate (V O : Type*)
    [DecidableEq V] [DecidableEq O] where
  admissible : V -> Prop
  admissible_decidable : DecidablePred admissible
  catalogue : Finset V
  complete : forall v, Iff (admissible v) (Membership.mem catalogue v)
  output : V -> O
  catalogue_card : catalogue.card = 76
  output_card : (catalogue.image output).card = 16
  rank2211 : Finset V
  rank2211_subset : rank2211 ⊆ catalogue
  rank2211_card : rank2211.card = 52

theorem vacua
    {V O : Type*} [DecidableEq V] [DecidableEq O]
    (c : VacuumCatalogueCertificate V O) :
    And (forall v, Iff (c.admissible v) (Membership.mem c.catalogue v))
      (And (c.catalogue.card = 76)
        (And ((c.catalogue.image c.output).card = 16)
          (c.rank2211.card = 52))) := by
  exact And.intro c.complete
    (And.intro c.catalogue_card (And.intro c.output_card c.rank2211_card))

end TorusModel
