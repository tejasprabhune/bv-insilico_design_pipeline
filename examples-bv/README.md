# bv smoke test fixtures

Minimal pre-stripped copies of `examples/` for verifying the bv migration
without running ESMFold/ProteinMPNN.

## What's here

- `unconditional/` — copy of `examples/unconditional/` with diversity and
  novelty columns removed from `info.csv`, plus a duplicated `example_clone.pdb`
  in `designs/` so the diversity pipeline has a real pair to compare. The
  remaining columns are exactly what the standard pipeline produces.

## Quick check (CPU, no models, ~1 minute)

```sh
bv exec python pipeline/diversity/evaluate.py --rootdir examples-bv/unconditional --num_cpus 2
```

If this finishes without error and `examples-bv/unconditional/info.csv` gains
`single_cluster_idx`, `complete_cluster_idx`, and `average_cluster_idx` columns,
the bv-managed TMalign is wired up correctly end-to-end.

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
