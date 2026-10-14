# Windows Jenkins → Ubuntu VM Tomcat CI/CD lab

## Assumptions
- Windows 10/11: Eclipse, JDK 17, Maven, Git for Windows, Jenkins, Windows OpenSSH client
- Ubuntu 24.04 VM: OpenSSH server, Tomcat 10, Java 17, unzip, curl
- VM IP **example**: `192.168.56.101` (replace with your actual IP)
- Jenkins URL **example**: `http://localhost:8081`
- This is **Tomcat**, not JEUS. JEUS requires a separate vendor-specific deploy implementation.

## 1. Ubuntu VM preparation
```bash
sudo apt update
sudo apt install -y openjdk-17-jdk tomcat10 openssh-server unzip curl
sudo systemctl enable --now ssh tomcat10
ip -4 addr
sudo adduser deploy
sudo install -d -m 0755 /opt/deploy
sudo install -d -o deploy -g deploy -m 0750 /opt/deploy/incoming
sudo install -d -m 0755 /opt/deploy/releases
```
Set VM networking to bridged or host-only with a reachable IP; allow Windows→VM TCP 22 and 8080. Test `http://VM-IP:8080/` from Windows. VM image and firewall configuration vary.

## 2. SSH key (Windows PowerShell)
```powershell
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\jenkins_vm_lab" -C "jenkins-vm-lab"
Get-Content "$env:USERPROFILE\.ssh\jenkins_vm_lab.pub"
```
Add the **public** key text as one line to `/home/deploy/.ssh/authorized_keys` on Ubuntu; create the `.ssh` directory with mode 700 and authorized_keys mode 600, owned by deploy. Never copy the private key to Linux. On Windows, add the VM host key to the known_hosts of the **Windows account running the Jenkins agent**, verifying its fingerprint through a trusted channel. Test SSH as that account. Register the private key in Jenkins Credentials as kind `SSH Username with private key`, ID `linux-vm-ssh`, Username `deploy`.

## 3. Linux deployment script installation
Copy `linux/deploy-hello-ci` to `/usr/local/sbin/deploy-hello-ci`, owner root, mode 0755. Copy `linux/sudoers-hello-ci` to `/etc/sudoers.d/hello-ci` as root, mode 0440. Verify with `sudo visudo -cf /etc/sudoers.d/hello-ci`. The deploy user should not be granted general passwordless sudo.

## 4. Windows Git repository
In Windows PowerShell, make a local **bare** repository and a working repository:
```powershell
New-Item -ItemType Directory -Force C:\JenkinsLab\git | Out-Null
New-Item -ItemType Directory -Force C:\JenkinsLab\projects | Out-Null
git init --bare C:/JenkinsLab/git/hello-ci.git
# Copy the entire hello-ci-lab folder to C:\JenkinsLab\projects\hello-ci
cd C:\JenkinsLab\projects\hello-ci
git init
git branch -M main
git config user.name "Lab User"
git config user.email "lab@example.local"
git add .
git commit -m "Initial CI/CD lab"
git remote add origin C:/JenkinsLab/git/hello-ci.git
git push -u origin main
```
Eclipse: File → Import → Existing Maven Projects → select the working repository folder. Modify sources in Eclipse, then `git add`, `git commit`, `git push origin main`.

## 5. Jenkins setup
1. Ensure Windows Jenkins service/agent account can run `git`, `java`, `mvn`, `ssh`, `scp`, and `curl.exe`. Set PATH for that account; check versions from a Jenkins test job.
2. Install Jenkins plugins: Pipeline, Git, Credentials Binding, SSH Credentials (typically pulled in as dependencies).
3. Add Windows agent label `windows` to the actual node executing this pipeline. For a one-PC lab, the built-in node can be assigned this label, although separate agents are preferred for production.
4. New Item → Pipeline → Definition `Pipeline script from SCM` → SCM `Git` → Repository URL `C:/JenkinsLab/git/hello-ci.git` → Branch Specifier `*/main` → Script Path `Jenkinsfile`.
5. Jenkins and Git must have permission to read the bare repository path. A Windows service account may have different filesystem permissions from your interactive account.
6. Update `windows/deploy-vm.bat` VM_HOST, commit, push, then click `Build Now`.

## 6. Expected workflow
Git push → Jenkins Checkout → Maven WAR build → Jenkins archive WAR → SCP to `/opt/deploy/incoming/` → SSH executes restricted sudo deployment → copy release → restart Tomcat → HTTP health check.

## 7. Tests and troubleshooting
Windows:
```powershell
git --version
mvn -version
ssh -V
Test-NetConnection 192.168.56.101 -Port 22
Test-NetConnection 192.168.56.101 -Port 8080
curl.exe http://192.168.56.101:8080/hello-ci/health
```
Ubuntu:
```bash
sudo systemctl status tomcat10
sudo journalctl -u tomcat10 -n 100 --no-pager
ls -l /opt/deploy/incoming /opt/deploy/releases
ls -l /var/lib/tomcat10/webapps/hello-ci.war
```
**Important:** The example deliberately restarts the whole Tomcat service, briefly interrupting every app on it. For production, use approved deployment interfaces, coordinated restarts, rollback, and secret/permission hardening. Avoid auto-deploying on every push to production.
