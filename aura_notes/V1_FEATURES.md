# AuraNotes V1 — Feature Testing Checklist

Use this document to test every feature in the current build. Mark each item as you test it.
Report any bugs, rough edges, or ideas for improvement next to the item.

---

## 1. Notes — Core CRUD

| # | Feature | How to Test | Status | Notes |
|---|---------|-------------|--------|-------|
| 1.1 | **Create a note** | Tap the `+ New Note` button in the sidebar footer | ☐ | |
| 1.2 | **Note default title** | New note should show "Untitled" as placeholder in the title field | ☐ | |
| 1.3 | **Edit title** | Tap the title area at the top of the editor and type a new name | ☐ | |
| 1.4 | **Edit body** | Tap below the title and start typing in the block editor | ☐ | |
| 1.5 | **Auto-save** | Edit a note → close the app → reopen → content should be preserved (saves every 500ms after last edit) | ☐ | |
| 1.6 | **Delete a note** | Long-press a note in the sidebar → "Delete" → confirm dialog | ☐ | |
| 1.7 | **Delete via menu** | With a note open, tap the `⋮` menu (top-right on mobile) → "Delete" | ☐ | |

---

## 2. Notes — Organization

| # | Feature | How to Test | Status | Notes |
|---|---------|-------------|--------|-------|
| 2.1 | **Pin a note** | Long-press a note → tap "Pin to top" | ☐ | |
| 2.2 | **Unpin a note** | Long-press a pinned note → tap "Unpin" | ☐ | |
| 2.3 | **Pinned sort order** | Pinned notes should appear above unpinned ones in the sidebar | ☐ | |
| 2.4 | **Pin via menu** | `⋮` menu → "Pin / Unpin" | ☐ | |
| 2.5 | **Note inside folder** | Long-press a folder → "New Note Here" → note should appear inside that folder | ☐ | |

---

## 3. Folders

| # | Feature | How to Test | Status | Notes |
|---|---------|-------------|--------|-------|
| 3.1 | **Create a root folder** | Tap the "Folder" button in the sidebar footer → enter a name → "Create" | ☐ | |
| 3.2 | **Create a subfolder** | Long-press a folder → "New Subfolder" → enter name → "Create" | ☐ | |
| 3.3 | **Expand / Collapse** | Tap a folder to toggle expand/collapse. Arrow icon should rotate. | ☐ | |
| 3.4 | **Rename a folder** | Long-press a folder → "Rename" → type new name → "Rename" | ☐ | |
| 3.5 | **Delete a folder** | Long-press a folder → "Delete" → confirm. Notes inside should move to root. | ☐ | |
| 3.6 | **Nested folders** | Create folder A → subfolder B inside A → subfolder C inside B. Tree should display correctly. | ☐ | |

---

## 4. Editor (AppFlowy Block Editor)

| # | Feature | How to Test | Status | Notes |
|---|---------|-------------|--------|-------|
| 4.1 | **Text input** | Tap the editor body and type | ☐ | |
| 4.2 | **Headings** | Select text → tap heading icon in toolbar → choose H1/H2/H3 | ☐ | |
| 4.3 | **Bold / Italic / Underline / Strikethrough** | Select text → tap the text decoration icon → toggle formatting | ☐ | |
| 4.4 | **Bulleted list** | Tap the list icon in toolbar → choose bulleted list | ☐ | |
| 4.5 | **Numbered list** | Tap the list icon in toolbar → choose numbered list | ☐ | |
| 4.6 | **Todo / Checkbox** | Tap the checkbox (todo) icon in toolbar | ☐ | |
| 4.7 | **Quote block** | Tap the quote icon in toolbar | ☐ | |
| 4.8 | **Code block** | Tap the code icon in toolbar | ☐ | |
| 4.9 | **Divider / Separator** | Tap the divider icon in toolbar | ☐ | |
| 4.10 | **Link** | Select text → tap link icon → enter URL | ☐ | |
| 4.11 | **Text / Background color** | Select text → tap the color icon → pick a color | ☐ | |
| 4.12 | **Toolbar visibility** | Toolbar should only appear when the editor has a selection/cursor | ☐ | |
| 4.13 | **Keyboard dismiss** | Tap the keyboard-hide icon on the right side of the toolbar | ☐ | |

---

## 5. Search

| # | Feature | How to Test | Status | Notes |
|---|---------|-------------|--------|-------|
| 5.1 | **Open search** | Tap the 🔍 icon in the sidebar header | ☐ | |
| 5.2 | **Search by title** | Type a note title in the search field → matching notes appear | ☐ | |
| 5.3 | **Search by content** | Type a word from a note's body → it should appear in results | ☐ | |
| 5.4 | **Navigate to result** | Tap a search result → should open that note in the editor | ☐ | |
| 5.5 | **Empty / no results state** | Search for gibberish → should show "No results found" | ☐ | |

---

## 6. Theme & Appearance

| # | Feature | How to Test | Status | Notes |
|---|---------|-------------|--------|-------|
| 6.1 | **Dark mode (default)** | App should launch in dark mode with OLED black background | ☐ | |
| 6.2 | **Toggle to light mode** | Tap the ☀/🌙 icon in the sidebar footer → theme should switch | ☐ | |
| 6.3 | **Theme persistence** | Switch theme → kill app → reopen → same theme should load | ☐ | |
| 6.4 | **Typography** | Text should use Inter font (Google Fonts) throughout | ☐ | |
| 6.5 | **Accent color** | Selected items, links, and accent UI should be muted indigo-violet (#6C63FF) | ☐ | |

---

## 7. Layout & Navigation

| # | Feature | How to Test | Status | Notes |
|---|---------|-------------|--------|-------|
| 7.1 | **Mobile sidebar (drawer)** | On phone: tap the ☰ hamburger menu → sidebar slides out as a drawer | ☐ | |
| 7.2 | **Tablet/desktop sidebar** | On wider screens (≥600px): sidebar is always visible, toggleable with ☰ button | ☐ | |
| 7.3 | **Sidebar toggle animation** | Sidebar slide should animate smoothly (~250ms) | ☐ | |
| 7.4 | **Note selection** | Tap a note in sidebar → it highlights and opens in editor | ☐ | |
| 7.5 | **Empty state** | With no notes: should show "Select a note or create a new one" with a "+ New Note" button | ☐ | |
| 7.6 | **Metadata line** | Below the note title, a timestamp should show (e.g. "3m ago", "2h ago") | ☐ | |

---

## 8. Data & Storage

| # | Feature | How to Test | Status | Notes |
|---|---------|-------------|--------|-------|
| 8.1 | **Local SQLite storage** | All data saved locally via sqflite (no cloud) | ☐ | |
| 8.2 | **Data survives restart** | Create notes/folders → kill app → reopen → everything intact | ☐ | |
| 8.3 | **Folder delete cascading** | Delete a folder → notes inside move to root, child folders reparent | ☐ | |

---

## 9. Known Limitations (V1)

These are **not bugs** — just things not yet built:

- No cloud sync / backup
- No export (Markdown, PDF, etc.)
- No drag-and-drop reordering of notes/folders
- No image or file attachments in notes
- No tags or labels
- No multi-note selection or bulk actions
- No undo/redo history beyond current session
- No offline-first conflict resolution (not needed yet — single device only)

---

## How to Use This Document

1. Go through each row on your phone
2. Mark ☐ → ✅ if it works, or ☐ → ❌ if broken
3. Add notes about anything that feels off (UX, speed, visual glitch, missing polish)
4. Send me back the list and we'll fix/refine everything in the next pass

**Let's make this something you're proud to show people.** 🚀
