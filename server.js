const fs = require('fs/promises');
const http = require('http');
const path = require('path');
const zlib = require('zlib');
const { createReviewDocxBuffer, createFindingsWorkbookBuffer } = require('./docxHelper');

const PORT = process.env.PORT || 3000;
const PLAYBOOK_DIR = process.env.PLAYBOOK_DIR || path.join(__dirname, 'playbooks');
const MAX_UPLOAD_MB = Number(process.env.MAX_UPLOAD_MB || 25);
const MODEL = process.env.ANTHROPIC_MODEL || 'claude-3-5-sonnet-latest';

function safeSlug(value) {
  return String(value || '').toLowerCase().replace(/\.[^.]+$/, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'default';
}

async function loadPlaybooks() {
  await fs.mkdir(PLAYBOOK_DIR, { recursive: true });
  const entries = await fs.readdir(PLAYBOOK_DIR, { withFileTypes: true });
  const playbooks = await Promise.all(entries
    .filter((entry) => entry.isFile() && /\.(md|txt)$/i.test(entry.name))
    .map(async (entry) => ({ id: safeSlug(entry.name), name: entry.name.replace(/\.(md|txt)$/i, ''), fileName: entry.name, content: await fs.readFile(path.join(PLAYBOOK_DIR, entry.name), 'utf8') })));
  return playbooks.length ? playbooks.sort((a, b) => a.name.localeCompare(b.name)) : [{ id: 'default', name: 'Default', fileName: 'default.md', content: 'Review for legal, drafting, and negotiation risk.' }];
}

async function getPlaybook(playbookId) {
  const playbooks = await loadPlaybooks();
  return playbooks.find((playbook) => playbook.id === playbookId) || playbooks[0];
}

function readZipEntries(buffer) {
  const entries = new Map();
  let offset = 0;
  while (offset + 30 < buffer.length && buffer.readUInt32LE(offset) === 0x04034b50) {
    const method = buffer.readUInt16LE(offset + 8);
    const compressedSize = buffer.readUInt32LE(offset + 18);
    const fileNameLength = buffer.readUInt16LE(offset + 26);
    const extraLength = buffer.readUInt16LE(offset + 28);
    const nameStart = offset + 30;
    const dataStart = nameStart + fileNameLength + extraLength;
    const name = buffer.subarray(nameStart, nameStart + fileNameLength).toString();
    const compressed = buffer.subarray(dataStart, dataStart + compressedSize);
    const data = method === 8 ? zlib.inflateRawSync(compressed) : compressed;
    entries.set(name, data);
    offset = dataStart + compressedSize;
  }
  return entries;
}

function xmlToText(xml) {
  return String(xml || '').replace(/<[^>]+>/g, ' ').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&').replace(/&quot;/g, '"').replace(/&apos;/g, "'").replace(/\s+/g, ' ').trim();
}

async function extractTextFromUpload(file) {
  if (!file) return '';
  const ext = path.extname(file.fileName || '').toLowerCase();
  if (ext === '.docx') {
    const entries = readZipEntries(file.buffer);
    return xmlToText(entries.get('word/document.xml')?.toString('utf8') || '');
  }
  if (ext === '.xlsx') {
    const entries = readZipEntries(file.buffer);
    return [...entries.entries()].filter(([name]) => /^xl\/worksheets\/sheet\d+\.xml$/.test(name)).map(([name, data]) => `# ${name}\n${xmlToText(data.toString('utf8'))}`).join('\n\n');
  }
  return file.buffer.toString('utf8');
}

function stripCodeFence(value) {
  return String(value || '').replace(/^```(?:json)?\s*/i, '').replace(/```\s*$/i, '').trim();
}

function parseReviewJson(content) {
  const cleaned = stripCodeFence(content);
  try { return JSON.parse(cleaned); } catch (error) {
    const match = cleaned.match(/\{[\s\S]*\}/);
    if (match) return JSON.parse(match[0]);
    throw error;
  }
}

function buildSystemPrompt(playbook) {
  return `You are a senior bilingual legal contract reviewer. Use the review playbook below. Return only valid JSON and no Markdown.\n\nPLAYBOOK:\n${playbook.content}\n\nJSON schema:\n{"summary":"short executive summary","findings":[{"id":"F-001","severity":"High|Medium|Low|Note","title":"issue title","clause":"clause name or location","risk":"why this matters","recommendation":"what to do","proposedText":"optional replacement wording"}]}`;
}

async function callClaude({ text, playbook, instructions }) {
  if (!process.env.ANTHROPIC_API_KEY) return demoReview(text, playbook, instructions);
  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'x-api-key': process.env.ANTHROPIC_API_KEY, 'anthropic-version': '2023-06-01' },
    body: JSON.stringify({ model: MODEL, max_tokens: 4096, temperature: 0.2, system: buildSystemPrompt(playbook), messages: [{ role: 'user', content: `Additional user instructions:\n${instructions || 'None'}\n\nDocument text:\n${text.slice(0, 90000)}` }] }),
  });
  const data = await response.json();
  if (!response.ok) throw new Error(data.error?.message || `Claude API error: ${response.status}`);
  return parseReviewJson((data.content || []).filter((part) => part.type === 'text').map((part) => part.text).join('\n'));
}

