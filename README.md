# Fusion 360 MCP Bridge

A lightweight, zero-dependency **Model Context Protocol (MCP)** server built as a native Python Add-In for **Autodesk Fusion 360**. 

It bridges AI coding assistants (**Google Antigravity**, **Claude Desktop**, **Cursor**, etc.) with Autodesk Fusion, enabling direct programmatic CAD modeling, geometric inspection, script execution, and viewport rendering.

---

## Why This Exists

* **Universal Compatibility**: Works across **any** version of Fusion 360 (native, legacy, offline, educational, or custom builds) that supports Python Add-Ins.
* **No Cloud / Licensing Lock**: Does not depend on Autodesk's proprietary C++ MCP endpoints or cloud connectivity flags.
* **Thread-Safe by Design**: Fusion's API requires calls to run on the main UI thread. This Add-In executes an embedded HTTP server in a background thread and uses Fusion's native `CustomEvent` subsystem to dispatch commands safely to the main thread without freezing or crashing the application.
* **Zero External Dependencies**: Implemented purely with Python standard libraries (`http.server`, `socketserver`, `threading`, `json`, `queue`) bundled inside Fusion's embedded Python runtime. No `pip install` required.

---

## Architecture

```
+-------------------------------------------------------------------------+
| AI Agent / MCP Client (Antigravity, Claude Desktop, Cursor)             |
| Configuration: http://127.0.0.1:9876/mcp                                |
+-----------------------------------+-------------------------------------+
                                    | JSON-RPC 2.0 (HTTP POST)
                                    v
+-------------------------------------------------------------------------+
| Autodesk Fusion 360 Process                                             |
|                                                                         |
|  [ Background Worker Thread ]                                           |
|    - Listens on 127.0.0.1:9876                                          |
|    - Handles /health (GET) and /mcp (POST)                              |
|    - Fires app.fireCustomEvent() & awaits threading.Event completion    |
|                               |                                         |
|                               v                                         |
|  [ Main UI Thread (Single-Threaded CAD Operations) ]                    |
|    - CustomEventHandler processes request                               |
|    - Executes CAD geometry modifications (adsk.core, adsk.fusion)       |
|    - Captures stdout, error traces, or viewport screenshots             |
|    - Signals background worker and returns JSON response                |
+-------------------------------------------------------------------------+
```

---

## Quick Installation

### Option 1: Automated Script (PowerShell)
From the repository root, run:
```powershell
.\install.ps1
```
This automatically copies `FusionMCPBridge.py` and `FusionMCPBridge.manifest` to your Fusion 360 Add-Ins directory:
`%APPDATA%\Autodesk\Autodesk Fusion 360\API\AddIns\FusionMCPBridge\`

### Option 2: Manual Copy
Copy the `FusionMCPBridge/` folder directly into:
```
%APPDATA%\Autodesk\Autodesk Fusion 360\API\AddIns\
```

---

## Starting the Bridge in Fusion 360

1. Launch **Autodesk Fusion 360**.
2. Press **`Shift + S`** (or go to **Utilities** $\rightarrow$ **Add-Ins**).
3. Under the **Add-Ins** tab, find **`FusionMCPBridge`**.
4. Check **"Run on Startup"** so it starts automatically with Fusion.
5. Click **Run**.
6. The bridge will start listening on `http://127.0.0.1:9876/mcp`. You can verify by opening `http://127.0.0.1:9876/health` in your browser.

---

## Client Configuration

### 1. Google Antigravity
Add the following to `~/.gemini/config/mcp_config.json`:
```json
{
  "mcpServers": {
    "fusion360_bridge": {
      "serverUrl": "http://127.0.0.1:9876/mcp"
    }
  }
}
```

### 2. Cursor
Add the server under **Cursor Settings $\rightarrow$ Tools & MCPs** or in `~/.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "fusion360_bridge": {
      "url": "http://127.0.0.1:9876/mcp"
    }
  }
}
```

### 3. Claude Desktop
Add to `%APPDATA%\Claude\claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "fusion360_bridge": {
      "url": "http://127.0.0.1:9876/mcp"
    }
  }
}
```

---

## Exposed Tools

| Tool | Description | Parameters |
| :--- | :--- | :--- |
| `execute_script` | Runs dynamic Python scripts inside the live Fusion session with full `adsk` API access. Output and errors are captured and returned. | `script` (string, required) |
| `create_primitive` | Creates parametric 3D bodies (`sphere`, `box`, `cylinder`) at specified $(x, y, z)$ coordinates. | `shape`, `radius`, `length`, `width`, `height`, `x`, `y`, `z` |
| `get_model_info` | Retrieves comprehensive model hierarchy: open document, bodies, volume, sketches, profiles, and user parameters. | *(None)* |
| `capture_screenshot` | Renders a PNG snapshot of the active graphics viewport and returns base64-encoded image data. | `width` (default 800), `height` (default 600) |
| `undo_redo` | Reverts or reapplies transactions in the active design timeline. | `action` (`undo` / `redo`) |

---

## Repository Structure

```
fusion360-mcp/
├── FusionMCPBridge/
│   ├── FusionMCPBridge.manifest   # Autodesk Add-In definition
│   ├── FusionMCPBridge.py         # HTTP JSON-RPC MCP server & dispatcher
│   └── install.ps1                # Subfolder install helper
├── install.ps1                    # One-click installation script
├── .gitignore
├── LICENSE
└── README.md
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.