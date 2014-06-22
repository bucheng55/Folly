module Folly.Formula(
  fvt,
  var, func,
  te, fa, pr, con, dis, neg, imp, bic, t, f,
  vars) where

import Data.Set as S
import Data.List as L

data Term =
  Var String |
  Func String [Term]
  deriving (Eq, Ord)
           
instance Show Term where
  show = showTerm
  
showTerm :: Term -> String
showTerm (Var name) = name
showTerm (Func name args) = name ++ "(" ++ (concat $ intersperse ", " $ L.map showTerm args) ++ ")"

var n = Var n
func n args = Func n args

fvt :: Term -> Set Term
fvt (Var n) = S.fromList [(Var n)]
fvt (Func name args) = S.foldl S.union S.empty (S.fromList (L.map fvt args))

data Formula =
  T                            | 
  F                            |
  P String [Term]              |
  B String Formula Formula     |
  N Formula                    |
  Q String Term Formula
  deriving (Eq, Ord)
           
instance Show Formula where
  show = showFormula
  
showFormula :: Formula -> String
showFormula T = "True"
showFormula F = "False"
showFormula (P predName args) = predName ++ "(" ++ (concat $ intersperse ", " $ L.map showTerm args)  ++ ")"
showFormula (N f) = "~(" ++ show f ++ ")"
showFormula (B op f1 f2) = "(" ++ show f1 ++ " " ++ op ++ " "  ++ show f2 ++ ")"
showFormula (Q q t f) = "(" ++ q ++ " "  ++ show t ++ " . " ++ show f ++ ")"

te :: Term -> Formula -> Formula
te v@(Var _) f = Q "E" v f
te t _ = error $ "Cannot quantify over non-variable term " ++ show t

fa :: Term -> Formula -> Formula
fa v@(Var _) f = Q "V" v f
fa t _ = error $ "Cannot quantify over non-variable term " ++ show t

pr name args = P name args
con f1 f2 = B "&" f1 f2
dis f1 f2 = B "|" f1 f2
imp f1 f2 = B "->" f1 f2
bic f1 f2 = B "<->" f1 f2
neg f = N f
t = T
f = F

vars :: Formula -> Set Term
vars T = S.empty
vars F = S.empty
vars (P name terms) = S.fold S.union S.empty $ S.fromList (L.map fvt terms)
vars (B _ f1 f2) = S.union (vars f1) (vars f2)
vars (N f) = vars f
vars (Q _ v f) = S.insert v (vars f)