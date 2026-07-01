# Lab 07: Role Circular Dependencies

## Difficulty: ⭐⭐ Medium

## Scenario
You have two roles: `app` and `db`. The `app` role depends on `db` (to set up the database first), and `db` depends on `app` (to notify the app after DB changes). This creates a circular dependency that causes Ansible to fail during role resolution with a recursion error.

## Expected Error Output
```
ERROR! A recursion loop was detected with the roles specified. 
Make sure roles don't depend on each other in a circular fashion.

The error appears to be in '/path/to/lab-07/roles/app/meta/main.yml':
  Role 'app' depends on role 'db'
  Role 'db' depends on role 'app'

ERROR! Recursive role dependency detected: app -> db -> app
```

## Hints
1. Check `roles/app/meta/main.yml` and `roles/db/meta/main.yml` for their dependency lists.
2. Break the circular dependency — decide which role truly depends on the other.
3. Use `pre_tasks`/`post_tasks` or separate plays instead of role dependencies for cross-role communication.

## Troubleshooting Commands
```bash
cat roles/app/meta/main.yml
cat roles/db/meta/main.yml
ansible-playbook site.yml --list-roles
ansible-galaxy role list
ansible-playbook site.yml --syntax-check
```
