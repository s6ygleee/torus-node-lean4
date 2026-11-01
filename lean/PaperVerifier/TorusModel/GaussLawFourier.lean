/-
  Fourier-analysis part of Lemma GL.

  The coefficient field is the lattice `Fin d -> Z`; `Summable` of the
  coefficient norm is the paper's absolute summability hypothesis.  The
  Weierstrass bound is then an exact Lean theorem: the Fourier series is
  continuous on the real torus.
-/
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.Complex.Exponential
import Mathlib.Analysis.Complex.Trigonometric
import Mathlib.Analysis.Normed.Group.FunctionSeries
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Int.Cast.Lemmas

namespace TorusModel.GL

abbrev Lattice (d : Type*) := d → ℤ
abbrev Torus (d : Type*) := d → ℝ

def phase {d : Type*} [Fintype d] (n : Lattice d) (θ : Torus d) : ℂ :=
  Complex.I * (∑ i, (n i : ℝ) * θ i)

noncomputable def fourierTerm {d : Type*} [Fintype d]
    (c : Lattice d → ℂ) (n : Lattice d) (θ : Torus d) : ℂ :=
  c n * Complex.exp (phase n θ)

noncomputable def fourier {d : Type*} [Fintype d]
    (c : Lattice d → ℂ) (θ : Torus d) : ℂ :=
  ∑' n, fourierTerm c n θ

theorem phase_exp_norm {d : Type*} [Fintype d]
    (n : Lattice d) (θ : Torus d) : ‖Complex.exp (phase n θ)‖ = 1 := by
  simpa [phase] using
    (Complex.norm_exp_I_mul_ofReal (∑ i, (n i : ℝ) * θ i))

theorem continuous_fourier {d : Type*} [Fintype d]
    (c : Lattice d → ℂ) (hc : Summable (fun n => ‖c n‖)) :
    Continuous (fourier c) := by
  apply continuous_tsum (u := fun n => ‖c n‖)
  · intro n
    have hphase : Continuous (fun θ : Torus d => phase n θ) := by
      unfold phase
      fun_prop
    exact continuous_const.mul hphase.cexp
  · exact hc
  · intro n θ
    simp [fourierTerm, phase_exp_norm]

theorem summable_fourierTerm {d : Type*} [Fintype d]
    (c : Lattice d → ℂ) (hc : Summable (fun n => ‖c n‖)) (θ : Torus d) :
    Summable (fun n => fourierTerm c n θ) := by
  apply Summable.of_norm
  simpa [fourierTerm, phase_exp_norm] using hc

end TorusModel.GL
