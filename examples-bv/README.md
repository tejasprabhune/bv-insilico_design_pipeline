# bv smoke test fixtures

Minimal pre-stripped copies of `examples/` for verifying the bv migration
without running ESMFold/ProteinMPNN.

## What's here

- `unconditional/` — copy of `examples/unconditional/` with diversity and
  novelty columns removed from `info.csv`, plus a duplicated `example_clone.pdb`
  in `designs/` so the diversity pipeline has a real pair to compare. The
  remaining columns are exactly what the standard pipeline produces.

## Quick check (CPU, no models, ~1 minute)

Run both pipelines that exercise TMalign — `diversity` (all-pairs) and
`novelty` (design-vs-reference):

```sh
bv exec python pipeline/diversity/evaluate.py \
    --rootdir examples-bv/unconditional --num_cpus 2

bv exec python pipeline/novelty/evaluate.py \
    --rootdir examples-bv/unconditional \
    --dataset pdb \
    --datadir examples-bv/reference_pdbs \
    --num_cpus 2
```

After both finish, `examples-bv/unconditional/info.csv` should gain:

- from diversity: `single_cluster_idx`, `complete_cluster_idx`, `average_cluster_idx`
- from novelty:   `max_pdb_name`, `max_pdb_tm`

If the columns are present and populated (TM-scores between 0 and 1 inclusive),
the bv-managed TMalign is wired up correctly end-to-end via two distinct
`subprocess.call` codepaths.

## What's in the reference set

`examples-bv/reference_pdbs/` contains two trivially-small `.pdb.gz` files
(both copies of `example.pdb` to keep the fixture self-contained). For the
smoke test the actual content doesn't matter; we only verify that
TMalign-via-bv is reachable and the pandas merge round-trips.

## What this proves

- `bv exec` puts `TMalign` on `PATH` for a non-interactive subprocess.
- The pipeline's `subprocess.call('TMalign ...', shell=True)` invocations
  resolve to the bv-managed container via the standard PATH lookup.
- Shell redirection (`> output_filepath`) still captures stdout from the
  containerized binary.
- The pipeline's pandas merge / CSV output behaviour is unchanged.

## What this does *not* prove

- ProteinMPNN or ESMFold integration (they're imported as Python libraries,
  not subprocess calls — bv doesn't apply). For full end-to-end validation,
  set up the GPU stack per the main README and run the standard pipeline
  against `examples/unconditional`.
