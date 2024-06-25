<img src="https://raw.githubusercontent.com/ATSiCorp/LinkPanel/main/utility/design/banner.png">

## About LinkPanel
LinkPanel is a Laravel based super lightweight cloud server control panel that supports small VPS. It comes with nginx, Mysql, multi PHP-FPM versions, multi users, Supervisor, Composer, npm, free Let's Encrypt certificates, Git deployment, backups, ffmpeg, fail2ban, Redis, API and with a simple graphical interface useful to manage Laravel, Codeigniter, Symfony, WordPress or other PHP applications. With LinkPanel you don’t need to be a Sys Admin to deploy and manage websites and PHP applications powered by cloud VPS.

## Features
- Easy install: setup one or more servers with a click in few minutes without be a Linux expert.

- Server Management: manage one or more servers in as easy as a few clicks without be a LEMP Guru.

- Perfect stack for PHP devs: LinkPanel comes with nginx, PHP, MySql, Composer, npm and Supervisor.

- Multi-PHP: Run simultaneous PHP versions at your ease & convenience.

- Secure: no unsed open ports, unprivileged PHP, isolated system users and filesystem, only SFTP (no insecure FTP), Free SSL certificates everywhere.

- Always update: LinkPanel takes care about your business and automatically keeps your server's software up to date so you always have the latest security patches.

- Integrate LinkPanel with your own software via Rest API and Swagger.

- Real-time servers stats: Keep an eye on everything through an awesome dashboard.

- Always up to date: LinkPanel installs last versions of LTS dists and supports Ubuntu 20.04 LTS :)

## Discover LinkPanel
Visit website: https://linkpanel.atsi.cloud

## Documentation
LinkPanel Documentation is available at: https://linkpanel.atsi.cloud/docs.html.

## Installation
```bash
wget -O - https://raw.githubusercontent.com/ATSiCorp/LinkPanel/main/installer.sh | bash
```
#### Installation on VPS
VPS by default disables root login. To login as root inside VPS, login as default user and then use command sudo -s.
And please dont use master branch, I still development them, if you want to still using master branch, you own risk for it.

```
$ ssh ubuntu@<your server IP address>
$ ubuntu@aws:~$ sudo -s
$ root@user:~# wget -O - https://raw.githubusercontent.com/ATSiCorp/LinkPanel/main/installer.sh | bash
```
Remember to open ports: 22, 80 and 443!

#### Installation Note
Before you can use LinkPanel, please make sure your server fulfils these requirements:

- Ubuntu 24.04 x86_64 LTS (Fresh installation)
- If the server is virtual (VPS), OpenVZ may not be supported
- We are checking LinkPanel compatibility within Oracle / ARM (not full supported yet)

Hardware Requirement: More than 1GB of HD / At least 1 core processor / 512MB minimum RAM / At least 1 public IP  Address (IPv6 and NAT VPS are not supported) / For VPS providers such as VPS, those providers already include an external firewall for your VPS. Please open port 22, 80 and 443 to install LinkPanel.

Installation may take up to about 30 minutes which may also depend on your server's internet speed. After the installation is completed, you are ready to use LinkPanel to manage your servers.

To correctly manage remote servers LinkPanel has to be on a public IP address (IPv4). Do not use it in localhost!

## LinkPanel LEMP environment
- nginx: Latest
- PHP-FPM: 8.2, 8.1, 8.0, 7.4
- MySql: Latest
- node: Latest
- npm: Latest
- Composer: Latest

## Screenshots

<img src="https://linkpanel.atsi.cloud/assets/images/docs/dashboard.png"> 

<img src="https://linkpanel.atsi.cloud/assets/images/docs/server.png"> 

<img src="https://linkpanel.atsi.cloud/assets/images/docs/site.png"> 

## Why use LinkPanel?
LinkPanel is easy, stable, powerful and free for any personal and commercial use and it's a perfect alternative to Runcloud, Ploi.io, Serverpilot, Forge, Moss.atsi.cloud and similar software...

## LinkPanel Roadmap... what's next? 
- LinkPanel Version 4 (half 2024)
- Laravel 9 support
- Backup on s3
- Apps installer
- ...

## Contributing
Thank you for considering contributing to the LinkPanel Project (code, issues, feedbacks, stars, promo, beers) :)

#### ...anyway star this project on Github, Thankyou ;)

## Licence
LinkPanel is an open-source software licensed under the MIT license.

## Need support with LinkPanel?
Please open an issue here: https://github.com/ATSiCorp/linkpanel/issues.

## Write to LinkPanel
Write an email to: hello@linkpanel.atsi.cloud

### ...enjoy LinkPanel :)
