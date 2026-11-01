/-
  Finite Gram core of the relational reflection-positivity proposition.

  The source-dependent measure and the entrywise-exponential factorisation are
  external inputs. Once the exponential kernel is supplied as a finite Gram
  matrix, the crossing kernel is exactly a Gram matrix after multiplying by
  the reflection amplitudes, hence is positive semidefinite.
-/
import Mathlib.LinearAlgebra.Matrix.PosDef
import Mathlib.Algebra.Order.Star.Real
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

namespace TorusModel

def reflectionGramKernel {Index Mark : Type*} [Fintype Mark]
    (v : Index → Real) (L : Matrix Index Mark Real) : Matrix Index Index Real :=
  fun i j => v i * v j * ((L * L.transpose) i j)

theorem reflection_gram_kernel_posSemidef
    {Index Mark : Type*} [Fintype Index] [Fintype Mark]
    [DecidableEq Index] [DecidableEq Mark]
    (v : Index → Real) (L : Matrix Index Mark Real) :
    (reflectionGramKernel v L).PosSemidef := by
  let A : Matrix Index Mark Real := Matrix.diagonal v * L
  have hI : (1 : Matrix Mark Mark Real).PosSemidef := Matrix.PosSemidef.one
  have hA := hI.mul_mul_conjTranspose_same A
  have hEq : reflectionGramKernel v L =
      A * (1 : Matrix Mark Mark Real) * A.transpose := by
    ext i j
    simp [reflectionGramKernel, A, Matrix.mul_apply, Matrix.transpose_apply,
      Matrix.diagonal_apply, Finset.mul_sum, Finset.sum_mul, mul_assoc,
      mul_left_comm, mul_comm]
  rw [hEq]
  simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using hA

/- A finite rotor phase kernel is itself a Gram kernel. This is the finite
   marked-rotor factor used by the Kallen--Lehmann reflection-positivity
   argument; it does not assert the Poisson law, spectral representation, or
   any infinite-volume limit. -/
noncomputable def rotorGramKernel {Index : Type*} [Fintype Index]
    (theta : Index → Real) : Matrix Index Index Real :=
  fun i j => Real.cos (theta i - theta j)

theorem rotor_gram_kernel_posSemidef
    {Index : Type*} [Fintype Index] [DecidableEq Index]
    (theta : Index → Real) :
    (rotorGramKernel theta).PosSemidef := by
  let U : Matrix Index (Fin 2) Real :=
    fun i k => if k = 0 then Real.cos (theta i) else Real.sin (theta i)
  have hI : (1 : Matrix (Fin 2) (Fin 2) Real).PosSemidef := Matrix.PosSemidef.one
  have hU := hI.mul_mul_conjTranspose_same U
  have hEq : rotorGramKernel theta = U * U.transpose := by
    ext i j
    simp [rotorGramKernel, U, Matrix.mul_apply, Matrix.transpose_apply,
      Fin.sum_univ_two, Real.cos_sub]
  rw [hEq]
  simpa only [Matrix.one_mul, Matrix.mul_one,
    Matrix.conjTranspose_eq_transpose_of_trivial] using hU

/- The entrywise product of two finite Gram kernels is a Gram kernel over the
   product index. This is the finite Schur--Gram core used when a crossing
   kernel factors into independent finite blocks. -/
def hadamardGramKernel
    {Index Left Right : Type*} [Fintype Left] [Fintype Right]
    (U : Matrix Index Left Real) (V : Matrix Index Right Real) :
    Matrix Index Index Real :=
  fun i j => (U * U.transpose) i j * (V * V.transpose) i j

theorem hadamard_gram_kernel_posSemidef
    {Index Left Right : Type*} [Fintype Index] [Fintype Left] [Fintype Right]
    [DecidableEq Index] [DecidableEq Left] [DecidableEq Right]
    (U : Matrix Index Left Real) (V : Matrix Index Right Real) :
    (hadamardGramKernel U V).PosSemidef := by
  let W : Matrix Index (Left × Right) Real :=
    fun i p => U i p.1 * V i p.2
  have hI : (1 : Matrix (Left × Right) (Left × Right) Real).PosSemidef :=
    Matrix.PosSemidef.one
  have hW := hI.mul_mul_conjTranspose_same W
  have hEq : hadamardGramKernel U V = W * W.transpose := by
    ext i j
    change (∑ left, U i left * U j left) *
        (∑ right, V i right * V j right) =
      ∑ p : Left × Right,
        (U i p.1 * V i p.2) * (U j p.1 * V j p.2)
    have hsum (f : Left → Real) (g : Right → Real) :
        (∑ left, f left) * (∑ right, g right) =
          ∑ p : Left × Right, f p.1 * g p.2 := by
      calc
        (∑ left, f left) * (∑ right, g right) =
            ∑ left, f left * (∑ right, g right) := by
              rw [Finset.sum_mul]
        _ = ∑ left, ∑ right, f left * g right := by
              simp_rw [Finset.mul_sum]
        _ = ∑ p : Left × Right, f p.1 * g p.2 := by
              symm
              exact Fintype.sum_prod_type
                (fun p : Left × Right => f p.1 * g p.2)
    simpa [mul_assoc, mul_left_comm, mul_comm] using
      hsum (fun left => U i left * U j left)
        (fun right => V i right * V j right)
  rw [hEq]
  simpa only [Matrix.one_mul, Matrix.mul_one,
    Matrix.conjTranspose_eq_transpose_of_trivial] using hW

end TorusModel
