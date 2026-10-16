#!/bin/sh
# Run every exercise specification file and check that each wheat passes all
# its tests and each chaff fails at least one.
#   exercises/run.sh                 # all files under exercises/*/ex*.ml
#   exercises/run.sh lecture3-4/ex3_2.ml
# The small stack limit (l = 200000 words) makes non-tail recursion over a
# 10^6-element list overflow, which is how the [Tail] tests work natively.
cd "$(dirname "$0")" || exit 2
if [ $# -eq 0 ]; then set -- */ex*.ml; fi
status=0
for f in "$@"; do
  OCAMLRUNPARAM=l=200000 ocaml -I . -I "$(dirname "$f")" "$f" || status=1
done
[ $status -eq 0 ] && echo "ALL OK" || echo "SOME FILES HAVE PROBLEMS"
exit $status
