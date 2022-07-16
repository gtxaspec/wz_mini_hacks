Wireguard support is available as a kernel module:

ENABLE_WIREGUARD="true"
Use the command wg to setup. See https://www.wireguard.com/quickstart/ for more info.

Some users have asked about tailscale support, I have tested and it works. See the issue #30 for further information.

Example setup:

ENABLE_WIREGUARD="true"
WIREGUARD_IPV4="192.168.2.101/32"
WIREGUARD_PEER_ENDPOINT="x.x.x.x:51820"
WIREGUARD_PEER_PUBLIC_KEY="INSERT_PEER_PUBLIC_KEY_HERE"
WIREGUARD_PEER_ALLOWED_IPS="192.168.2.0/24"
WIREGUARD_PEER_KEEP_ALIVE="25"
To retrieve the public key that you'll need to add the peer to your wireguard endpoint:

Use SSH to log in
wg
