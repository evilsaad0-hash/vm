import os

c = get_config()  # noqa: F821

# Require a secret token supplied through the hosting provider's environment.
token = os.environ.get("JUPYTER_TOKEN", "").strip()
if not token:
    raise RuntimeError("JUPYTER_TOKEN is required. Set a strong secret in Render environment variables.")

c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = int(os.environ.get("PORT", "10000"))
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
c.ServerApp.root_dir = "/home/jovyan/work"
c.ServerApp.token = token
c.ServerApp.password = ""
c.ServerApp.allow_origin = ""
c.ServerApp.terminals_enabled = True
c.ServerApp.jpserver_extensions = {"jupyterlab": True}
c.ServerApp.quit_button = False
c.LabApp.app_name = "EVILSAAD JUPYTER"
