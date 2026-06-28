# austraits-api-nectar — agent & contributor guide

Infrastructure-as-code for automated deployment of
[`traitecoevo/austraits-api`](https://github.com/traitecoevo/austraits-api) to the Nectar research
cloud, using OpenStack Heat templates and cloud-init.

## Repo-local guidance

This is a **deployment/infra config repo**, not an R or Python package — there's no
`DESCRIPTION`/build step. It's a set of OpenStack Heat templates plus cloud-init/userdata scripts.

- **Entry point / main template:** `base.yaml` — deploys a full API stack (autoscaling group of API
  instances behind a load balancer, DNS, and a Logstash instance).
- **Templates:** `server.yaml` (a single API instance, called per-instance by the ASG),
  `network.yaml` (network config), `test-instance.yaml` (a standalone API instance with a public IP
  and no load balancer, for testing/SSH access).
- **Instance setup:** `cloud-init.yaml` and `userdata.sh` — `userdata.sh` is where data is fetched
  (from Swift object storage), API code is copied, and the API is started. Deploy flow:
  `base.yaml` → ASG → `server.yaml` (per instance) → `cloud-init.yaml` → `userdata.sh`.
- **Logging / gateway:** `logstash/` and `filebeat.yml` (log shipping), `nginx.conf` (API gateway).
- **Utilities:** `utils/`.

How to deploy (per README): with OpenStack credentials sourced and
`python-openstackclient`/`python-heatclient` installed, run e.g.
`openstack stack create YOUR_STACK_NAME -t base.yaml --parameter="image=..." ...`. Override defaults
via `--parameter` (e.g. `instance_count`, `api_branch`, `class_c`). Validate a template with
`openstack stack validate -t base.yaml ...`; add `--debug` for verbose output. Default branch is
`master`.

> Heads-up: the `image`/`logstash_image` parameters expect images built by
> [`austraits-api-nectar-imagebuilder`](https://github.com/traitecoevo/austraits-api-nectar-imagebuilder);
> the deployed API source comes from `austraits-api` (selectable via the `api_branch` parameter).

---

## AusTraits family — cross-package context

`austraits-api-nectar` is part of the **AusTraits family** (a subset of the
[`traitecoevo`](https://github.com/traitecoevo) org) — here, deployment of the AusTraits API on the
Nectar research cloud. Family-wide concerns are documented centrally in
**[austraits-meta](https://github.com/traitecoevo/austraits-meta)** — don't restate them here, read
them there:

- **Start with [`AGENTS.md`](https://github.com/traitecoevo/austraits-meta/blob/main/AGENTS.md)** —
  pipeline order, who owns what, dependency direction, source-of-truth rules, cross-boundary
  artifacts, gotchas.
- **[`dependencies.yml`](https://github.com/traitecoevo/austraits-meta/blob/main/dependencies.yml)** —
  machine-readable package graph + cross-boundary artifacts.
- **[`governance/`](https://github.com/traitecoevo/austraits-meta/tree/main/governance)** —
  label taxonomy, board #9 conventions, release playbooks, triage.

**Filing issues:** the whole family is tracked on one board,
[AusTraits #9](https://github.com/orgs/traitecoevo/projects/9) (new issues auto-add to it). Follow
the [issue & labelling guide](https://github.com/traitecoevo/austraits-meta/blob/main/governance/issue-guide.md):
pick one work-type label (`bug` / `task` / `epic`); Status and Priority are set on the board, not as
labels.

> austraits-meta is hand-maintained prose — a map, not ground truth. Verify specifics against the
> actual repos.
