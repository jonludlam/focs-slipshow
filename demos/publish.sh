#!/bin/sh
# Make the folder published at jon.ludl.am/experiments/focs/:
#
#   demos/publish.sh OUT_DIR
#
# It holds the FoCS demos from x-ocaml's focs-check branch, with a release
# build of x-ocaml, and Asai's stepper (demos/stepper; stepper_web.js isn't
# in git: see research/stepper-trial.md).  Left out on purpose:
#   - the T9 pages (a possible tick: the answers are in the page; they are
#     in the private focs-assignments repo, branch t9);
#   - test pages.
set -eu

out=$1
xo=${XOCAML:-$HOME/devel/x-ocaml-focscheck}
build=${BUILD_DIR:-$out.build}

(cd "$xo" && dune build --profile release --build-dir "$build" \
  ./src/x_ocaml.bc.js ./worker/no-effects/x_worker.bc.js)

rm -rf "$out"
mkdir -p "$out/examples/elements"
cp "$build/default/src/x_ocaml.bc.js" "$out/x-ocaml.js"
cp "$build/default/worker/no-effects/x_worker.bc.js" "$out/x-ocaml.worker.js"
cp "$xo/examples/style.css" "$out/examples/"
cp "$xo/examples/elements/stepper.js" "$out/examples/elements/"
for p in focs-demos focs-demos-solved predict examplar; do
  cp "$xo/examples/$p.html" "$out/examples/"
done
chmod u+w "$out"/*.js

# The demos' "More demos" list names pages that aren't published.
python3 -I - "$out/examples" <<'EOF'
import re, sys, os
d = sys.argv[1]
for name in ("focs-demos.html", "focs-demos-solved.html"):
    p = os.path.join(d, name)
    s = open(p).read()
    s = re.sub(r'\s*<li><a href="t9\.html">.*?</li>', '', s, flags=re.S)
    s = re.sub(r'\s*<li><a href="/test_own_worker\.html">.*?</li>', '', s, flags=re.S)
    open(p, "w").write(s)
EOF

here=$(dirname "$0")
mkdir -p "$out/stepper"
cp "$here/stepper/index.html" "$here/stepper/stepper_web.js" "$out/stepper/"

cp "$here/publish-index.html" "$out/examples/index.html"
cat > "$out/index.html" <<'EOF'
<!DOCTYPE html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=examples/">
<a href="examples/">FoCS experiments</a>
EOF
echo "made $out"