function demoReview(text, playbook, instructions) {
  const lower = text.toLowerCase();
  const findings = [];
  if (lower.includes('indemn')) findings.push({ id: 'F-001', severity: 'High', title: 'Indemnity may be broad or one-sided', clause: 'Indemnity', risk: 'The indemnity language should be checked for uncapped third-party and first-party losses, defense control, and exclusions.', recommendation: 'Limit indemnity to third-party claims caused by breach, negligence, willful misconduct, or IP infringement, and align it with the liability cap.', proposedText: 'Each party will indemnify the other only for third-party claims arising from its breach, gross negligence, willful misconduct, or infringement, subject to the limitations of liability in this agreement.' });
  if (lower.includes('terminate') || lower.includes('termination')) findings.push({ id: `F-${String(findings.length + 1).padStart(3, '0')}`, severity: 'Medium', title: 'Termination mechanics need operational detail', clause: 'Termination', risk: 'Termination rights can be difficult to enforce if notice, cure periods, survival, and wind-down obligations are unclear.', recommendation: 'Confirm notice method, cure period, effect of termination, payment obligations, and survival provisions.', proposedText: 'Either party may terminate for material breach if the breach is not cured within 30 days after written notice, and accrued payment, confidentiality, IP, liability, and dispute provisions will survive termination.' });
  if (!findings.length) findings.push({ id: 'F-001', severity: 'Note', title: 'General legal review recommended', clause: 'Entire document', risk: 'No keyword-triggered issues were found in demo mode, but the document should still be reviewed against the selected playbook.', recommendation: 'Add an Anthropic API key for a full Claude-powered review, or manually inspect key commercial and legal terms.', proposedText: '' });
  return { summary: `Demo review generated without ANTHROPIC_API_KEY. Selected playbook: ${playbook.name}. ${instructions ? `User focus: ${instructions}` : 'The report highlights likely drafting and negotiation points.'}`, findings };
}

function collectBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > MAX_UPLOAD_MB * 1024 * 1024) reject(new Error('Request body is too large.'));
      chunks.push(chunk);
    });
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

