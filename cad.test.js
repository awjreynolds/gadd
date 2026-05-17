import assert from "node:assert/strict";
import test from "node:test";

import { normalizeLayerName } from "./cad.js";

test("normalizeLayerName trims surrounding whitespace", () => {
  assert.equal(normalizeLayerName("  Walls  "), "walls");
});

test("normalizeLayerName lowercases trimmed names for stable comparison", () => {
  assert.equal(normalizeLayerName("  WALLS  "), "walls");
});
