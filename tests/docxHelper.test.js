const test = require('node:test');
const assert = require('node:assert/strict');
const { normalizeFindings, createReviewDocxBuffer, createFindingsWorkbookBuffer } = require('../docxHelper');

test('normalizeFindings fills stable defaults', () => {
  const findings = normalizeFindings([{ title: 'Risk', proposed_text: 'Use clearer wording.' }]);
  assert.equal(findings[0].id, 'F-001');
  assert.equal(findings[0].severity, 'Note');
  assert.equal(findings[0].proposedText, 'Use clearer wording.');
});

test('export helpers return Office buffers', async () => {
  const review = {
    summary: 'Summary',
    findings: [{ id: 'F-001', severity: 'High', title: 'Issue', risk: 'Risk', recommendation: 'Fix' }],
  };
  const docx = await createReviewDocxBuffer(review);
  const xlsx = createFindingsWorkbookBuffer(review);
  assert.ok(Buffer.isBuffer(docx));
  assert.ok(docx.length > 1000);
  assert.ok(Buffer.isBuffer(xlsx));
  assert.ok(xlsx.length > 1000);
});