function parseMultipart(buffer, contentType) {
  const boundary = contentType.match(/boundary=(?:(?:"([^"]+)")|([^;]+))/i)?.[1] || contentType.match(/boundary=(?:(?:"([^"]+)")|([^;]+))/i)?.[2];
  if (!boundary) return { fields: {}, file: null };
  const body = buffer.toString('binary');
  const parts = body.split(`--${boundary}`).slice(1, -1);
  const fields = {};
  let file = null;
  for (const part of parts) {
    const clean = part.replace(/^\r\n/, '').replace(/\r\n$/, '');
    const headerEnd = clean.indexOf('\r\n\r\n');
    if (headerEnd < 0) continue;
    const headers = clean.slice(0, headerEnd);
    const content = Buffer.from(clean.slice(headerEnd + 4), 'binary');
    const name = headers.match(/name="([^"]+)"/)?.[1];
    const fileName = headers.match(/filename="([^"]*)"/)?.[1];
    if (fileName) file = { fieldName: name, fileName, buffer: content };
    else if (name) fields[name] = content.toString('utf8');
  }
  return { fields, file };
}

function sendJson(res, status, data) {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(data));
}

async function sendStatic(req, res) {
  const requested = decodeURIComponent(new URL(req.url, `http://${req.headers.host}`).pathname);
  const relative = requested === '/' ? 'index.html' : requested.replace(/^\/+/, '');
  const filePath = path.normalize(path.join(__dirname, 'public', relative));
  if (!filePath.startsWith(path.join(__dirname, 'public'))) return sendJson(res, 403, { error: 'Forbidden' });
  try {
    const data = await fs.readFile(filePath);
    const ext = path.extname(filePath);
    const type = ext === '.html' ? 'text/html; charset=utf-8' : ext === '.js' ? 'text/javascript' : ext === '.css' ? 'text/css' : 'application/octet-stream';
    res.writeHead(200, { 'content-type': type });
    res.end(data);
  } catch { sendJson(res, 404, { error: 'Not found' }); }
}

async function router(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);
  if (req.method === 'GET' && url.pathname === '/api/health') return sendJson(res, 200, { ok: true, model: MODEL, hasApiKey: Boolean(process.env.ANTHROPIC_API_KEY) });
  if (req.method === 'GET' && url.pathname === '/api/playbooks') {
    const playbooks = await loadPlaybooks();
    return sendJson(res, 200, { playbooks: playbooks.map(({ id, name, fileName }) => ({ id, name, fileName })) });
  }
  if (req.method === 'POST' && url.pathname === '/api/review') {
    const body = await collectBody(req);
    const { fields, file } = parseMultipart(body, req.headers['content-type'] || '');
    const documentText = fields.text || await extractTextFromUpload(file);
    if (!documentText.trim()) return sendJson(res, 400, { error: 'Please upload a document or paste text to review.' });
    const playbook = await getPlaybook(fields.playbookId);
    const review = await callClaude({ text: documentText, playbook, instructions: fields.instructions || '' });
    return sendJson(res, 200, { ...review, fileName: file?.fileName || 'pasted-text.txt', playbookName: playbook.name, originalText: documentText });
  }
  if (req.method === 'POST' && (url.pathname === '/api/export/docx' || url.pathname === '/api/export/xlsx')) {
    const payload = JSON.parse((await collectBody(req)).toString('utf8') || '{}');
    const review = payload.review || payload;
    const isDocx = url.pathname.endsWith('/docx');
    const buffer = isDocx ? await createReviewDocxBuffer(review, payload.options || {}) : createFindingsWorkbookBuffer(review, payload.options || {});
    res.writeHead(200, { 'content-type': isDocx ? 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'content-disposition': `attachment; filename="${isDocx ? 'legal-review-report.docx' : 'legal-review-findings.xlsx'}"` });
    return res.end(buffer);
  }
  if (req.method === 'GET') return sendStatic(req, res);
  return sendJson(res, 404, { error: 'Not found' });
}

const app = (req, res) => router(req, res).catch((error) => { console.error(error); sendJson(res, error.status || 500, { error: error.message || 'Unexpected server error' }); });

if (require.main === module) http.createServer(app).listen(PORT, () => console.log(`Legal Review Assistant running at http://localhost:${PORT}`));

module.exports = { app, loadPlaybooks, extractTextFromUpload, parseReviewJson, demoReview, readZipEntries };
