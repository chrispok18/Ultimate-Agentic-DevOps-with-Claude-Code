# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Static HTML/CSS portfolio website deployed to AWS using S3 and CloudFront, provisioned with Terraform, and automated via GitHub Actions.
Static HTML/CSS portfolio site for Pravin Mishra (Cloud/DevOps/Data/AI consultant). Pure HTML5 + CSS3, no build step, no JavaScript file (despite `onclick="toggleMenu()"` / `onclick="goToSection(...)"` handlers in `index.html` — no `<script>` tag defines these, so the hamburger/mobile menu is currently inert; anchor links like `href="#book"` work regardless since they're plain fragment links).

The README frames this repo as a DMI (DevOps Micro Internship) Week 1 training exercise: students are expected to fork it, add an ownership-proof line to the footer (`<p>Crafted with <span>cloud</span> excellence by Pravin Mishra</p>` → append deployer name/cohort/date), and host it on an Ubuntu VM with Nginx.

Separately, `.github/workflows/deploy.yml` implements a *different*, already-wired deploy path: on push to `main` it syncs the repo to an S3 bucket and invalidates a CloudFront distribution via OIDC (no stored AWS keys). That workflow is hardcoded to the original author's AWS account/role/bucket/distribution IDs, so it will fail for any fork unless those values are replaced with the fork owner's own AWS resources.

## Commands

There is no build/lint/test tooling — this is static markup and CSS only.
- terraform init
- terraform plan
- terraform apply
- **Local preview**: open `index.html` directly in a browser, or serve the directory with any static file server.
- **Deploy (as currently wired)**: push to `main` triggers `.github/workflows/deploy.yml`, which runs `aws s3 sync` (excluding `.git`, `.github`, `*.md`) then `aws cloudfront create-invalidation`. To reuse this for a different AWS account, update the `role-to-assume`, `aws-region`, S3 bucket name, and `--distribution-id` in that workflow.

## Architecture

- **`index.html`** — single page, sections identified by id and linked from the navbar via fragment anchors: `#home` (hero), `about`, `services`, `courses`, `book`, `community` (`trust-section`), `contact`, plus a closing `footer`. Adding/removing a nav item means keeping both the `.nav-links` anchor list and the `#mobileMenu` button list in sync (they're maintained as two separate markup blocks, not generated from one source).
Pure HTML5 and CSS3. No JavaScript. No build step. No framework.
- **`style.css`** (~1145 lines) — mobile-first, with breakpoints at `900px`, `768px`, and `600px` repeated per-section (there isn't one global breakpoint block; each section defines its own `@media` overrides near its base styles).
- **`privacy.html` / `terms.html`** — standalone pages with their own inline `<style>` blocks; they do **not** load `style.css`, so styling changes to the main site do not propagate to these pages and must be edited separately.
- **`images/`** — static assets referenced by relative path (logo, hero background, profile, course thumbnails).

## Conventions
- All infrastructure changes go through Terraform — never modify AWS resources manually
- No JavaScript in this project
- CSS uses mobile-first approach with breakpoints at 900px, 768px, and 600px

## Safety
Never put secrets in this file. No API keys, passwords, or AWS credentials.
