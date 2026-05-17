import assert from "node:assert/strict";
import test from "node:test";

import { normalizeLayerName } from "./cad.js";

test("normalizeLayerName trims surrounding whitespace", () => {
  assert.equal(normalizeLayerName("  Walls  "), "Walls");
});
