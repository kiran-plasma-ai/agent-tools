# Kitty remote-control gate: background launch of the dispatcher only, with
# a registered env and a [a-z0-9-] key. Registry = ~/.config/omp-debug/envs/.
# Runs inside kitty as the desktop user; paths resolve from its $HOME.
import os, re

HOME = os.path.expanduser("~")
DISPATCH = os.path.join(HOME, ".bin", "omp-debug-dispatch")
ENVS = os.path.join(HOME, ".config", "omp-debug", "envs")
NAME = re.compile(r"[a-z0-9-]+")

def is_cmd_allowed(pcmd, window, from_socket, extra_data):
    if pcmd.get("cmd") != "launch":
        return False
    p = pcmd.get("payload") or {}
    if set(p) - {"args", "type"} or p.get("type") != "background":
        return False
    a = p.get("args")
    if not (isinstance(a, list) and len(a) == 3 and a[0] == DISPATCH
            and isinstance(a[1], str) and NAME.fullmatch(a[1])
            and isinstance(a[2], str) and NAME.fullmatch(a[2])):
        return False
    return os.access(os.path.join(ENVS, a[1]), os.X_OK)
