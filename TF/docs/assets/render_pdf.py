#!/usr/bin/env python3
"""Render the multi-tenant Morpheus blog (Markdown) to PDF.

For the PDF only, the ASCII architecture diagram in the Markdown source is
replaced with a rendered image (``architecture.png``, produced by
``make_diagram.py``). A page break before that section gives PyMuPDF's Story
renderer a full page height, so the image is placed at full content width
instead of being shrunk to fit the remaining space.

Requirements: ``markdown-pdf`` (pulls in markdown-it-py + PyMuPDF). Install with::

    python3 -m pip install markdown-pdf

Usage (from anywhere)::

    python3 TF/docs/assets/render_pdf.py

Paths are resolved relative to this file, so the script is location-independent.
"""
import os
import re

from markdown_pdf import MarkdownPdf, Section

HERE = os.path.dirname(os.path.abspath(__file__))
DOCS = os.path.dirname(HERE)

SRC = os.path.join(DOCS, "multi-tenant-morpheus-hpe-terraform.md")
OUT = os.path.join(DOCS, "multi-tenant-morpheus-hpe-terraform.pdf")
IMG = "architecture.png"  # resolved against `root=HERE` below

md = open(SRC, encoding="utf-8").read()

# Swap the ASCII-art architecture diagram (first fenced block after the header)
# for the rendered image. The .md source keeps its ASCII fallback unchanged.
pattern = r"(## Architecture at a glance\s*\n+)```.*?\n.*?```"
repl = (r'<div style="page-break-before: always"></div>\n\n\1'
        r"![Multi-tenant Morpheus architecture](" + IMG + ")")
md, n = re.subn(pattern, repl, md, count=1, flags=re.S)
assert n == 1, f"diagram substitution failed (n={n})"

css = """
h1 { font-size: 22px; border-bottom: 2px solid #444; padding-bottom: 4px; }
h2 { font-size: 16px; color: #23324d; margin-top: 18px; border-bottom: 1px solid #ccc; padding-bottom: 2px; }
h3 { font-size: 13px; color: #23324d; }
a { color: #1a5fb4; }
code { font-family: Menlo, Monaco, monospace; font-size: 9.5px; }
pre { border-left: 3px solid #b8c4d6; padding-left: 10px; }
pre code { font-size: 9px; }
blockquote { border-left: 3px solid #b8c4d6; padding-left: 10px; color: #555; }
th, td { border: 1px solid #ccc; padding: 3px; font-size: 8.5px; text-align: left; }
td code, th code { font-size: 7.8px; }
th { background: #eef1f6; }
"""

pdf = MarkdownPdf(toc_level=2, optimize=True)
pdf.add_section(Section(md, toc=False, root=HERE), user_css=css)
pdf.meta["title"] = "Building Multi-Tenant Morpheus Environments with the HPE Terraform Provider (MSP)"
pdf.meta["author"] = "John Lenihan"
pdf.save(OUT)

import fitz  # noqa: E402

print(f"wrote {OUT} ({fitz.open(OUT).page_count} pages)")
