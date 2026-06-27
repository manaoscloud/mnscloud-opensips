# MNSCloud OpenSIPS SBC

Public standalone OpenSIPS SBC connector for MNSCloud.

This repository installs and configures local OpenSIPS runtime assets that consume the MNSCloud API
contract. It can run on MNSCloud, customer, or partner infrastructure.

## Boundary

- This repository is public and auditable by design.
- It must remain standalone and must not depend on the private MNSCloud monorepo at runtime.
- The MNSCloud API is the source of truth for authorization, tenant scope, routing ownership, billing,
  policy, and secret resolution.
- Do not commit secrets, customer data, production infrastructure values, provider credentials, or
  private business rules.

## Contract

- Product/runtime: `mnscloud-opensips-sbc`
- Project directory: `/opt/mnscloud/mnscloud-opensips-sbc`
- Installer: `scripts/install-opensips-sbc.sh`
- Shared package installer: `mnscloud-runtime-kit`
- Service: `opensips.service`
- Local state prefix: `/etc/mnscloud/sbc`
- Node UUID: `/etc/mnscloud/sbc/node.uuid`
- API token: `/etc/mnscloud/sbc/api.token`
- API base URL: `/etc/mnscloud/sbc/api.base`
- OpenSIPS config: `/etc/opensips/opensips.cfg`
- Config validation: `opensips -C -f /etc/opensips/opensips.cfg`

## Install

Install GitHub CLI if needed:
[cli/cli installation](https://github.com/cli/cli#installation).

Authenticate GitHub CLI:

```bash
gh auth login
```

Clone the private repository and install:

```bash
sudo install -d -m 0755 /opt/mnscloud
cd /opt/mnscloud
gh repo clone manaoscloud/mnscloud-opensips-sbc
cd /opt/mnscloud/mnscloud-opensips-sbc
sudo bash scripts/install-opensips-sbc.sh
```

See `opensips.md` and `SECURITY.md` for details.
