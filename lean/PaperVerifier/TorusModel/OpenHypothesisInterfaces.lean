/-
  Explicit conditional boundary for the paper.

  These structures are interfaces, not axioms: no instance is constructed in
  this project.  A downstream theorem must receive a value of `Assumptions`
  explicitly, so the four unresolved physical inputs cannot be smuggled in by
  an import or an unregistered declaration.
-/

namespace TorusModel.OpenInputs

structure WilsonPhotonInput where
  statement : Prop
  proof : statement

structure ElectroweakGapInput where
  statement : Prop
  proof : statement

structure PhysicalPoissonRPInput where
  statement : Prop
  proof : statement

structure YangMillsGapInput where
  statement : Prop
  proof : statement

structure Assumptions where
  wilsonPhoton : WilsonPhotonInput
  electroweakGap : ElectroweakGapInput
  physicalPoissonRP : PhysicalPoissonRPInput
  yangMillsGap : YangMillsGapInput

theorem unpack
    (h : Assumptions) :
    h.wilsonPhoton.statement ∧
      h.electroweakGap.statement ∧
      h.physicalPoissonRP.statement ∧
      h.yangMillsGap.statement := by
  exact ⟨h.wilsonPhoton.proof, h.electroweakGap.proof,
    h.physicalPoissonRP.proof, h.yangMillsGap.proof⟩

theorem derive_of_inputs
    {P : Prop} (h : Assumptions)
    (derive :
      h.wilsonPhoton.statement ∧
        h.electroweakGap.statement ∧
        h.physicalPoissonRP.statement ∧
        h.yangMillsGap.statement → P) :
    P := by
  exact derive (unpack h)

end TorusModel.OpenInputs
