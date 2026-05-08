const test = require('node:test');
const assert = require('node:assert/strict');
const { parseReviewJson, demoReview } = require('../server');

test('parseReviewJson accepts fenced JSON', () => {
  const parsed = parseReviewJson('```json\n{"summary":"ok","findings":[]}\n```');
  assert.equal(parsed.summary, 'ok');
  assert.deepEqual(parsed.findings, []);
});

test('demoReview produces deterministic findings', () => {
  const review = demoReview('The party shall indemnify and may terminate.', { name: 'Default' }, 'Vendor friendly');
  assert.match(review.summary, /Demo review/);
  assert.equal(review.findings.length, 2);
  assert.equal(review.findings[0].severity, 'High');
});
