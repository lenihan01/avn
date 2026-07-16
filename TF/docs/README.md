# Docs

Background reading for the Terraform configuration in `../`.

## Contents

- **`multi-tenant-morpheus-hpe-terraform.md`** — a blog-style, MSP-focused
  walkthrough of how this configuration builds a multi-tenant Morpheus
  environment with the `HPE/hpe` Terraform provider. Grounded in the real
  Coke / Pepsi example in `../`, it covers provider aliases per tenant, the
  base-role permission ceiling, bootstrap admins, the `local-exec` escape
  hatch, and (in §10) the known provider bugs/limitations catalogued in
  `../bugs/README.md`.
- **`multi-tenant-morpheus-hpe-terraform.pdf`** — the rendered PDF of the above.
- **`assets/`** — everything needed to regenerate the PDF:
  - `make_diagram.py` — builds the architecture diagram (`architecture.png`)
    with matplotlib.
  - `architecture.png` — the rendered diagram embedded in the PDF.
  - `render_pdf.py` — renders the Markdown to `multi-tenant-morpheus-hpe-terraform.pdf`
    (swapping the source's ASCII diagram for `architecture.png`).

## Regenerating the PDF

```bash
python3 -m pip install markdown-pdf matplotlib   # one-time
python3 TF/docs/assets/make_diagram.py           # optional: rebuild the diagram
python3 TF/docs/assets/render_pdf.py             # rebuild the PDF
```

The Markdown source keeps a plain-text (ASCII) version of the architecture
diagram, so it stays readable on GitHub; `render_pdf.py` substitutes the image
only for the PDF.
