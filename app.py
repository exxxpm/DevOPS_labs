from flask import Flask, render_template_string
import os, socket, datetime, subprocess

app = Flask(__name__)

def get_ip():
    try:
        return subprocess.getoutput("hostname -I | awk '{print $1}'").strip()
    except Exception:
        return "unknown"

def get_branch():
    try:
        b = subprocess.check_output(["git","-C","/opt/app","rev-parse","--abbrev-ref","HEAD"]).decode().strip()
        return b or "unknown"
    except Exception:
        return os.environ.get("BRANCH","unknown")

def get_repo():
    try:
        url = subprocess.check_output(["git","-C","/opt/app","config","--get","remote.origin.url"]).decode().strip()
        return url or "N/A"
    except Exception:
        return os.environ.get("REPO_URL","N/A")

@app.route("/")
def index():
    branch = get_branch()
    hostname = socket.gethostname()
    ip = get_ip()
    last_update = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    repo_url = get_repo()

    html = """
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>DevOPS Lab Status</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
          body { background-color:#0d1117; color:#e6edf3; font-family:'Segoe UI', Roboto, sans-serif; }
          .card { background:#161b22; border:1px solid #30363d; box-shadow:0 4px 16px rgba(0,0,0,.5); }
          .status-badge { font-size:1rem; background-color:#198754; }
          a { color:#58a6ff; text-decoration:none; } a:hover{ text-decoration:underline; }
        </style>
      </head>
      <body class="d-flex align-items-center justify-content-center vh-100">
        <div class="card p-4" style="width: 650px;">
          <h3 class="text-center mb-3">🚀 DevOPS</h3>
          <div class="text-center mb-4">
            <span class="badge status-badge">✅ DEPLOYED SUCCESSFULLY</span>
          </div>
          <table class="table table-dark table-striped mb-0">
            <tbody>
              <tr><th>Server</th><td>{{hostname}} ({{ip}})</td></tr>
              <tr><th>Branch</th><td>{{branch}}</td></tr>
              <tr><th>Port</th><td>8181</td></tr>
              <tr><th>Updated</th><td>{{last_update}}</td></tr>
              <tr><th>Repository</th><td><a href="{{repo_url}}" target="_blank">{{repo_url}}</a></td></tr>
              <tr><th>Environment</th><td>Flask + Gunicorn + FRP + GitHub Webhook</td></tr>
            </tbody>
          </table>
          <div class="text-center text-secondary mt-3">
            <small>© {{year}} DevOPS Labs — Auto-Deploy Pipeline</small>
          </div>
        </div>
      </body>
    </html>
    """
    return render_template_string(
        html,
        hostname=hostname,
        ip=ip,
        branch=branch,
        last_update=last_update,
        repo_url=repo_url,
        year=datetime.datetime.now().year
    )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8181)
