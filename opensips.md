# OpenSIPS SBC

Este diretório documenta o uso do OpenSIPS como SBC do mnscloud.

## Modelo

- SBC é separado de Softswitch.
- O servidor físico mantém a URL base da API em `/etc/mnscloud/sbc/api.base`.
- O servidor físico mantém UUID local em `/etc/mnscloud/sbc/node.uuid`.
- O servidor físico mantém token local em `/etc/mnscloud/sbc/api.token`.
- Esse UUID é vinculado ao cadastro `VoipSbcServer.VbsNodeUUID`.
- O hash do token é salvo em `VoipSbcServer.VbsApiTokenHash`.
- Cada requisição runtime enviada ao mnscloud usa `node_uuid` e `Authorization: Bearer <token>` para validar o servidor.

## Cadastros

- `VoipSbcProvider`: plataformas/providers SBC.
- `VoipSbcServer`: servidores OpenSIPS/Kamailio/SBC autorizados.
- `VoipSbcTrunk`: trunks de operadoras.
- `VoipSbcRoute`: rotas por prefixo/trunk/prioridade.
- `VoipSbcPolicy`: políticas ACL, rate, codec, NAT, header e routing.

## Endpoints Runtime

- `POST /api/v1/sbc/opensips/heartbeat`
- `POST /api/v1/sbc/opensips/bootstrap`
- `POST /api/v1/sbc/opensips/auth`
- `POST /api/v1/sbc/opensips/route`
- `POST /api/v1/sbc/opensips/accounting`

O `node_uuid` pode ir via query string ou header `X-SBC-Node-UUID`. O token é gerado
pelo instalador, enviado como `Authorization: Bearer <token>` no bootstrap e nas
consultas runtime, e somente o hash fica salvo no banco.

## Instalação

```bash
bash scripts/install-opensips.sh
```

O instalador:

- solicita a URL base da API na primeira execução e salva em `/etc/mnscloud/sbc/api.base`;
- configura o repositório oficial OpenSIPS 3.6.x LTS antes da instalação;
  - Debian 12 Bookworm: `https://apt.opensips.org` com componente `3.6-releases` e keyring `/usr/share/keyrings/opensips.gpg`;
  - Rocky 8/9: `https://yum.opensips.org/3.6/releases/st/<major>/<arch>/`;
- instala OpenSIPS e módulos HTTP/REST/JSON;
- instala ferramentas de troubleshooting como `sngrep`, `tcpdump`, `ngrep`, `mtr`, `jq` e `curl`;
- cria ou reaproveita `/etc/mnscloud/sbc/node.uuid`;
- cria ou reaproveita `/etc/mnscloud/sbc/api.token`;
- tenta vincular o node UUID via API bootstrap usando hostname, IPv4 privado e IPv4 público descoberto;
- não executa SQL direto nem instala cliente MariaDB para vincular o node UUID;
- faz backup de `/etc/opensips/opensips.cfg` como `.bkp`;
- gera uma configuração limpa mínima para consulta HTTP ao mnscloud;
- grava o Bearer token local no `opensips.cfg` para autenticar as chamadas runtime contra a API;
- define `mpath` no `opensips.cfg` conforme a distro/arquitetura para carregar os módulos oficiais instalados em `/usr/lib/<multiarch>/opensips/modules/` ou `/usr/lib64/opensips/modules/`.
- carrega explicitamente `proto_udp.so` e `proto_tcp.so`, exigidos pelo OpenSIPS 3.6 para escutar nos sockets SIP UDP/TCP.
- usa `sl_send_reply()` do módulo `sl.so` e `rest_post()` no formato OpenSIPS 3.6 para consultar a API de roteamento.

## Troubleshooting

```bash
opensips -C -f /etc/opensips/opensips.cfg
systemctl status opensips
journalctl -u opensips -f
sngrep -d any port 5060
tcpdump -ni any udp port 5060
```

Para validar heartbeat:

```bash
NODE_UUID="$(tr -d '[:space:]' < /etc/mnscloud/sbc/node.uuid)"
API_TOKEN="$(tr -d '[:space:]' < /etc/mnscloud/sbc/api.token)"
curl -sS -X POST "https://dev1.publichost.cloud/api/v1/sbc/opensips/heartbeat?node_uuid=${NODE_UUID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  --data '{"hostname":"sbc-dev1"}'
```
