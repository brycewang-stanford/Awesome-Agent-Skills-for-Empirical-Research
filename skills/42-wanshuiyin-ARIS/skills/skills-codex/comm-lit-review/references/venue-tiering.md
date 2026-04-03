# Venue Tiering

Use this file to rank communications-domain literature before broadening the search.

The goal is not to claim a universal ranking. The goal is to give the skill a stable, practical search order:

1. top communications and networking venues
2. strong mainstream venues
3. the rest of the relevant formal literature

By default, these tiers are search priorities rather than strict eligibility rules. Only treat Tier A as a hard boundary if the user explicitly requests top-only search.

## Tier A: top journals and top conferences

Start here unless the user asks for a broad sweep immediately.

### Journals

- `IEEE Journal on Selected Areas in Communications (JSAC)`
- `IEEE/ACM Transactions on Networking (ToN)`
- `IEEE Transactions on Wireless Communications (TWC)`
- `IEEE Transactions on Communications (TCOM)`
- `IEEE Transactions on Mobile Computing (TMC)` when the topic is mobile or wireless systems
- `IEEE Transactions on Network and Service Management (TNSM)` when the topic is network control or management

### Conferences

- `ACM SIGCOMM`
- `USENIX NSDI`
- `ACM MobiCom`
- `ACM CoNEXT`
- `IEEE INFOCOM`

## Tier B: mainstream strong venues

Use these after Tier A, or earlier if the topic naturally lands here.

### Journals

- `IEEE Transactions on Vehicular Technology (TVT)`
- `IEEE Wireless Communications Letters (WCL)`
- `IEEE Communications Letters`
- `Computer Networks`
- `Computer Communications`
- `Ad Hoc Networks`
- `Physical Communication`

### Conferences

- `IEEE ICC`
- `IEEE GLOBECOM`
- `IEEE WCNC`
- `IEEE PIMRC`
- `ACM MobiHoc`
- topic-specific satellite, wireless, or vehicular conferences with established proceedings

## Tier C: broad relevant formal venues

Use these when the higher tiers are sparse or when the user asks for exhaustive coverage.

- other IEEE journals and transactions related to communications, networking, signal processing, and aerospace
- other Elsevier journals relevant to the topic
- other ACM conferences and workshops that are clearly on-topic
- domain-specific venues in satellite, optical, vehicular, IoT, aerial, or edge communications

## Escalation rule

Within a given topic:

- search Tier A first
- if too few relevant papers appear, expand to Tier B
- if still sparse, expand to Tier C
- only after that use broader web search for gaps, forward citations, or hard-to-find formal papers

## Topic-specific notes

### Wireless PHY/MAC

Give extra weight to:

- `TWC`
- `TCOM`
- `JSAC`
- `INFOCOM`
- `MobiCom`
- `ICC/GLOBECOM/WCNC` once the top tier is exhausted

### Networking / transport

Give extra weight to:

- `SIGCOMM`
- `NSDI`
- `CoNEXT`
- `ToN`
- `INFOCOM`
- `Computer Networks`

### Satellite / NTN

Give extra weight to:

- `JSAC`
- `TWC`
- `TCOM`
- `TVT`
- `INFOCOM`
- strong satellite or aerospace communications venues once top general venues are exhausted

### Learning for communications

If the center of gravity is still a communication system problem, keep the same venue ladder. Do not jump to generic ML venues unless the paper's actual home community is no longer communications.
