#!/usr/bin/env bash
set -Eeuo pipefail

OPENSIPS_CFG="${OPENSIPS_CFG:-/etc/opensips/opensips.cfg}"
BACKUP_CFG="${OPENSIPS_CFG}.bkp"

if [[ ! -r "$BACKUP_CFG" ]]; then
  echo "[rollback-opensips-sbc] backup not found: ${BACKUP_CFG}" >&2
  exit 1
fi

install -m 0644 "$BACKUP_CFG" "$OPENSIPS_CFG"
opensips -C -f "$OPENSIPS_CFG"
systemctl restart opensips

echo "[rollback-opensips-sbc] restored ${BACKUP_CFG}"
