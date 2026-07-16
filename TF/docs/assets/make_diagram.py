import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from matplotlib.lines import Line2D

MSP   = "#23324d"   # dark navy
CUST  = "#1a5fb4"   # blue
UNIT  = "#3d6f9e"   # lighter blue
EDGE  = "#8a97ab"
TXT   = "#1b1b1b"

fig, ax = plt.subplots(figsize=(11, 8.2))
ax.set_xlim(0, 100)
ax.set_ylim(0, 100)
ax.axis("off")

def box(x, y, w, h, facecolor, title, lines, title_color="white",
        body_color="white", fontsize=10.5, title_fs=12):
    p = FancyBboxPatch((x, y), w, h,
                       boxstyle="round,pad=0.6,rounding_size=2.2",
                       linewidth=1.4, edgecolor=EDGE, facecolor=facecolor,
                       mutation_aspect=1.0, zorder=2)
    ax.add_patch(p)
    ax.text(x + w/2, y + h - 4.2, title, ha="center", va="top",
            fontsize=title_fs, fontweight="bold", color=title_color, zorder=3)
    ax.text(x + w/2, y + h - 10.5, "\n".join(lines), ha="center", va="top",
            fontsize=fontsize, color=body_color, linespacing=1.5, zorder=3)

def arrow(x1, y1, x2, y2, label=None, lx=0, ly=0, ha="center"):
    a = FancyArrowPatch((x1, y1), (x2, y2),
                        arrowstyle="-|>", mutation_scale=18,
                        linewidth=1.8, color="#4a5568", zorder=1,
                        shrinkA=0, shrinkB=0)
    ax.add_patch(a)
    if label:
        ax.text((x1+x2)/2 + lx, (y1+y2)/2 + ly, label, ha=ha, va="center",
                fontsize=9, color="#2d3748", style="italic", zorder=4,
                bbox=dict(boxstyle="round,pad=0.25", fc="white", ec="none", alpha=0.9))

# --- Master tenant (top, wide) ---
box(18, 78, 64, 20, MSP, "MASTER TENANT  (MSP control plane)",
    ['provider "hpe"  —  master admin credentials',
     'owns & governs:  tenants  •  multitenant roles',
     'base-role ceiling (the guardrail)',
     'shared clouds / library visibility'],
    fontsize=10)

# --- Subtenants: Coke (left) and Pepsi (right) ---
box(6, 40, 40, 26, CUST, "SUBTENANT: Coke  (MSP customer)",
    ['• bootstrap admin (via API)',
     '• users (tenant-local role)',
     '• group + VMware cloud',
     '• Ansible, workflow',
     '• expiration policy'], fontsize=9.5, title_fs=11)

box(54, 40, 40, 26, CUST, "SUBTENANT: Pepsi  (MSP customer)",
    ['• bootstrap admin (via API)',
     '• users (tenant-local role)',
     '• group + VMware cloud',
     '• bare-metal cloud',
     '• expiration policy'], fontsize=9.5, title_fs=11)

# --- Coke-Finance (below Coke) ---
box(6, 2, 40, 30, UNIT, "SUBTENANT: Coke-Finance",
    ['(models a business unit)',
     '• own admin, group, HVM cloud / cluster',
     '',
     'flat PEER of Coke: the v1.5.0 provider',
     "can't set a parent tenant — the platform",
     'DOES support N-tier nesting (see §1)'],
    fontsize=8.6, title_fs=11)

# --- Arrows ---
arrow(38, 78, 26, 66, "provider = hpe.coke\n(coke\\coke-admin)", lx=-11, ly=2, ha="center")
arrow(62, 78, 74, 66, "provider = hpe.pepsi\n(pepsi\\pepsi-admin)", lx=11, ly=2, ha="center")
arrow(26, 40, 26, 32, "provider = hpe.coke_finance", lx=17, ly=0, ha="left")

plt.tight_layout(pad=0.5)
fig.savefig("/tmp/architecture.png", dpi=200, bbox_inches="tight",
            facecolor="white")
print("saved /tmp/architecture.png")
