# Lab 06: Vault Decryption Failure

## Difficulty: ⭐⭐ Medium

## Scenario
You're deploying an application that reads database credentials from an encrypted Ansible Vault file. The playbook fails because the vault password file contains the wrong password. The vault was encrypted with `CorrectP@ssword456!` but `vault-password.txt` contains `WrongP@ssword123!`. The playbook cannot decrypt `vault.yml` to read the secrets.

## Expected Error Output
```
PLAY [Deploy application with secrets] *****************************************

ERROR! Attempting to decrypt but the vault password provided ('vault-password.txt') is not correct for /home/user/lab-06-vault-decryption/vault.yml

Decryption failed (no vault secrets were found that could decrypt) for 
/home/user/lab-06-vault-decryption/vault.yml

Attempting to decrypt but the vault secrets provided do not match. Please check your vault password.
```

## Hints
1. The vault-password.txt file contains the wrong password — what was the original encryption password?
2. You can re-encrypt the vault with the correct password using `ansible-vault rekey`.
3. Alternatively, decrypt with the correct password and re-encrypt with the password in `vault-password.txt`.

## Troubleshooting Commands
```bash
ansible-vault view vault.yml --vault-password-file vault-password.txt
ansible-vault decrypt vault.yml --vault-password-file vault-password.txt
cat vault-password.txt
ansible-playbook playbook.yml --vault-password-file vault-password.txt --syntax-check
head -1 vault.yml
```
