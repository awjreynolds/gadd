# Triage Narrative

## What We Have Established

CAD layer names should normalize consistently before comparison. The current
implementation trims surrounding whitespace but preserves inconsistent casing,
which makes layer equality checks fragile.

## Approved Outcome

Route directly to `/gadd:implement CAD-0001`.

## Boundary

Change only `normalizeLayerName` and its focused test. Do not add a parser,
layer registry, file format support, or external tracker projection.
