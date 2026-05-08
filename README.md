# Legal Review Assistant

A single-page legal document review app backed by a Node.js server, Claude, and Word/Excel export helpers.

## Files

- `server.js` - API server, Claude calls, playbook loading, file parsing.
- `public/index.html` - all UI, prompt controls, and browser JavaScript in one file.
- `docxHelper.js` - Word and Excel export logic.

## Setup

```bash
# No npm packages are required.
export ANTHROPIC_API_KEY="your-key" # optional; demo mode works without it
npm start
```

Open <http://localhost:3000/>.

If `ANTHROPIC_API_KEY` is not set, the review endpoint returns a deterministic demo review so the UI and exports can be tested locally.

## Optional playbooks

Add Markdown or text files under `playbooks/`. The app loads them automatically and lets users select one in the UI.
