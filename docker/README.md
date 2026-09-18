<h2 align="center">Stable Diffusion WebUI Forge - Neo (Docker)</h2>

> [!Warning]
> Requires an **NVIDIA** GPU<br>
> Ensure driver is up to date (`560+` required)

<hr>

## Unraid Deployment

<table>
	<tr>
		<th>Container Path</th>
		<th>Purpose</th>
	</tr>
	<tr>
		<td>
			<code>/home/forge/sd-webui/models</code>
		</td>
		<td>Checkpoint, Text Encoder, VAE, LoRA, ControlNet</td>
	</tr>
	<tr>
		<td>
			<code>/home/forge/sd-webui/output</code>
		</td>
		<td>Generated Images</td>
	</tr>
	<tr>
		<td>
			<code>/home/forge/sd-webui/extensions</code>
		</td>
		<td>User-Installed Extensions</td>
	</tr>
	<tr>
		<td>
			<code>/home/forge/sd-webui/config</code>
		</td>
		<td>User Settings</td>
	</tr>
</table>

- The container runs as **UID 99** / **GID 100** (`nobody:users`) to match Unraid's default share permissions

<hr>

## Building Locally

```bash
git clone https://github.com/Haoming02/sd-webui-forge-classic sd-webui-forge-neo --branch neo
cd sd-webui-forge-neo/docker
docker build -t forge-neo-local .
```

<hr>

## Pre-Built Image

> a non-official pre-built image is maintained on Docker Hub by [@oromis995](https://github.com/oromis995):

```bash
docker pull oromis995/sd-forge-neo:latest
```

<hr>

## Image Details

<table>
	<tr>
		<td>Base</td>
		<td><code>nvidia/cuda:12.6.3-runtime-ubuntu22.04</code></td>
	</tr>
	<tr>
		<td>Python</td>
		<td><code>3.13</code> via <b>uv</b></td>
	</tr>
	<tr>
		<td>PyTorch</td>
		<td>Latest (<code>cu126</code>)</td>
	</tr>
	<tr>
	<td>User</td>
	<td><code>forge</code> (UID 99 / GID 100)</td>
</tr>
<tr>
	<td>Ports</td>
	<td><code>22</code> (SSH) / <code>7860</code> (WebUI)</td>
</tr>
</table>

> [!Note]
> On the first run, `prepare_environment()` will install requirements and dependencies. This may take a few minutes

<hr>

## SSH

The container starts an `sshd` that allows **root** login via **public key** only (no password). The WebUI itself still runs as the `forge` user.

Provide your public key with the `SSH_ROOT_PUBKEY` environment variable (or bind-mount a file to `/root/.ssh/authorized_keys`):

```bash
docker run -d \
    --gpus all \
    -p 2222:22 -p 7860:7860 \
    -e SSH_ROOT_PUBKEY="ssh-ed25519 AAAA... user@host" \
    ...
```

Then connect as root: `ssh -p 2222 root@<host>`
